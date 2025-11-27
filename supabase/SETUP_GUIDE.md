# MoneyStocks - Supabase Setup Guide

## 🚀 Quick Start

### 1. Install Supabase CLI

```bash
# Windows (PowerShell)
scoop install supabase

# Or download from: https://github.com/supabase/cli/releases
```

### 2. Login to Supabase

```bash
supabase login
```

### 3. Link Project

```bash
# Di folder root project
cd C:\PERKULIAHAN\AKADEMIK\SEM7\tekber-a-7-supabase
supabase link --project-ref YOUR_PROJECT_REF

# Get project ref dari: https://supabase.com/dashboard/project/_/settings/general
```

### 4. Apply Database Schema

```bash
# Reset database (akan apply migration + seed data)
supabase db reset

# Atau apply migration saja
supabase migration up
```

### 5. Get API Keys

Buka Supabase Dashboard → Project Settings → API

Copy:
- `SUPABASE_URL`: https://xxxxx.supabase.co
- `SUPABASE_ANON_KEY`: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

### 6. Update Flutter Config

Edit `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://xxxxx.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

---

## 🔧 Setup External APIs

### OpenRouter (AI Chatbot & OCR)

1. Daftar: https://openrouter.ai/keys
2. Create API Key
3. Set di Supabase Dashboard → Settings → Edge Functions → Secrets:
   ```
   OPENROUTER_API_KEY=sk-or-v1-xxxxx
   ```

**Models yang dipakai:**
- Chatbot Pak Arief: `anthropic/claude-3.5-sonnet`
- Chatbot Dina: `openai/gpt-4-turbo`
- Chatbot Sarah: `google/gemini-pro-1.5`
- OCR Receipt: `google/gemini-pro-vision`

**Estimasi Biaya:**
- Claude 3.5 Sonnet: $3/1M input tokens
- GPT-4 Turbo: $10/1M input tokens
- Gemini Pro 1.5: $0.35/1M input tokens
- Gemini Vision: $0.25/1M input tokens

Untuk 1000 chat messages + 100 OCR scans ≈ **$1-2/bulan** 💰

### News API (Investment Courses)

1. Daftar: https://newsapi.org/register
2. Get API Key (Free: 100 requests/day)
3. Set di Supabase:
   ```
   NEWS_API_KEY=xxxxx
   ```

**Note:** Free tier cukup untuk development. Untuk production, upgrade ke Developer plan ($449/month untuk unlimited requests).

---

## 📦 Deploy Edge Functions

### ⚠️ Fix TypeScript Errors (Optional)

Jika ada error merah di VS Code pada file `.ts` di folder `functions/`:

1. **Install Deno Extension**:
   - Buka Extensions (Ctrl+Shift+X)
   - Cari "Deno"
   - Install extension dari Deno Land

2. **Reload VS Code**:
   - Tekan `Ctrl+Shift+P`
   - Ketik "Reload Window"
   - Enter

Error akan hilang! ✅ (Error itu normal karena Edge Functions pakai Deno, bukan Node.js)

### Deploy Functions

```bash
# Deploy semua sekaligus
supabase functions deploy

# Atau satu per satu
supabase functions deploy ai-chat
supabase functions deploy ocr-receipt
supabase functions deploy fetch-news
```

### Test Edge Functions

```bash
# Test AI Chat
supabase functions invoke ai-chat --data '{"conversation_id":"xxx","message":"Halo!"}'

# Test OCR
supabase functions invoke ocr-receipt --data '{"image_url":"https://...","user_id":"xxx"}'

