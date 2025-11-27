-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;

-- ============================================
-- 1. USER PROFILES & SETTINGS
-- ============================================

-- User Profile table (extends auth.users)
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
    preferred_chatbot_persona TEXT DEFAULT 'wise_mentor' CHECK (preferred_chatbot_persona IN ('angry_mom', 'supportive_cheerleader', 'wise_mentor')),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Settings
CREATE TABLE public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Notification Settings
    enable_notifications BOOLEAN DEFAULT TRUE,
    enable_daily_reminders BOOLEAN DEFAULT TRUE,
    enable_mission_alerts BOOLEAN DEFAULT TRUE,
    enable_budget_alerts BOOLEAN DEFAULT TRUE,
    
    -- App Preferences
    currency TEXT DEFAULT 'IDR',
    language TEXT DEFAULT 'id',
    theme TEXT DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'auto')),
    
    -- AI Settings
    enable_ai_insights BOOLEAN DEFAULT TRUE,
    enable_ocr BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- ============================================
-- 2. FINANCIAL TRACKING
-- ============================================

-- Categories for transactions
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    icon TEXT,
    color TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(name, type, user_id)
);

-- Transactions
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id),
    
    -- Transaction Details
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    notes TEXT,
    
    -- Date & Time
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    transaction_time TIME,
    
    -- Input Method
    input_method TEXT DEFAULT 'manual' CHECK (input_method IN ('manual', 'ai_chat', 'ocr', 'voice')),
    
    -- OCR Data (if from receipt)
    receipt_image_url TEXT,
    ocr_raw_data JSONB,
    merchant_name TEXT,
    
    -- Location (optional)
    location TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Budgets
CREATE TABLE public.budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    
    name TEXT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    period TEXT NOT NULL CHECK (period IN ('daily', 'weekly', 'monthly', 'yearly')),
    
    -- Date Range
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- Alerts
    alert_threshold INTEGER DEFAULT 80 CHECK (alert_threshold BETWEEN 0 AND 100),
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CHECK (end_date > start_date)
);

-- ============================================
-- 3. AI CHATBOT & CONVERSATIONS
-- ============================================

-- Chatbot Conversations
CREATE TABLE public.chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    title TEXT,
    persona TEXT NOT NULL CHECK (persona IN ('angry_mom', 'supportive_cheerleader', 'wise_mentor')),
    
    -- Conversation Context
    context_summary TEXT,
    last_message_at TIMESTAMPTZ,
    
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat Messages
CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
    
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    
    -- AI Metadata
    persona TEXT,
    intent TEXT, -- e.g., 'record_transaction', 'financial_advice', 'general_chat'
    extracted_data JSONB, -- parsed transaction data, etc.
    
    -- Related Transaction (if message resulted in transaction)
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE SET NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 4. GAMIFICATION SYSTEM
-- ============================================

-- Badges
CREATE TABLE public.badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT,
    category TEXT CHECK (category IN ('tracking', 'saving', 'investment', 'streak', 'special')),
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    xp_reward INTEGER DEFAULT 0,
    
    -- Requirements
    requirement_type TEXT, -- e.g., 'transactions_count', 'streak_days', 'savings_goal'
    requirement_value INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Badges (earned)
CREATE TABLE public.user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,
    
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, badge_id)
);

-- Daily Missions
CREATE TABLE public.missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('daily', 'weekly', 'monthly', 'special', 'achievement')),
    category TEXT CHECK (category IN ('tracking', 'saving', 'investment', 'education', 'social')),
    
    -- Rewards
    xp_reward INTEGER DEFAULT 0,
    points_reward INTEGER DEFAULT 0,
    
    -- Requirements
    requirement_type TEXT NOT NULL, -- e.g., 'record_transactions', 'save_amount', 'complete_lesson'
    requirement_value INTEGER NOT NULL,
    requirement_data JSONB,
    
    -- Availability
    is_active BOOLEAN DEFAULT TRUE,
    difficulty TEXT DEFAULT 'easy' CHECK (difficulty IN ('easy', 'medium', 'hard')),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Missions (progress tracking)
