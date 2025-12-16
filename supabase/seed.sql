-- ============================================
-- SEED DATA FOR MONEYSTOCKS APPLICATION
-- ============================================

-- ============================================
-- 1. DEFAULT CATEGORIES
-- ============================================

-- Income Categories (Fixed UUIDs)
INSERT INTO public.categories (id, name, type, icon, color, is_system) VALUES
('00000000-0000-0000-0000-000000000001', 'Gaji', 'income', '💰', '#4CAF50', TRUE),
('00000000-0000-0000-0000-000000000002', 'Bonus', 'income', '🎁', '#8BC34A', TRUE),
('00000000-0000-0000-0000-000000000003', 'Investasi', 'income', '📈', '#009688', TRUE),
('00000000-0000-0000-0000-000000000004', 'Freelance', 'income', '💼', '#00BCD4', TRUE),
('00000000-0000-0000-0000-000000000005', 'Bisnis', 'income', '🏢', '#03A9F4', TRUE),
('00000000-0000-0000-0000-000000000006', 'Hadiah', 'income', '🎉', '#2196F3', TRUE),
('00000000-0000-0000-0000-000000000007', 'Lainnya', 'income', '➕', '#607D8B', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Expense Categories (Fixed UUIDs)
INSERT INTO public.categories (id, name, type, icon, color, is_system) VALUES
('00000000-0000-0000-0000-000000000011', 'Makanan & Minuman', 'expense', '🍔', '#FF5722', TRUE),
('00000000-0000-0000-0000-000000000012', 'Transportasi', 'expense', '🚗', '#FF9800', TRUE),
('00000000-0000-0000-0000-000000000013', 'Belanja', 'expense', '🛒', '#FFC107', TRUE),
('00000000-0000-0000-0000-000000000014', 'Tagihan', 'expense', '📄', '#F44336', TRUE),
('00000000-0000-0000-0000-000000000015', 'Hiburan', 'expense', '🎮', '#E91E63', TRUE),
('00000000-0000-0000-0000-000000000016', 'Kesehatan', 'expense', '🏥', '#9C27B0', TRUE),
('00000000-0000-0000-0000-000000000017', 'Pendidikan', 'expense', '📚', '#673AB7', TRUE),
('00000000-0000-0000-0000-000000000018', 'Investasi', 'expense', '💎', '#3F51B5', TRUE),
('00000000-0000-0000-0000-000000000019', 'Cicilan', 'expense', '💳', '#D32F2F', TRUE),
('00000000-0000-0000-0000-000000000020', 'Asuransi', 'expense', '🛡️', '#795548', TRUE),
('00000000-0000-0000-0000-000000000021', 'Donasi', 'expense', '❤️', '#E91E63', TRUE),
('00000000-0000-0000-0000-000000000022', 'Kecantikan', 'expense', '💄', '#EC407A', TRUE),
('00000000-0000-0000-0000-000000000023', 'Olahraga', 'expense', '⚽', '#66BB6A', TRUE),
('00000000-0000-0000-0000-000000000024', 'Hadiah', 'expense', '🎁', '#AB47BC', TRUE),
('00000000-0000-0000-0000-000000000025', 'Lainnya', 'expense', '❓', '#607D8B', TRUE)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. BADGES (ACHIEVEMENTS)
-- ============================================

INSERT INTO public.badges (name, description, icon, category, rarity, xp_reward, requirement_type, requirement_value) VALUES
-- Tracking Badges
('Pencatat Pemula', 'Catat transaksi pertamamu', '📝', 'tracking', 'common', 10, 'transactions_count', 1),
('Pencatat Rajin', 'Catat 10 transaksi', '📊', 'tracking', 'common', 50, 'transactions_count', 10),
('Master Pencatat', 'Catat 100 transaksi', '📈', 'tracking', 'rare', 200, 'transactions_count', 100),
('Pencatat Legendaris', 'Catat 1000 transaksi', '🏆', 'tracking', 'legendary', 1000, 'transactions_count', 1000),

-- Streak Badges
('Streak 3 Hari', 'Catat transaksi 3 hari berturut-turut', '🔥', 'streak', 'common', 30, 'streak_days', 3),
('Streak 7 Hari', 'Catat transaksi 7 hari berturut-turut', '🔥🔥', 'streak', 'rare', 100, 'streak_days', 7),
('Streak 30 Hari', 'Catat transaksi 30 hari berturut-turut', '🔥🔥🔥', 'streak', 'epic', 500, 'streak_days', 30),
('Streak 100 Hari', 'Catat transaksi 100 hari berturut-turut', '🔥🔥🔥🔥', 'streak', 'legendary', 2000, 'streak_days', 100),

-- Saving Badges
('Penabung Pemula', 'Hemat Rp 100.000', '🪙', 'saving', 'common', 20, 'savings_amount', 100000),
('Penabung Rajin', 'Hemat Rp 1.000.000', '💰', 'saving', 'rare', 100, 'savings_amount', 1000000),
('Penabung Ahli', 'Hemat Rp 10.000.000', '💎', 'saving', 'epic', 500, 'savings_amount', 10000000),
('Jutawan', 'Hemat Rp 100.000.000', '👑', 'saving', 'legendary', 5000, 'savings_amount', 100000000),

-- Investment Badges
('Investor Pemula', 'Selesaikan kursus pertama', '📚', 'investment', 'common', 50, 'courses_completed', 1),
('Trader Pemula', 'Lakukan transaksi trading pertama', '📊', 'investment', 'common', 30, 'trades_count', 1),
('Portfolio Manager', 'Diversifikasi portfolio dengan 5 aset berbeda', '📈', 'investment', 'rare', 200, 'assets_count', 5),
('Profit Master', 'Raih profit 10% di virtual trading', '💹', 'investment', 'epic', 500, 'profit_percentage', 10),

-- Special Badges
('Early Adopter', 'Salah satu pengguna pertama MoneyStocks', '⭐', 'special', 'legendary', 1000, 'manual', 0),
('Perfect Month', 'Catat semua transaksi selama sebulan penuh', '📅', 'special', 'epic', 500, 'manual', 0),
('AI Enthusiast', 'Gunakan AI chatbot 50 kali', '🤖', 'special', 'rare', 200, 'chat_messages_count', 50);

-- ============================================
-- 3. DAILY MISSIONS
-- ============================================

INSERT INTO public.missions (title, description, type, category, xp_reward, points_reward, requirement_type, requirement_value, difficulty) VALUES
-- Daily Missions
('Catat 1 Transaksi', 'Catat minimal 1 transaksi hari ini', 'daily', 'tracking', 10, 10, 'record_transactions', 1, 'easy'),
('Catat 3 Transaksi', 'Catat minimal 3 transaksi hari ini', 'daily', 'tracking', 30, 20, 'record_transactions', 3, 'medium'),
('Gunakan AI Chat', 'Tanyakan sesuatu ke AI chatbot', 'daily', 'tracking', 15, 15, 'use_chatbot', 1, 'easy'),
('Review Budget', 'Cek status budget harian/mingguanmu', 'daily', 'saving', 10, 10, 'check_budget', 1, 'easy'),

-- Weekly Missions
('Catat 20 Transaksi', 'Catat minimal 20 transaksi minggu ini', 'weekly', 'tracking', 100, 50, 'record_transactions', 20, 'medium'),
('Hemat 10%', 'Hemat minimal 10% dari pengeluaran minggu lalu', 'weekly', 'saving', 150, 100, 'save_percentage', 10, 'hard'),
('Pelajari Investasi', 'Selesaikan 1 kursus investasi', 'weekly', 'education', 100, 75, 'complete_course', 1, 'medium'),
('Trading Challenge', 'Lakukan 5 transaksi trading virtual', 'weekly', 'investment', 120, 80, 'virtual_trades', 5, 'medium'),

-- Monthly Missions
('Konsisten Sebulan', 'Catat transaksi setiap hari selama sebulan', 'monthly', 'tracking', 500, 300, 'daily_tracking_streak', 30, 'hard'),
('Profit Trading', 'Raih profit minimal 5% di virtual trading', 'monthly', 'investment', 300, 200, 'trading_profit', 5, 'hard'),
('Master Budget', 'Ikuti budget bulanan dengan ketat (< 5% selisih)', 'monthly', 'saving', 400, 250, 'budget_adherence', 95, 'hard');

-- ============================================
-- 4. INVESTMENT COURSES (Using External News API)
-- ============================================

-- Note: Course content will be fetched from external news API
-- Content field stores API configuration and filters
INSERT INTO public.courses (title, description, level, category, duration_minutes, xp_reward, content, order_index) VALUES
(
    'Berita Pasar Saham Terkini',
    'Update terbaru tentang pergerakan pasar saham Indonesia dan global',
    'beginner',
    'stocks',
    15,
    25,
    '{
        "api_source": "newsapi",
        "query": "saham OR bursa OR IHSG",
        "language": "id",
        "country": "id",
        "category": "business",
        "pageSize": 10
    }',
    1
),
(
    'Analisis & Tips Investasi',
    'Artikel dan analisis dari para ahli tentang strategi investasi',
    'beginner',
    'fundamental',
    20,
    30,
    '{
        "api_source": "newsapi",
        "query": "investasi OR reksadana OR obligasi OR portfolio",
        "language": "id",
        "country": "id",
        "category": "business",
        "pageSize": 10
    }',
    2
),
(
    'Ekonomi & Keuangan',
    'Berita ekonomi makro yang mempengaruhi keputusan investasi',
    'intermediate',
    'fundamental',
    20,
    35,
    '{
        "api_source": "newsapi",
        "query": "ekonomi OR inflasi OR BI rate OR rupiah",
        "language": "id",
        "country": "id",
        "category": "business",
        "pageSize": 10
    }',
    3
),
(
    'Cryptocurrency & Blockchain',
    'Update tentang crypto, blockchain, dan aset digital',
    'intermediate',
    'crypto',
    15,
    40,
    '{
        "api_source": "newsapi",
        "query": "cryptocurrency OR bitcoin OR blockchain OR crypto",
        "language": "en",
        "category": "technology",
        "pageSize": 10
    }',
    4
),
(
    'Fintech & Inovasi Keuangan',
    'Perkembangan terbaru di dunia teknologi finansial',
    'intermediate',
    'technology',
    15,
    35,
    '{
        "api_source": "newsapi",
        "query": "fintech OR digital banking OR payment technology",
        "language": "en",
        "category": "technology",
        "pageSize": 10
    }',
    5
);

