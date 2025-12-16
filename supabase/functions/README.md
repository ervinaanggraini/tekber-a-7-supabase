# Supabase Edge Functions

Edge Functions untuk MoneyStocks menggunakan Deno runtime.

## 📁 Structure

```
functions/
├── ai-chat/          # AI Chatbot dengan OpenRouter
├── ocr-receipt/      # OCR struk belanja
├── fetch-news/       # Fetch berita investasi
├── deno.json         # Deno configuration
└── .vscode/          # VS Code Deno settings
```

## 🛠️ Setup

### Install Deno Extension

VS Code akan otomatis merekomendasikan extension **Deno for VS Code**.

Atau install manual:
1. Buka Extensions (Ctrl+Shift+X)
2. Cari "Deno"
3. Install extension dari Deno Land

### Reload VS Code

Setelah install extension, reload VS Code:
- Tekan `Ctrl+Shift+P`
- Ketik "Reload Window"
- Enter

Error TypeScript akan hilang! ✅

## 🚀 Deploy

```bash
# Deploy semua functions
supabase functions deploy

# Atau satu per satu
supabase functions deploy ai-chat
supabase functions deploy ocr-receipt
supabase functions deploy fetch-news
```

## 🧪 Test Locally

```bash
# Start local functions
supabase functions serve ai-chat

# Test dengan curl
curl -i --location --request POST 'http://localhost:54321/functions/v1/ai-chat' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"conversation_id":"xxx","message":"Halo!"}'
```

## 📝 Environment Variables

Set di Supabase Dashboard → Settings → Edge Functions → Secrets:

```bash
OPENROUTER_API_KEY=sk-or-v1-xxxxx
NEWS_API_KEY=xxxxx
```

## ⚠️ Catatan Penting

**Error TypeScript di VS Code itu NORMAL** jika belum install Deno extension.

File-file ini menggunakan Deno runtime (bukan Node.js), jadi VS Code perlu extension khusus untuk mengenali:
- `Deno.env.get()` → Deno environment variables
- URL imports → Deno module system
- `serve()` → Deno HTTP server

Setelah install Deno extension, semua error akan hilang! 🎉

## 📚 Resources

- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [Deno Manual](https://deno.land/manual)
- [OpenRouter API](https://openrouter.ai/docs)
- [News API](https://newsapi.org/docs)
