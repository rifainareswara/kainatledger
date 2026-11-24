# KainatLedger Deployment Guide

Dokumentasi lengkap deploy KainatLedger ke ACK (Alibaba Cloud Kubernetes).

---

## 📋 Prerequisites

Pastikan Anda memiliki:

1. **Akses ke ACK Magnus**
   ```bash
   kubectl config use-context ack-magnus
   kubectl get nodes
   ```

2. **Docker & akses ke ACR magnus-registry**
   ```bash
   docker login magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com
   ```

3. **StorageClass di cluster** (untuk PVC Postgres)
   ```bash
   kubectl get storageclass
   ```
   Jika tidak ada, buat `StorageClass` dengan provisioner Alibaba Cloud Disk.

---

## 🏗️ Urutan Pembuatan File YAML

File YAML di `deploy/k8s/` dibuat dengan urutan dependensi sebagai berikut:

```
1. namespace.yaml          ← Buat namespace (tidak ada dependensi)
2. postgres.yaml           ← Deploy database (butuh namespace)
   ├─ pg-secret            ← Kredensial Postgres
   ├─ PVC postgres-data    ← Persistent storage
   └─ StatefulSet postgres ← Pod database
3. configmap.yaml          ← Environment config (butuh namespace)
4. secret.yaml             ← Secret backend (butuh namespace, DB URL)
5. deployment.yaml         ← Backend app (butuh ConfigMap + Secret)
6. service.yaml            ← ClusterIP service (butuh deployment)
7. ingress.yaml            ← External access (butuh service)
8. wipe-job.yaml           ← Job untuk wipe data + migrate (opsional)
```

**Mengapa urutan ini penting:**
- `namespace.yaml` harus dulu karena semua resource lain butuh namespace exist
- `postgres.yaml` sebelum backend karena backend butuh DB URL valid
- `configmap.yaml`/`secret.yaml` sebelum `deployment.yaml` karena dirujuk via `envFrom`
- `service.yaml` setelah deployment agar selector menemukan pod
- `ingress.yaml` terakhir karena merujuk ke service

---

## 🚀 Deploy Step-by-Step

### Step 1: Build dan Push Docker Image

```bash
cd /Users/rifai/code/kainatledger

# Build image
docker build -t magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com/kainatledger/kainatledger:latest ./backend

# Push ke ACR
docker push magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com/kainatledger/kainatledger:latest
```

### Step 2: Deploy PostgreSQL

```bash
kubectl apply -f deploy/k8s/namespace.yaml
kubectl apply -f deploy/k8s/postgres.yaml

# Tunggu sampai ready
kubectl rollout status statefulset/postgres-kainatledger -n kainatledger --timeout=300s
```

**Troubleshoot PVC Pending:**
```bash
# Cek event PVC
kubectl describe pvc postgres-data -n kainatledger

# Cek StorageClass tersedia
kubectl get storageclass

# Jika tidak ada StorageClass, buat:
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: alicloud-disk-ssd
provisioner: disk.csi.alibabacloud.com
parameters:
  type: cloud_ssd
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
EOF
```

### Step 3: Deploy Backend

```bash
kubectl apply -f deploy/k8s/configmap.yaml
kubectl apply -f deploy/k8s/secret.yaml
kubectl apply -f deploy/k8s/deployment.yaml
kubectl apply -f deploy/k8s/service.yaml
kubectl apply -f deploy/k8s/ingress.yaml
```

### Step 4: Wipe Data & Migrate

```bash
# Hapus semua data (DROP SCHEMA CASCADE)
kubectl apply -f deploy/k8s/wipe-job.yaml

# Tunggu job selesai
kubectl wait --for=condition=complete job/db-wipe -n kainatledger --timeout=60s

# Jalankan Alembic migrations
kubectl apply -f deploy/k8s/wipe-job.yaml
kubectl wait --for=condition=complete job/alembic-migrate -n kainatledger --timeout=120s
```

### Step 5: Verifikasi

```bash
# Cek pods
kubectl get pods -n kainatledger

# Cek logs backend
kubectl logs -n kainatledger -l app=kainatledger-backend -f

# Test health endpoint
kubectl port-forward svc/kainatledger-service 8000:8000 -n kainatledger
curl http://localhost:8000/health
```

---

## 📱 Build APK Flutter

### Lokasi Hasil Build

```
/Users/rifai/code/kainatledger/mobile/build/app/outputs/flutter-apk/app-release.apk
```

Ukuran: ~57 MB

### Build Ulang (jika perlu)

```bash
cd /Users/rifai/code/kainatledger/mobile

# Clean build
flutter clean

# Build release APK
flutter build apk --release
```

### Install ke Device Android