CREATE TABLE public.user_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    mission_id UUID NOT NULL REFERENCES public.missions(id) ON DELETE CASCADE,
    
    current_progress INTEGER DEFAULT 0,
    target_progress INTEGER NOT NULL,
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'claimed', 'expired')),
    
    -- Dates
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ
);

-- ============================================
-- 5. INVESTMENT & EDUCATION
-- ============================================

-- Investment Education Courses
CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    
    -- Course Details
    level TEXT DEFAULT 'beginner' CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    category TEXT CHECK (category IN ('stocks', 'crypto', 'bonds', 'forex', 'fundamental', 'technology')),
    duration_minutes INTEGER,
    
    -- News API Configuration (bukan lesson content static)
    -- Stores: api_source, query, language, country, category, pageSize
    content JSONB NOT NULL,
    
    -- Rewards
    xp_reward INTEGER DEFAULT 0,
    
    is_published BOOLEAN DEFAULT TRUE,
    order_index INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Course Progress (simplified untuk news-based courses)
CREATE TABLE public.user_course_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    
    -- Track artikel berita yang sudah dibaca (array of article URLs)
    read_articles JSONB DEFAULT '[]'::jsonb,
    total_articles_read INTEGER DEFAULT 0,
    
    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, course_id)
);

-- Virtual Trading Portfolio
CREATE TABLE public.virtual_portfolios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    name TEXT DEFAULT 'My Portfolio',
    initial_balance DECIMAL(15, 2) DEFAULT 10000000, -- 10 juta IDR virtual
    current_balance DECIMAL(15, 2) DEFAULT 10000000,
    total_profit_loss DECIMAL(15, 2) DEFAULT 0,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Virtual Trading Positions
CREATE TABLE public.virtual_positions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id UUID NOT NULL REFERENCES public.virtual_portfolios(id) ON DELETE CASCADE,
    
    -- Asset Details
    asset_symbol TEXT NOT NULL, -- e.g., 'BBCA', 'TLKM', 'BTC', 'ETH'
    asset_type TEXT NOT NULL CHECK (asset_type IN ('stock', 'crypto', 'forex', 'commodity')),
    asset_name TEXT,
    
    -- Position Details
    quantity DECIMAL(15, 8) NOT NULL CHECK (quantity > 0),
    entry_price DECIMAL(15, 2) NOT NULL,
    current_price DECIMAL(15, 2),
    
    -- P&L
    profit_loss DECIMAL(15, 2) DEFAULT 0,
    profit_loss_percentage DECIMAL(5, 2) DEFAULT 0,
    
    -- Dates
    opened_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed'))
);

-- Virtual Trading Transactions
CREATE TABLE public.virtual_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id UUID NOT NULL REFERENCES public.virtual_portfolios(id) ON DELETE CASCADE,
    position_id UUID REFERENCES public.virtual_positions(id) ON DELETE SET NULL,
    
    type TEXT NOT NULL CHECK (type IN ('buy', 'sell')),
    asset_symbol TEXT NOT NULL,
    asset_type TEXT NOT NULL,
    
    quantity DECIMAL(15, 8) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    
    -- Fees (simulated)
    fee DECIMAL(15, 2) DEFAULT 0,
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Investment Challenges/Missions
CREATE TABLE public.investment_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    title TEXT NOT NULL,
    description TEXT,
    type TEXT CHECK (type IN ('diversification', 'profit_target', 'risk_management', 'trading_frequency')),
    
    -- Requirements
    target_value DECIMAL(15, 2),
    duration_days INTEGER,
    
    -- Rewards
    xp_reward INTEGER DEFAULT 0,
    points_reward INTEGER DEFAULT 0,
    
    difficulty TEXT DEFAULT 'easy' CHECK (difficulty IN ('easy', 'medium', 'hard')),
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Investment Challenge Progress
CREATE TABLE public.user_investment_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES public.investment_challenges(id) ON DELETE CASCADE,
    
    progress_data JSONB DEFAULT '{}'::jsonb,
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'failed', 'claimed')),
    
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- ============================================
-- 6. AI INSIGHTS & ANALYTICS
-- ============================================

