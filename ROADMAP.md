# KainatLedger — Project Roadmap

Aplikasi pencatat keuangan pribadi multi-platform (Mobile & Web).

**Stack:** FastAPI + PostgreSQL | Flutter Mobile + Riverpod | Flutter Web (responsif)

---

## Tahap 1 — Arsitektur & Desain Sistem ✅

**Output:** Desain di chat, disetujui sebelum coding dimulai.

- [x] Struktur folder Clean Architecture (backend, mobile, web)
- [x] Skema database relasional (ERD + SQLModel code)
- [x] Daftar endpoint REST API lengkap beserta payload request/response
- [x] Keputusan stack teknologi final

**Keputusan utama:**
- Transfer menghasilkan 2 transaksi atomik (expense + income) dengan `transfer_id` sebagai penanda
- Saldo dompet disimpan langsung di kolom `wallets.balance` (bukan dihitung dari agregat)
- Refresh token disimpan sebagai SHA-256 hash di DB, bukan plaintext
- Flutter Web dipilih untuk konsistensi codebase tunggal dengan mobile

---

## Tahap 2 — Backend FastAPI (Selesai) ✅

**Status:** Semua kode ditulis, migration dijalankan, server berjalan.

### Core
- [x] `app/core/config.py` — Settings via pydantic-settings + `.env`
- [x] `app/core/security.py` — JWT access token (15 menit) + opaque refresh token (SHA-256, 30 hari)
- [x] `app/core/exceptions.py` — 6 custom HTTP exceptions
- [x] `app/db/session.py` — AsyncEngine + AsyncSession factory
- [x] `app/db/base.py` — Import semua model untuk Alembic autogenerate

### Models (SQLModel)
- [x] `User` + `RefreshToken` — Auth dengan token rotation per sesi
- [x] `Category` — Pemasukan/pengeluaran dengan ikon & warna kustom
- [x] `Wallet` — Multi-dompet (cash, bank, e-wallet, credit card, investasi)
- [x] `Transaction` — Kolom `type` dan `date` pakai `sa_column` (hindari bentrok Python builtins)
- [x] `Transfer` — Atomik: 1 transfer = 2 transaksi otomatis

### Schemas (Pydantic v2)
- [x] `auth.py` — Register, Login, Token, Refresh
- [x] `category.py` — Create, Update, Response (dengan `transaction_count`)
- [x] `wallet.py` — Create, Update, Response, Summary
- [x] `transaction.py` — Create, Update, Response, ListResponse + CategoryBrief/WalletBrief
- [x] `transfer.py` — Create, Response + validasi `from != to` dan `fee >= 0`
- [x] `report.py` — Summary, Monthly, CategoryBreakdown, CashFlow

### Services (Business Logic)
- [x] `auth_service.py` — Register, Login, Refresh (token rotation), Logout, Logout-all
- [x] `category_service.py` — CRUD + block delete jika punya transaksi
- [x] `wallet_service.py` — CRUD + deactivate + summary total saldo
- [x] `transaction_service.py` — CRUD + filter multi-param + koreksi saldo otomatis
- [x] `transfer_service.py` — Create atomik + cancel (rollback saldo) + auto-kategori sistem
- [x] `report_service.py` — Summary, Monthly chart data, Category breakdown, Cash flow harian, Export CSV (UTF-8 BOM), Export Excel (openpyxl)

### API Routers
- [x] `POST/GET /api/v1/auth/*` — Register, Login, Refresh, Logout, Logout-all
- [x] `GET/POST/PUT/DELETE /api/v1/categories` — CRUD kategori
- [x] `GET/POST/PUT/DELETE /api/v1/wallets` — CRUD dompet + `/summary`
- [x] `GET/POST/PUT/DELETE /api/v1/transactions` — CRUD + 8 query parameter filter
- [x] `GET/POST/DELETE /api/v1/transfers` — Transfer antar-dompet
- [x] `GET /api/v1/reports/*` — Summary, Monthly, By-category, Cash-flow, Export CSV/Excel

### Infrastructure
- [x] `alembic/` — Migration awal semua 6 tabel dengan index lengkap
- [x] `pyproject.toml` — Python 3.12, semua dependensi
- [x] `.env.example` — Template konfigurasi
- [x] `Dockerfile` — Python 3.12 slim + uv
- [x] `docker-compose.yml` — PostgreSQL 16 (arm64) + backend service