# Test News
supabase functions invoke fetch-news --data '{"course_id":"xxx"}'
```

---

## 🗄️ Database Schema Overview

### Tables Created (20+):

1. **User Management**
   - `user_profiles` - Profile + gamification (level, XP, streak)
   - `user_settings` - User preferences

2. **Financial Tracking**
   - `categories` - Income/expense categories
   - `transactions` - All financial transactions
   - `budgets` - Budget planning & tracking

3. **AI Chatbot**
   - `chat_conversations` - Chat sessions with persona
   - `chat_messages` - All messages + intent detection

4. **Gamification**
   - `badges` - Achievement definitions
   - `user_badges` - User achievements
   - `missions` - Daily/weekly/monthly missions
   - `user_missions` - User mission progress

5. **Investment & Education**
   - `courses` - News-based courses
   - `user_course_progress` - Reading progress
   - `virtual_portfolios` - Virtual trading accounts
   - `virtual_positions` - Stock positions
   - `virtual_transactions` - Trading history
   - `investment_challenges` - Trading challenges
   - `user_investment_challenges` - Challenge progress

6. **AI Insights**
   - `financial_insights` - AI-generated insights
   - `spending_patterns` - Spending analysis

### Default Data (Seed):

- ✅ 22 categories (7 income, 15 expense)
- ✅ 20+ badges (common → legendary)
- ✅ 10+ missions (daily/weekly/monthly)
- ✅ 5 news-based courses
- ✅ 5 investment challenges

---

## 🔐 Security Setup

### Row Level Security (RLS)

Semua tabel sudah punya RLS policies:
- Users hanya bisa akses data mereka sendiri
- System data (categories, badges, missions) read-only untuk semua user

### Storage Buckets

Buat bucket untuk receipts:

```bash
# Via Supabase Dashboard: Storage → New Bucket
Bucket name: receipts
Public: Yes (biar image bisa di-fetch)
```

Set RLS policy untuk receipts bucket:

```sql
-- Allow users to upload their own receipts
CREATE POLICY "Users can upload own receipts"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to read own receipts
CREATE POLICY "Users can read own receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);
```

---

## 📱 Flutter Integration

### Install Package

```bash
cd flutter_application
flutter pub add supabase_flutter
```

### Initialize Supabase

Edit `lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
```

### Usage Examples

Lihat `API_INTEGRATION.md` untuk contoh lengkap:
- Authentication & Profile
- Categories & Transactions
- Budgets
- AI Chatbot (OpenRouter)
- OCR Receipt Scanning (OpenRouter Vision)
- Gamification (Badges, Missions, XP)
- Investment Courses (News API)
- Virtual Trading
- Financial Insights

---

## 🧪 Testing

### Local Development

```bash
# Start local Supabase
supabase start

# Apply migrations
supabase db reset

# Test Edge Functions locally
supabase functions serve ai-chat
```

### Sample Test Data

Tambahkan di `seed.sql`:

```sql
-- Test user (password: test123)
INSERT INTO auth.users (id, email, encrypted_password)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'test@example.com',
  crypt('test123', gen_salt('bf'))
);

-- User profile
INSERT INTO user_profiles (id, full_name, email)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Test User',
  'test@example.com'
);

-- Sample transactions
INSERT INTO transactions (user_id, category_id, type, amount, description)
SELECT 
  '00000000-0000-0000-0000-000000000001',
  id,
  'expense',
  50000,
  'Test transaction'
FROM categories 
WHERE name = 'Makanan & Minuman' 
LIMIT 1;
```

---

## 📊 Monitoring

### View Logs

```bash
# Edge Function logs
supabase functions logs ai-chat
supabase functions logs ocr-receipt
supabase functions logs fetch-news

# Database logs
supabase db logs
```

### Performance Tips

1. **Indexes sudah dibuat** untuk query umum (user_id, dates, status)
2. **Pagination**: Gunakan `.range(offset, limit)` untuk list besar
3. **Caching**: Cache categories, badges, missions di Flutter (jarang berubah)
4. **Batch Operations**: Gunakan `.insert([])` untuk multiple rows

---

## 🚨 Troubleshooting

### Error: "relation does not exist"
```bash
supabase db reset
```

### Error: "JWT expired"
```bash
supabase login
```

### Edge Function Error
```bash
# Check logs
supabase functions logs ai-chat --tail

# Redeploy
supabase functions deploy ai-chat
```

### RLS Policy Blocking
```sql
-- Disable RLS temporarily untuk testing
ALTER TABLE transactions DISABLE ROW LEVEL SECURITY;

-- Re-enable setelah fix
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
```

---

## 📚 Resources

- **Supabase Docs**: https://supabase.com/docs
- **OpenRouter Docs**: https://openrouter.ai/docs
- **News API Docs**: https://newsapi.org/docs
- **Flutter Supabase**: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter

---

## ✅ Checklist

- [ ] Install Supabase CLI
- [ ] Link project
- [ ] Apply migrations (`supabase db reset`)
- [ ] Get API keys (Supabase, OpenRouter, News API)
- [ ] Set environment variables
- [ ] Deploy Edge Functions
- [ ] Create storage bucket (receipts)
- [ ] Update Flutter config
- [ ] Test authentication
- [ ] Test Edge Functions
- [ ] Deploy to production

---

**Happy coding! 🎉**
