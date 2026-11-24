# KainatLedger — Project Summary

Personal Finance Tracker multi-platform (Mobile Android + Web).

---

## 📦 Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | FastAPI + SQLModel + PostgreSQL + Alembic |
| Mobile | Flutter + Riverpod + GoRouter |
| Web | Flutter Web (responsive) |
| Database | PostgreSQL 16 |
| Deployment | Docker + ACK (Alibaba Cloud Kubernetes) |
| Registry | ACR magnus-registry |

---

## 📁 Struktur Project

```
kainatledger/
├── backend/                    # FastAPI backend
│   ├── app/
│   │   ├── core/               # Config, security, exceptions
│   │   ├── db/                 # Session, base models
│   │   ├── models/             # SQLModel (User, Wallet, Transaction, ...)
│   │   ├── schemas/            # Pydantic schemas
│   │   ├── services/           # Business logic
│   │   ├── routers/            # API endpoints
│   │   └── main.py             # FastAPI app
│   ├── alembic/                # Database migrations
│   ├── tests/                  # Pytest tests
│   ├── Dockerfile
│   └── pyproject.toml
│
├── mobile/                     # Flutter app (Android + Web)
│   ├── lib/
│   │   ├── core/               # Constants, errors, utils, network
│   │   ├── domain/             # Entities, repositories
│   │   ├── data/               # Models, datasources, repos impl
│   │   ├── presentation/       # Providers (Riverpod), pages, widgets
│   │   └── main.dart
│   ├── test/                   # Unit + widget tests
│   └── pubspec.yaml
│
├── deploy/                     # Deployment manifests
│   ├── README.md               # Deploy guide (lengkap)
│   ├── scripts/
│   │   └── deploy.sh           # One-command deploy
│   └── k8s/
│       ├── namespace.yaml
│       ├── postgres.yaml
│       ├── configmap.yaml
│       ├── secret.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       └── wipe-job.yaml
│
├── docker-compose.yml          # Local dev
├── docker-compose.prod.yml     # Production (docker)
├── nginx.conf                  # Nginx reverse proxy
└── ROADMAP.md                  # Project roadmap
```

---

## 🚀 Quick Start

### Local Development

```bash
# Start PostgreSQL
docker compose up -d db

# Setup backend
cd backend
cp .env.example .env
alembic upgrade head
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Run mobile
cd mobile
flutter run
```

### Production Deploy (ACK)

Lihat [`deploy/README.md`](./deploy/README.md) untuk panduan lengkap.

```bash
# 1. Build & push image
docker build -t magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com/kainatledger:latest ./backend
docker push magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com/kainatledger:latest

# 2. Deploy ke ACK
./deploy/scripts/deploy.sh
```

---

## 📱 APK Location

**Release APK:** `/Users/rifai/code/kainatledger/mobile/build/app/outputs/flutter-apk/app-release.apk`

Ukuran: ~57 MB

Install:
```bash
adb install -r mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 API Endpoints

Base URL: `https://kainatledger-api.vanapp.co.id/api/v1`

| Endpoint | Method | Auth |
|----------|--------|------|
| `/auth/register` | POST | ❌ |
| `/auth/login` | POST | ❌ |
| `/auth/refresh` | POST | ✅ |
| `/auth/logout` | POST | ✅ |
| `/categories` | GET/POST/PUT/DELETE | ✅ |
| `/wallets` | GET/POST/PUT/DELETE | ✅ |
| `/transactions` | GET/POST/PUT/DELETE | ✅ |
| `/transfers` | POST/DELETE | ✅ |
| `/reports/*` | GET | ✅ |

---

## 🧪 Testing

### Backend
```bash
cd backend
pytest
```

### Flutter
```bash
cd mobile
flutter test
flutter analyze
```

---

## 📊 Database Schema

| Table | Description |
|-------|-------------|
| `users` | User accounts |
| `refresh_tokens` | JWT refresh tokens (SHA-256 hashed) |
| `categories` | Income/expense categories |
| `wallets` | Multi-wallet (cash, bank, e-wallet, credit) |
| `transactions` | Income/expense records |
| `transfers` | Inter-wallet transfers (atomic: 2 transactions) |

---

## 🔐 Security Features

- JWT access token (15 menit) + refresh token (30 hari)
- Refresh token stored as SHA-256 hash
- Password hashing dengan bcrypt
- CORS configured
- Input validation (Pydantic v2)
- SQL injection prevented (SQLModel ORM)

---

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
