# Moneystock - Aplikasi Manajemen Keuangan

**Final Project - Teknologi Berkembang A - Kelompok 7**

Moneystock adalah aplikasi mobile manajemen keuangan pribadi yang dibangun dengan Flutter dan Supabase. Aplikasi ini membantu Anda melacak pemasukan, pengeluaran, dan mengelola keuangan dengan mudah.

## Fitur Utama

* 🎨 **UI Modern** dengan dukungan Dark/Light Mode
* 🔐 **Autentikasi** menggunakan Supabase Auth (Email/Password)
* 💰 **Cashflow Monitoring** - Track pemasukan dan pengeluaran
* 📊 **Dashboard** dengan visualisasi cashflow
* 👤 **Profile Management** dengan settings terintegrasi
* ⚡ **Skeleton Loading** untuk UX yang lebih baik
* 🏗️ **Clean Architecture** dengan separation of concerns
* 🔄 **State Management** menggunakan BLoC/Cubit
* 🎯 **Dependency Injection** dengan GetIt dan Injectable

## Tech Stack

- **Framework**: Flutter
- **Backend**: Supabase (PostgreSQL)
- **State Management**: flutter_bloc
- **Navigation**: go_router
- **DI**: get_it + injectable
- **Local Storage**: Hive
- **Fonts**: Google Fonts (Poppins)
- **Icons**: Font Awesome

## Prerequisites

Sebelum menjalankan aplikasi, pastikan Anda sudah menginstal:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi terbaru)
- [Dart SDK](https://dart.dev/get-dart) (biasanya sudah include dengan Flutter)
- Android Studio / VS Code dengan Flutter extension
- Device emulator atau physical device untuk testing

## Cara Run Aplikasi

### 1. Clone Repository

```bash
git clone https://github.com/ervinaanggraini/tekber-a-7-supabase.git
cd tekber-a-7-supabase/flutter_application
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

#### a. Buat Project Supabase
1. Kunjungi [Supabase](https://supabase.com/) dan buat project baru
2. Copy **Project URL** dan **API Key (anon public)** dari Settings > API

#### b. Konfigurasi Environment Variables
1. Copy file `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit file `.env` dan update dengan credentials Supabase Anda:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

**⚠️ PENTING**: File `.env` sudah ada di `.gitignore`, jangan commit ke Git!

#### c. Setup Database Schema
Jalankan migration SQL di Supabase SQL Editor (`supabase/migrations/20251127000001_initial_schema.sql`):

```sql
-- Copy dan jalankan semua SQL di file migration
```

### 4. Generate Code (Dependency Injection)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run Aplikasi

#### Untuk Android:
```bash
flutter run
```

#### Untuk iOS:
```bash
flutter run -d ios
```

#### Untuk Web:
```bash
flutter run -d chrome
```

### 6. Hot Reload

Setelah aplikasi running, Anda bisa menggunakan:
- `r` untuk hot reload
- `R` untuk hot restart
- `q` untuk quit

## Struktur Project

```
lib/
├── core/                      # Core utilities & constants
│   ├── app/                   # App theme & config
│   ├── constants/             # Colors, spacings, URLs
│   ├── router/                # Navigation setup
│   └── widgets/               # Reusable widgets (skeleton, etc)
├── features/                  # Feature modules
│   ├── auth/                  # Authentication
│   ├── home/                  # Home dashboard
│   ├── profile/               # User profile & settings
│   ├── transactions/          # Transaction management
│   ├── theme_mode/            # Theme switching
│   └── onboarding/            # Welcome screen
└── dependency_injection.dart  # DI configuration
```

## Fitur yang Tersedia

### ✅ Sudah Implementasi
- [x] Authentication (Login/Register)
- [x] Home Dashboard dengan Cashflow
- [x] Profile Page dengan Settings
- [x] Dark/Light Mode Toggle
- [x] Skeleton Loading
- [x] Backend Integration dengan Supabase

### 🚧 Dalam Pengembangan
- [ ] Add Transaction Feature
- [ ] Transaction History
- [ ] Budget Management
- [ ] Analytics & Reports
- [ ] Export Data

## Troubleshooting

### Build Runner Error
Jika terjadi error saat generate code:
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Supabase Connection Error
- Pastikan URL dan API Key sudah benar
- Cek koneksi internet
- Pastikan Supabase project sudah running

### Flutter Version Error
Update Flutter ke versi terbaru:
```bash
flutter upgrade
```

## Kontribusi

Silakan berkontribusi dengan cara:
1. Fork repository ini
2. Buat branch baru (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## Tim Pengembang

**Kelompok 7 - Teknologi Berkembang A**

| Nama | NRP |
|------|-----|
| Batara Haryo Yudanto | 5026231008 |
| Azzahra Amalia Arfin | 5026231027 |
| Antika Raya | 5026231034 |
| Ervina Anggraini | 5026231042 |
| Batara Haryo Yudanto | 5026231008 |
| Nisrina Kamiliya Riswanto | 5026231111 |
| Realasa Femmi Novelika | 5026231113 |

## Credits

Project ini dibangun menggunakan boilerplate dari [Flutter & Supabase Mobile App Starter Template](https://github.com/mhadaily/flutter_supabase_starter) oleh [Majid Hajian](https://github.com/mhadaily)

## Lisensi

Project ini dibuat untuk keperluan akademik.