-- ============================================
-- 5. INVESTMENT CHALLENGES
-- ============================================

INSERT INTO public.investment_challenges (title, description, type, target_value, duration_days, xp_reward, points_reward, difficulty) VALUES
('Diversifikasi Pemula', 'Miliki minimal 3 jenis aset berbeda di portfoliomu', 'diversification', 3, 30, 100, 50, 'easy'),
('Target Profit 5%', 'Raih profit 5% dari modal awal dalam 30 hari', 'profit_target', 5, 30, 200, 100, 'medium'),
('Target Profit 10%', 'Raih profit 10% dari modal awal dalam 60 hari', 'profit_target', 10, 60, 500, 250, 'hard'),
('Trader Aktif', 'Lakukan minimal 20 transaksi trading dalam sebulan', 'trading_frequency', 20, 30, 150, 75, 'medium'),
('Portfolio Seimbang', 'Jaga agar tidak ada aset yang lebih dari 40% total portfolio', 'risk_management', 40, 30, 200, 100, 'medium');

-- ============================================
-- SAMPLE DATA NOTE
-- ============================================
-- 
-- Data di atas adalah seed data untuk:
-- 1. Kategori default (income & expense)
-- 2. Badge/Achievement sistem gamifikasi
-- 3. Daily/Weekly/Monthly missions
-- 4. Investment courses (menggunakan external news API)
-- 5. Investment challenges
--
-- CATATAN PENTING:
-- - Course content akan di-fetch dari News API (newsapi.org)
-- - Chatbot menggunakan OpenRouter API (via Edge Function)
-- - OCR receipt processing menggunakan OpenRouter Vision API
--
-- User-specific data seperti transactions, budgets, chat messages, dll
-- akan dibuat saat pengguna menggunakan aplikasi.
--
-- Untuk testing, Anda bisa menambahkan sample user data di sini.
--
-- ============================================