### Bug Fixes Saat Running
- [x] `passlib` tidak kompatibel dengan `bcrypt 5.x` → diganti ke `bcrypt` langsung
- [x] SQLModel Enum field otomatis buat PG ENUM type yang tidak ada → semua diganti `sa_column` plain `String`
- [x] `redirect_slashes=False` di FastAPI untuk hindari 307 redirect pada route tanpa trailing slash
- [x] Field `type` dan `date` di model bentrok dengan Python builtins → rename ke `tx_type`/`tx_date` dengan `sa_column` mapping ke nama kolom asli

### Smoke Test Results ✅
| Endpoint | Status |
|----------|--------|
| `POST /auth/register` | ✅ 201 Created |
| `POST /auth/login` | ✅ 200 OK + access & refresh token |
| `POST /auth/refresh` | ✅ 200 OK + access token baru |
| `POST /categories` | ✅ 201 Created |
| `GET /categories` | ✅ 200 OK |
| `POST /wallets` | ✅ 201 Created + saldo awal |
| `GET /wallets/summary` | ✅ 200 OK + total saldo |
| `POST /transactions` (income) | ✅ 201 + saldo wallet naik |
| `POST /transactions` (expense) | ✅ 201 + saldo wallet turun |
| `GET /transactions` | ✅ 200 OK + pagination |
| `POST /transfers` | ✅ 201 + 2 tx atomik + saldo kedua wallet terupdate |
| `GET /reports/summary` | ✅ income/expense/net benar |
| `GET /reports/monthly` | ✅ data per bulan |
| `GET /reports/by-category` | ✅ breakdown + persentase |
| `GET /reports/export/csv` | ✅ CSV 205 bytes, UTF-8 BOM |
| `GET /reports/export/excel` | ✅ XLSX 5.2 KB |

---

## Tahap 3 — Flutter Mobile App (Selesai) ✅

**Status:** Selesai, Clean Architecture + Riverpod + GoRouter diimplementasikan, unit & widget test tersedia, analisis kode 100% bersih tanpa error/warning.

### Setup & Core
- [x] Project Flutter + setup pubspec.yaml (riverpod, dio, flutter_secure_storage, go_router, fl_chart, json_serializable)
- [x] `core/network/dio_client.dart` — Dio instance + interceptor JWT auto-refresh
- [x] `core/constants/` — API endpoints, app colors (`AppColors`)
- [x] `core/errors/` — Exceptions, Failures
- [x] `core/utils/` — Currency formatter (IDR), date formatter

### Domain Layer
- [x] Entities: `UserEntity`, `CategoryEntity`, `WalletEntity`, `TransactionEntity`, `TransferEntity`, `ReportEntity`
- [x] Repository interfaces (abstract): `AuthRepository`, `CategoryRepository`, `WalletRepository`, `TransactionRepository`, `TransferRepository`, `ReportRepository`

### Data Layer
- [x] Models JSON serializable (json_serializable + build_runner sukses generate `.g.dart`)
- [x] Remote datasources (Auth, Category, Wallet, Transaction, Transfer, Report)
- [x] Local datasource (`AuthLocalDataSource` via `flutter_secure_storage`)
- [x] Repository implementations (`AuthRepositoryImpl`, `CategoryRepositoryImpl`, `WalletRepositoryImpl`, `TransactionRepositoryImpl`, `TransferRepositoryImpl`, `ReportRepositoryImpl`)

### Presentation Layer (Riverpod Providers + Pages + Router)
- [x] **Router:** `GoRouter` dengan route protection auth redirect & bottom navigation shell
- [x] **Providers:** `authProvider`, `walletsProvider`, `walletActionsProvider`, `categoriesProvider`, `categoryActionsProvider`, `transactionsProvider`, `transactionActionsProvider`, `reportSummaryProvider`, `monthlyReportProvider`, `categoryReportProvider`
- [x] **Auth:** `LoginPage`, `RegisterPage`
- [x] **Dashboard:** `DashboardPage` (Total Saldo, Ringkasan Bulan Ini, Quick Actions, Preview Dompet, Transaksi Terakhir)
- [x] **Transactions:** `TransactionsPage` (filter chip pengeluaran/pemasukan, pencarian, dismissible delete), `TransactionFormPage` (catat pemasukan/pengeluaran)
- [x] **Wallets:** `WalletsPage` (grid dompet aktif, total saldo), `WalletFormPage` (buat dompet baru), `TransferFormPage` (transfer antar-dompet)
- [x] **Categories:** `CategoriesPage` (kelola kategori pemasukan & pengeluaran, color & icon picker)
- [x] **Reports:** `ReportsPage` (ringkasan arus kas, grafik tren batang tahunan `fl_chart`, pie chart distribusi kategori)
- [x] **Shared Widgets:** `MoneyText`, `CategoryChip`, `WalletCard`, `EmptyStateWidget`, `ErrorViewWidget`, `CustomButton`, `CustomTextField`