```bash
# Via ADB
adb install -r /Users/rifai/code/kainatledger/mobile/build/app/outputs/flutter-apk/app-release.apk

# Atau transfer manual ke device dan install
```

---

## 🔗 Koneksi Mobile → Backend

APK sudah dikonfigurasi untuk terhubung ke:

```
https://kainatledger-api.vanapp.co.id/api/v1
```

**File konfigurasi:** [`mobile/lib/core/constants/api_constants.dart`](../../mobile/lib/core/constants/api_constants.dart)

Jika ingin ganti backend URL, edit file tersebut:

```dart
String get baseUrl {
  return 'https://kainatledger-api.vanapp.co.id/api/v1';
}
```

Lalu build ulang APK.

---

## 🧹 Wipe Data Dummy

Untuk menghapus semua data dari database production:

### Metode 1: Via Kubernetes Job (Recommended)

```bash
kubectl apply -f deploy/k8s/wipe-job.yaml
kubectl wait --for=condition=complete job/db-wipe -n kainatledger --timeout=60s
kubectl apply -f deploy/k8s/wipe-job.yaml  # alembic-migrate
kubectl wait --for=condition=complete job/alembic-migrate -n kainatledger --timeout=120s
```

### Metode 2: Manual via psql

```bash
kubectl run pg-wipe --rm -i --restart=Never -n kainatledger \
  --image=postgres:16-alpine \
  --env="PGPASSWORD=kainat_secure_password" \
  -- psql -h postgres-kainatledger -U kainat -d kainatledger -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Lalu migrate ulang
kubectl run alembic --rm -i --restart=Never -n kainatledger \
  --image=magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com/kainatledger:latest \
  -- alembic upgrade head
```

---

## 🔍 Troubleshooting

### Pod Postgres Pending

```bash
kubectl describe pvc postgres-data -n kainatledger
kubectl get storageclass
```

### ImagePullBackOff

```bash
# Pastikan sudah login ACR
docker login magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com

# Cek imagePullSecrets (jika diperlukan)
kubectl get secret regcred -n kainatledger
```

### Backend tidak bisa connect ke Postgres

```bash
# Cek DATABASE_URL di secret
kubectl get secret kainatledger-secret -n kainatledger -o jsonpath='{.data.DATABASE_URL}' | base64 -d

# Format: postgresql+asyncpg://user:pass@postgres:5432/dbname
```

### Ingress tidak dapat IP

```bash
kubectl get ingress -n kainatledger
kubectl describe ingress kainatledger-ingress -n kainatledger

# Pastikan ingress controller running
kubectl get pods -n ingress-nginx
```

---

## 📁 Struktur File Deploy

```
deploy/
├── README.md                 ← Dokumentasi ini
├── scripts/
│   ├── deploy.sh             ← One-command deploy
│   └── wipe-and-deploy.sh    ← Deploy + wipe (deprecated, gunakan k8s job)
└── k8s/
    ├── namespace.yaml        ← Namespace kainatledger
    ├── postgres.yaml         ← PostgreSQL StatefulSet + PVC + Service
    ├── configmap.yaml        ← Environment variables
    ├── secret.yaml           ← Secrets (SECRET_KEY, DATABASE_URL)
    ├── deployment.yaml       ← Backend Deployment
    ├── service.yaml          ← ClusterIP Service
    ├── ingress.yaml          ← Ingress (kainatledger-api.vanapp.co.id)
    └── wipe-job.yaml         ← Jobs untuk wipe + migrate
```

---

## 🌐 Domain & TLS

Backend diakses via: **https://kainatledger-api.vanapp.co.id**

**TLS Configuration:**
- Gunakan Cloudflare Flexible SSL (TLS di Cloudflare, HTTP ke cluster)
- DNS record: `kainatledger-api.vanapp.co.id` → IP Ingress/CLB

Jika butuh TLS di cluster:
```yaml
# Tambahkan ke ingress.yaml
spec:
  tls:
  - hosts:
    - kainatledger-api.vanapp.co.id
    secretName: kainatledger-tls
```

---

## 📊 Resource Allocation

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| Backend   | 500m        | 1000m     | 512Mi          | 1Gi          |
| Postgres  | -           | -         | -              | -            |

Ubah di [`deployment.yaml`](./k8s/deployment.yaml) jika perlu.

---

## 📞 Quick Commands

```bash
# Lihat semua resource di namespace
kubectl get all -n kainatledger

# Logs backend
kubectl logs -n kainatledger -l app=kainatledger-backend -f

# Exec ke pod postgres
kubectl exec -it postgres-kainatledger-0 -n kainatledger -- psql -U kainat -d kainatledger

# Restart backend
kubectl rollout restart deployment/kainatledger-backend -n kainatledger

# Scale backend
kubectl scale deployment/kainatledger-backend --replicas=3 -n kainatledger
```

---

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
