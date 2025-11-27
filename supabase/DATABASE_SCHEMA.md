# MoneyStocks Database Schema Documentation

## Overview
Database backend untuk aplikasi MoneyStocks - AI-powered financial management app dengan fitur chatbot, gamification, dan investment education.

## Database Structure

### 1. User Management

#### `user_profiles`
Extends auth.users dengan data profil lengkap
- **Core Fields**: `id`, `full_name`, `avatar_url`, `phone_number`, `date_of_birth`
- **Gamification**: `level`, `total_xp`, `total_points`, `current_streak`, `longest_streak`
- **Financial Profile**: `monthly_income`, `risk_profile`, `financial_goals`
- **AI Preferences**: `preferred_chatbot_persona` (angry_mom, supportive_cheerleader, wise_mentor)

#### `user_settings`
User preferences dan konfigurasi aplikasi
- Notification settings
- Currency, language, theme preferences
- AI feature toggles (insights, OCR)

### 2. Financial Tracking

#### `categories`
Kategori transaksi (income/expense)
- System categories (default) dan user custom categories
- Includes: `name`, `type`, `icon`, `color`
- RLS: Users dapat create custom categories

#### `transactions`
Record semua transaksi keuangan
- **Core**: `amount`, `description`, `type` (income/expense)
- **Date/Time**: `transaction_date`, `transaction_time`
- **Input Method**: `manual`, `ai_chat`, `ocr`, `voice`
- **OCR Support**: `receipt_image_url`, `ocr_raw_data`, `merchant_name`
- **Location**: Optional GPS coordinates

#### `budgets`
Budget management dengan alerts
- Period: daily, weekly, monthly, yearly
- Alert threshold (default 80%)
- Date range validation

### 3. AI Chatbot System

#### `chat_conversations`
Conversation threads dengan AI
- Persona selection per conversation
- Context summary untuk continuity
- Archive support

#### `chat_messages`
Individual chat messages
- Roles: user, assistant, system
- Intent tracking (record_transaction, financial_advice, etc.)
- `extracted_data`: Parsed information dari NLP
- `transaction_id`: Link to created transaction

### 4. Gamification System

#### `badges`
Achievement badges
- Categories: tracking, saving, investment, streak, special
- Rarity levels: common, rare, epic, legendary
- XP rewards
- Automated requirement checking

#### `user_badges`
Earned badges per user
- Timestamp tracking
- Prevents duplicates

#### `missions`
Daily/weekly/monthly challenges
- Types: daily, weekly, monthly, special, achievement
- Requirement types & values
- XP & points rewards
- Difficulty levels

#### `user_missions`
User progress pada missions
- Current vs target progress tracking
- Status: in_progress, completed, claimed, expired
- Expiration handling

### 5. Investment & Education

#### `courses`
Educational content
- Levels: beginner, intermediate, advanced
- Categories: stocks, crypto, bonds, forex, fundamental, technical
- JSONB content structure (lessons, videos, quizzes)
- XP rewards on completion

#### `user_course_progress`
User learning progress
- Progress percentage
- Completed lessons tracking
- Quiz scores storage

#### `virtual_portfolios`
Simulated trading portfolios
- Initial balance: 10,000,000 IDR virtual
- Real-time P&L tracking
- Multiple portfolios per user (optional)

#### `virtual_positions`
Active/closed trading positions
- Asset details (symbol, type, name)
- Entry price, current price
- Profit/Loss calculations
- Auto-updated dengan price changes

#### `virtual_transactions`
Trading transaction history
- Buy/sell records
- Quantity, price, total calculations
- Fee simulation

#### `investment_challenges`
Trading challenges/missions
- Types: diversification, profit_target, risk_management, trading_frequency
- Duration-based
- Rewards system

#### `user_investment_challenges`
User progress pada investment challenges
- Progress data (JSONB)
- Status tracking
- Completion timestamps

### 6. AI Insights & Analytics

#### `financial_insights`
AI-generated financial advice
- Types: spending_pattern, saving_tip, budget_alert, investment_advice, trend_analysis
- Priority levels
- Suggested actions (JSONB)
- Read/dismiss status
- Validity period

#### `spending_patterns`
Periodic spending analysis
- Period types: weekly, monthly, quarterly, yearly
- Income/expense/savings totals
- Top categories analysis
- Spending trends (JSONB)
- AI summary & recommendations

## Key Features

### Row Level Security (RLS)
✅ All tables protected dengan RLS policies
- Users can only access their own data
- System data (categories, badges, missions, courses) readable by all authenticated users
- Chat messages restricted to conversation participants