---

## Tahap 4 — Flutter Web (Responsive Dashboard) (Selesai) ✅

**Status:** Selesai, Web platform scaffolded, navigasi adaptif Mobile/Tablet/Desktop (Bottom Nav & NavigationRail), dashboard multi-kolom, tabel data transaksi desktop, dan fitur ekspor CSV & Excel via browser download. Build rilis web diverifikasi (`flutter build web --release` sukses).

### Layout System
- [x] `ResponsiveLayout` & `ResponsiveBreakpoints` (Mobile < 700px, Tablet 700-1100px, Desktop >= 1100px)
- [x] `MobileLayout` — bottom nav, single column feed
- [x] `TabletLayout` — collapsed side NavigationRail, responsive content
- [x] `DesktopLayout` — expanded side NavigationRail dengan brand mark & logout, multi-kolom dashboard (Saldo + Aksi Cepat berdampingan, Dompet + Transaksi berdampingan)

### Web-specific Features
- [x] Dashboard overview: ringkasan saldo, monthly income/expense preview, dan grafik
- [x] Tabel transaksi desktop: `DataTable` interaktif dengan filter tipe, pencarian, format rupiah, dan aksi hapus
- [x] Period picker bulan dan tahun untuk laporan analitik
- [x] Ekspor CSV (UTF-8 BOM) & Excel (.xlsx) via browser download (`FileDownloader`)
- [x] Multi-column report analysis: grafik batang arus kas tahunan & diagram pie distribusi kategori berdampingan

### Shared dengan Mobile
- [x] 100% codebase tunggal (single codebase) berbagi domain entities, models, datasources, repositories, dan Riverpod providers
- [x] Dio client + interceptor token auto-refresh adaptif untuk Web (`localhost`) & Mobile (`10.0.2.2`)

---

## Tahap 5 — Testing & Hardening (Selesai) ✅

### Backend Tests
- [x] `pytest` + `pytest-asyncio` + `httpx AsyncClient` + in-memory SQLite async engine
- [x] Unit test: `auth_service`, `transaction_service` (koreksi saldo otomatis), `transfer_service` (transfer atomik)
- [x] Integration test: register → login → create wallet → create transaction → check balance
- [x] Edge cases: unauthenticated access, invalid JWT token, transfer ke dompet yang sama, nominal negatif

### Flutter Tests
- [x] Unit tests: `currency_formatter` (format IDR standar & format ringkas compact), `date_formatter` (relative date & API format)
- [x] Widget tests: `MoneyText` dan `EmptyStateWidget` (action button interaction)
- [x] 100% test lulus (`7/7 passed`) dan `flutter analyze` bersih tanpa error

### Security Hardening
- [x] Tambah `RequestIDMiddleware` (`X-Request-ID` tracing header)
- [x] Perbaikan error response: header Authorization yang tidak ada / tidak valid mengembalikan status 401 Unauthorized yang konsisten (bukan 422)
- [x] Normalisasi penamaan wallet type (`e-wallet` vs `e_wallet`) untuk mencegah mismatch format

---

## Tahap 6 — Deployment (Selesai) ✅

### Backend & Infrastructure
- [x] `docker-compose.prod.yml` — PostgreSQL + Backend + Nginx reverse proxy
- [x] `nginx.conf` — Konfigurasi reverse proxy untuk API, caching statis, gzip compression, dan URL rewrite Flutter Web (`try_files`)
- [x] CI/CD Pipeline: GitHub Actions workflow (`.github/workflows/ci.yml`) menjalankan lint, pytest, dan build release Flutter Web otomatis

### Flutter Web & Mobile
- [x] Build web release terverifikasi: `flutter build web --release` sukses menghasilkan folder produksi `build/web`
- [x] PWA manifest & web icons terkonfigurasi di `mobile/web/`
- [x] Konfigurasi environment multi-platform (Android emulator, iOS simulator, macOS, dan browser web) otomatis tersinkronisasi via `api_constants.dart`

---

## Dependensi Antar Tahap

```
Tahap 1 ──► Tahap 2 ──► Tahap 3 ──► Tahap 5
                    └──► Tahap 4 ──► Tahap 5
                                         └──► Tahap 6
```

Tahap 3 dan 4 bisa dikerjakan paralel setelah Tahap 2 selesai.

---

## Cara Menjalankan (Development)

```bash
# 1. Start PostgreSQL
docker compose up -d db

# 2. Setup backend
cd backend
cp .env.example .env        # edit DATABASE_URL jika perlu
alembic upgrade head
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 3. API Docs (DEBUG=true)
open http://localhost:8000/docs
```