-- AI-Generated Financial Insights
CREATE TABLE public.financial_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    type TEXT NOT NULL CHECK (type IN ('spending_pattern', 'saving_tip', 'budget_alert', 'investment_advice', 'trend_analysis')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    
    -- Priority
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    
    -- Action Items
    suggested_actions JSONB,
    
    -- Related Data
    related_category_id UUID REFERENCES public.categories(id),
    related_transaction_ids JSONB,
    analysis_data JSONB,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    
    valid_until DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spending Patterns (AI Analysis Results)
CREATE TABLE public.spending_patterns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    period_type TEXT NOT NULL CHECK (period_type IN ('weekly', 'monthly', 'quarterly', 'yearly')),
    
    -- Analysis Data
    total_income DECIMAL(15, 2) DEFAULT 0,
    total_expense DECIMAL(15, 2) DEFAULT 0,
    net_savings DECIMAL(15, 2) DEFAULT 0,
    
    top_categories JSONB, -- [{category_id, amount, percentage}]
    spending_trends JSONB, -- day-by-day or week-by-week data
    
    -- AI Insights
    ai_summary TEXT,
    ai_recommendations JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, period_start, period_end, period_type)
);

-- ============================================
-- INDEXES for Performance
-- ============================================

-- User Profiles
CREATE INDEX idx_user_profiles_level ON public.user_profiles(level);
CREATE INDEX idx_user_profiles_total_xp ON public.user_profiles(total_xp);

-- Transactions
CREATE INDEX idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX idx_transactions_category_id ON public.transactions(category_id);
CREATE INDEX idx_transactions_date ON public.transactions(transaction_date);
CREATE INDEX idx_transactions_type ON public.transactions(type);
CREATE INDEX idx_transactions_user_date ON public.transactions(user_id, transaction_date);

-- Budgets
CREATE INDEX idx_budgets_user_id ON public.budgets(user_id);
CREATE INDEX idx_budgets_dates ON public.budgets(start_date, end_date);
CREATE INDEX idx_budgets_active ON public.budgets(is_active);

-- Chat
CREATE INDEX idx_chat_conversations_user_id ON public.chat_conversations(user_id);
CREATE INDEX idx_chat_messages_conversation_id ON public.chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_created_at ON public.chat_messages(created_at);

-- Gamification
CREATE INDEX idx_user_badges_user_id ON public.user_badges(user_id);
CREATE INDEX idx_user_missions_user_id ON public.user_missions(user_id);
CREATE INDEX idx_user_missions_status ON public.user_missions(status);

-- Investment
CREATE INDEX idx_virtual_portfolios_user_id ON public.virtual_portfolios(user_id);
CREATE INDEX idx_virtual_positions_portfolio_id ON public.virtual_positions(portfolio_id);
CREATE INDEX idx_virtual_positions_status ON public.virtual_positions(status);

-- Insights
CREATE INDEX idx_financial_insights_user_id ON public.financial_insights(user_id);
CREATE INDEX idx_financial_insights_type ON public.financial_insights(type);
CREATE INDEX idx_financial_insights_read ON public.financial_insights(is_read);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_course_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.virtual_portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.virtual_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.virtual_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_investment_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spending_patterns ENABLE ROW LEVEL SECURITY;

-- User Profiles Policies
CREATE POLICY "Users can view own profile"
    ON public.user_profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.user_profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- User Settings Policies
CREATE POLICY "Users can manage own settings"
    ON public.user_settings FOR ALL
    USING (auth.uid() = user_id);

-- Categories Policies
CREATE POLICY "Users can view all system categories"
    ON public.categories FOR SELECT
    USING (is_system = TRUE OR auth.uid() = user_id);

CREATE POLICY "Users can manage own custom categories"
    ON public.categories FOR ALL
    USING (auth.uid() = user_id AND is_system = FALSE);

-- Transactions Policies
CREATE POLICY "Users can manage own transactions"
    ON public.transactions FOR ALL
    USING (auth.uid() = user_id);