### Automatic Triggers
✅ `updated_at` auto-update on modifications
✅ `last_activity_date` updated on user actions
✅ Default settings created on user registration
✅ Default virtual portfolio created on signup

### Indexes
✅ Optimized indexes pada:
- User lookups (user_id)
- Date-based queries (transaction_date)
- Status filtering
- Conversation threading

## Data Relationships

```
user_profiles (1) ──> (*) transactions
user_profiles (1) ──> (*) budgets
user_profiles (1) ──> (*) chat_conversations
user_profiles (1) ──> (1) user_settings
user_profiles (1) ──> (*) virtual_portfolios

categories (1) ──> (*) transactions
categories (1) ──> (*) budgets

chat_conversations (1) ──> (*) chat_messages
transactions (1) <──> (0..1) chat_messages

virtual_portfolios (1) ──> (*) virtual_positions
virtual_portfolios (1) ──> (*) virtual_transactions

badges (1) ──> (*) user_badges
missions (1) ──> (*) user_missions
courses (1) ──> (*) user_course_progress
investment_challenges (1) ──> (*) user_investment_challenges
```

## Seed Data Included

### Categories
- **Income**: Gaji, Bonus, Investasi, Freelance, Bisnis, Hadiah, Lainnya
- **Expense**: Makanan & Minuman, Transportasi, Belanja, Tagihan, Hiburan, Kesehatan, Pendidikan, Investasi, Cicilan, Asuransi, Donasi, Kecantikan, Olahraga, Hadiah, Lainnya

### Badges
- 20+ badges across all categories
- Progression badges (Pemula → Rajin → Ahli → Legendaris)
- Streak badges (3, 7, 30, 100 days)
- Saving milestones (100K → 100M)
- Investment achievements

### Missions
- Daily missions (easy difficulty)
- Weekly missions (medium difficulty)
- Monthly missions (hard difficulty)
- Categories: tracking, saving, education, investment

### Courses
5 courses:
1. Pengenalan Investasi (Beginner)
2. Mengenal Saham (Beginner)
3. Diversifikasi Portfolio (Intermediate)
4. Analisis Fundamental (Intermediate)
5. Analisis Teknikal Dasar (Intermediate)

### Investment Challenges
- Diversifikasi Pemula
- Target Profit 5% & 10%
- Trader Aktif
- Portfolio Seimbang

## Migration & Setup

### Apply Migration
```bash
# Using Supabase CLI
supabase db reset

# Or apply specific migration
supabase migration up
```

### Seed Data
```bash
# Seed data akan otomatis dijalankan setelah migration
# Atau manual via:
psql -h <host> -U postgres -d postgres -f supabase/seed.sql
```

## API Integration

### Flutter Integration Points

1. **Authentication**
   - Sign up → Auto creates user_profile, user_settings, virtual_portfolio
   - Login → Fetch user_profile

2. **Transaction Recording**
   - Manual input → Insert ke `transactions`
   - AI Chat → Parse message → Insert ke `transactions` + link `chat_messages`
   - OCR → Extract receipt → Insert ke `transactions` dengan `receipt_image_url`

3. **Chatbot**
   - Create/resume `chat_conversations`
   - Insert user messages → Call AI API → Insert assistant response
   - Link transactions if created via chat

4. **Gamification**
   - Check badge requirements → Award badge
   - Daily mission refresh → Create new `user_missions`
   - XP gain → Update `user_profiles.total_xp` & `level`

5. **Investment**
   - Enroll course → Create `user_course_progress`
   - Complete lesson → Update progress
   - Trading → Insert `virtual_transactions` → Update `virtual_positions` & `virtual_portfolios`

6. **Insights**
   - Periodic job → Analyze spending → Insert `spending_patterns` & `financial_insights`
   - User views insight → Mark as read

## Security Considerations

✅ All user data protected by RLS
✅ No direct database access from client
✅ Use Supabase client libraries with proper auth
✅ Sensitive operations (AI calls, OCR) via Edge Functions
✅ Input validation on both client & database level

## Performance Tips

1. Use indexes untuk frequent queries
2. Pagination untuk large datasets (transactions, messages)
3. Cache static data (categories, badges, courses)
4. Batch operations untuk mission progress updates
5. Use JSONB efficiently untuk flexible data structures

## Future Enhancements

- [ ] Social features (friend system, leaderboards)
- [ ] Notifications table
- [ ] File storage metadata (receipts, avatars)
- [ ] Real market data integration
- [ ] AI prompt templates & history
- [ ] Audit logs
- [ ] Data export functionality

---

**Created**: November 2025  
**Version**: 1.0.0  
**Database**: PostgreSQL (Supabase)
