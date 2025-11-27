-- ============================================
-- EXTENSIONS
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USER PROFILES & SETTINGS
-- ============================================

CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    phone_number TEXT,
    date_of_birth DATE,

    -- Gamification
    level INTEGER DEFAULT 1,
    total_xp INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,

    -- Financial Profile
    monthly_income DECIMAL(15, 2),
    risk_profile TEXT CHECK (risk_profile IN ('conservative', 'moderate', 'aggressive')),
    financial_goals JSONB DEFAULT '[]'::jsonb,

    -- AI Preferences
    preferred_chatbot_persona TEXT DEFAULT 'wise_mentor'
        CHECK (preferred_chatbot_persona IN ('angry_mom', 'supportive_cheerleader', 'wise_mentor')),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,

    enable_notifications BOOLEAN DEFAULT TRUE,
    enable_daily_reminders BOOLEAN DEFAULT TRUE,
    enable_mission_alerts BOOLEAN DEFAULT TRUE,
    enable_budget_alerts BOOLEAN DEFAULT TRUE,

    currency TEXT DEFAULT 'IDR',
    language TEXT DEFAULT 'id',
    theme TEXT DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'auto')),

    enable_ai_insights BOOLEAN DEFAULT TRUE,
    enable_ocr BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================
-- 2. FINANCIAL TRACKING
-- ============================================

CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    icon TEXT,
    color TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(name, type, user_id)
);

CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id),

    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    notes TEXT,

    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    transaction_time TIME,

    input_method TEXT DEFAULT 'manual'
        CHECK (input_method IN ('manual', 'ai_chat', 'ocr', 'voice')),

    receipt_image_url TEXT,
    ocr_raw_data JSONB,
    merchant_name TEXT,

    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,

    name TEXT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    period TEXT NOT NULL CHECK (period IN ('daily', 'weekly', 'monthly', 'yearly')),

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    alert_threshold INTEGER DEFAULT 80 CHECK (alert_threshold BETWEEN 0 AND 100),
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CHECK (end_date > start_date)
);

-- ============================================
-- 3. AI CHATBOT SYSTEM
-- ============================================

CREATE TABLE public.chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,

    title TEXT,
    persona TEXT NOT NULL CHECK (persona IN ('angry_mom', 'supportive_cheerleader', 'wise_mentor')),
    context_summary TEXT,
    last_message_at TIMESTAMPTZ,

    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.chat_conversations(id) ON DELETE CASCADE,

    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,

    persona TEXT,
    intent TEXT,
    extracted_data JSONB,
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE SET NULL,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 4. GAMIFICATION SYSTEM
-- ============================================

CREATE TABLE public.badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT,
    category TEXT CHECK (category IN ('tracking', 'saving', 'investment', 'streak', 'special')),
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    xp_reward INTEGER DEFAULT 0,

    requirement_type TEXT,
    requirement_value INTEGER,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,

    earned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

CREATE TABLE public.missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('daily', 'weekly', 'monthly', 'special', 'achievement')),
    category TEXT CHECK (category IN ('tracking', 'saving', 'investment', 'education', 'social')),

    xp_reward INTEGER DEFAULT 0,
    points_reward INTEGER DEFAULT 0,

    requirement_type TEXT NOT NULL,
    requirement_value INTEGER NOT NULL,
    requirement_data JSONB,

    is_active BOOLEAN DEFAULT TRUE,
    difficulty TEXT DEFAULT 'easy' CHECK (difficulty IN ('easy', 'medium', 'hard')),

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    mission_id UUID NOT NULL REFERENCES public.missions(id) ON DELETE CASCADE,

    current_progress INTEGER DEFAULT 0,
    target_progress INTEGER NOT NULL,
    status TEXT DEFAULT 'in_progress'
        CHECK (status IN ('in_progress', 'completed', 'claimed', 'expired')),

    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,

    UNIQUE(user_id, mission_id, started_at::date)
);

-- ============================================
-- 5. EDUCATION & VIRTUAL TRADING
-- ============================================

CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,

    level TEXT DEFAULT 'beginner'
        CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    category TEXT CHECK (category IN ('stocks', 'crypto', 'bonds', 'forex', 'fundamental', 'technology')),
    duration_minutes INTEGER,

    -- News API configuration (bukan lesson content)
    content JSONB NOT NULL, -- Stores: api_source, query, language, country, category, pageSize
    xp_reward INTEGER DEFAULT 0,

    is_published BOOLEAN DEFAULT TRUE,
    order_index INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_course_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,

    -- Track artikel berita yang sudah dibaca (berisi array of article URLs)
    read_articles JSONB DEFAULT '[]',
    total_articles_read INTEGER DEFAULT 0,

    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, course_id)
);

CREATE TABLE public.virtual_portfolios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,

    name TEXT DEFAULT 'My Portfolio',
    initial_balance DECIMAL(15, 2) DEFAULT 10000000,
    current_balance DECIMAL(15, 2) DEFAULT 10000000,
    total_profit_loss DECIMAL(15, 2) DEFAULT 0,

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.virtual_positions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    portfolio_id UUID NOT NULL REFERENCES public.virtual_portfolios(id) ON DELETE CASCADE,

    asset_symbol TEXT NOT NULL,
    asset_type TEXT NOT NULL CHECK (asset_type IN ('stock', 'crypto', 'forex', 'commodity')),
    asset_name TEXT,

    quantity DECIMAL(15, 8) NOT NULL CHECK (quantity > 0),
    entry_price DECIMAL(15, 2) NOT NULL,
    current_price DECIMAL(15, 2),

    profit_loss DECIMAL(15, 2) DEFAULT 0,
    profit_loss_percentage DECIMAL(5, 2) DEFAULT 0,

    opened_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ,

    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed'))
);

CREATE TABLE public.virtual_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    portfolio_id UUID NOT NULL REFERENCES public.virtual_portfolios(id) ON DELETE CASCADE,
    position_id UUID REFERENCES public.virtual_positions(id) ON DELETE SET NULL,

    type TEXT NOT NULL CHECK (type IN ('buy', 'sell')),
    asset_symbol TEXT NOT NULL,
    asset_type TEXT NOT NULL,

    quantity DECIMAL(15, 8) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,

    fee DECIMAL(15, 2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.investment_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    title TEXT NOT NULL,
    description TEXT,
    type TEXT CHECK (type IN ('diversification', 'profit_target', 'risk_management', 'trading_frequency')),

    target_value DECIMAL(15, 2),
    duration_days INTEGER,

    xp_reward INTEGER DEFAULT 0,
    points_reward INTEGER DEFAULT 0,

    difficulty TEXT DEFAULT 'easy' CHECK (difficulty IN ('easy', 'medium', 'hard')),
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_investment_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES public.investment_challenges(id) ON DELETE CASCADE,

    progress_data JSONB DEFAULT '{}'::jsonb,
    status TEXT DEFAULT 'in_progress'
        CHECK (status IN ('in_progress', 'completed', 'failed', 'claimed')),

    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,

    UNIQUE(user_id, challenge_id, started_at::date)
);

-- ============================================
-- 6. AI INSIGHTS & ANALYTICS
-- ============================================

CREATE TABLE public.financial_insights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,

    type TEXT CHECK (type IN ('spending_pattern','saving_tip','budget_alert','investment_advice','trend_analysis')),
    priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),

    suggested_actions JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    dismissed_at TIMESTAMPTZ,
    valid_until TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.spending_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,

    period_type TEXT CHECK (period_type IN ('weekly','monthly','quarterly','yearly')),
    period_start DATE,
    period_end DATE,

    total_income DECIMAL(15, 2),
    total_expense DECIMAL(15, 2),
    total_savings DECIMAL(15, 2),

    top_categories JSONB,
    trends JSONB,
    ai_summary TEXT,
    ai_recommendations JSONB,

    created_at TIMESTAMPTZ DEFAULT NOW()
);