-- Budgets Policies
CREATE POLICY "Users can manage own budgets"
    ON public.budgets FOR ALL
    USING (auth.uid() = user_id);

-- Chat Policies
CREATE POLICY "Users can manage own conversations"
    ON public.chat_conversations FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view messages in own conversations"
    ON public.chat_messages FOR SELECT
    USING (
        conversation_id IN (
            SELECT id FROM public.chat_conversations WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert messages in own conversations"
    ON public.chat_messages FOR INSERT
    WITH CHECK (
        conversation_id IN (
            SELECT id FROM public.chat_conversations WHERE user_id = auth.uid()
        )
    );

-- Badges Policies (read-only for all)
CREATE POLICY "Everyone can view badges"
    ON public.badges FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can view own earned badges"
    ON public.user_badges FOR SELECT
    USING (auth.uid() = user_id);

-- Missions Policies
CREATE POLICY "Everyone can view active missions"
    ON public.missions FOR SELECT
    TO authenticated
    USING (is_active = TRUE);

CREATE POLICY "Users can manage own mission progress"
    ON public.user_missions FOR ALL
    USING (auth.uid() = user_id);

-- Courses Policies
CREATE POLICY "Everyone can view published courses"
    ON public.courses FOR SELECT
    TO authenticated
    USING (is_published = TRUE);

CREATE POLICY "Users can manage own course progress"
    ON public.user_course_progress FOR ALL
    USING (auth.uid() = user_id);

-- Virtual Trading Policies
CREATE POLICY "Users can manage own portfolios"
    ON public.virtual_portfolios FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view positions in own portfolios"
    ON public.virtual_positions FOR SELECT
    USING (
        portfolio_id IN (
            SELECT id FROM public.virtual_portfolios WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert positions in own portfolios"
    ON public.virtual_positions FOR INSERT
    WITH CHECK (
        portfolio_id IN (
            SELECT id FROM public.virtual_portfolios WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update positions in own portfolios"
    ON public.virtual_positions FOR UPDATE
    USING (
        portfolio_id IN (
            SELECT id FROM public.virtual_portfolios WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete positions in own portfolios"
    ON public.virtual_positions FOR DELETE
    USING (
        portfolio_id IN (
            SELECT id FROM public.virtual_portfolios WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage own virtual transactions"
    ON public.virtual_transactions FOR ALL
    USING (
        portfolio_id IN (
            SELECT id FROM public.virtual_portfolios WHERE user_id = auth.uid()
        )
    );

-- Investment Challenges Policies
CREATE POLICY "Everyone can view active challenges"
    ON public.investment_challenges FOR SELECT
    TO authenticated
    USING (is_active = TRUE);

CREATE POLICY "Users can manage own challenge progress"
    ON public.user_investment_challenges FOR ALL
    USING (auth.uid() = user_id);

-- Insights Policies
CREATE POLICY "Users can manage own insights"
    ON public.financial_insights FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view own spending patterns"
    ON public.spending_patterns FOR SELECT
    USING (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_budgets_updated_at
    BEFORE UPDATE ON public.budgets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at
    BEFORE UPDATE ON public.courses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_virtual_portfolios_updated_at
    BEFORE UPDATE ON public.virtual_portfolios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to update user last_activity_date
CREATE OR REPLACE FUNCTION update_user_last_activity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.user_profiles
    SET last_activity_date = CURRENT_DATE
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply last_activity trigger
CREATE TRIGGER update_last_activity_on_transaction
    AFTER INSERT ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_last_activity();

CREATE TRIGGER update_last_activity_on_chat
    AFTER INSERT ON public.chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_user_last_activity();

-- Function to create default user settings on profile creation
CREATE OR REPLACE FUNCTION create_default_user_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_user_settings_on_profile_creation
    AFTER INSERT ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_default_user_settings();

-- Function to create default virtual portfolio on profile creation
CREATE OR REPLACE FUNCTION create_default_virtual_portfolio()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.virtual_portfolios (user_id, name)
    VALUES (NEW.id, 'Portfolio Utama');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_portfolio_on_profile_creation
    AFTER INSERT ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION create_default_virtual_portfolio();
