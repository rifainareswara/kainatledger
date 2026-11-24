#!/bin/bash
set -e

NAMESPACE="kainatledger"
CONTEXT="ack-magnus"

echo "=== KainatLedger Deploy Script ==="
echo "Namespace: $NAMESPACE"
echo "Context: $CONTEXT"
echo ""

# 1. Create namespace
echo "[1/6] Creating namespace..."
kubectl apply -f deploy/k8s/namespace.yaml --context=$CONTEXT

# 2. Deploy Postgres
echo "[2/6] Deploying PostgreSQL..."
kubectl apply -f deploy/k8s/postgres.yaml --context=$CONTEXT
echo "Waiting for PostgreSQL to be ready..."
kubectl rollout status statefulset/postgres -n $NAMESPACE --context=$CONTEXT --timeout=120s

# 3. Apply ConfigMap and Secret
echo "[3/6] Applying ConfigMap and Secret..."
kubectl apply -f deploy/k8s/configmap.yaml --context=$CONTEXT
kubectl apply -f deploy/k8s/secret.yaml --context=$CONTEXT

# 4. Deploy backend
echo "[4/6] Deploying backend..."
kubectl apply -f deploy/k8s/deployment.yaml --context=$CONTEXT
kubectl apply -f deploy/k8s/service.yaml --context=$CONTEXT
kubectl apply -f deploy/k8s/ingress.yaml --context=$CONTEXT

# 5. Wipe all dummy data (drop and recreate all tables)
echo "[5/6] Wiping all data (fresh database)..."
kubectl run pg-wipe --rm -i --restart=Never -n $NAMESPACE --context=$CONTEXT \
  --image=postgres:16-alpine \
  --env="PGPASSWORD=kainat_secure_password" \
  -- psql -h postgres -U kainat -d kainatledger -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" || true

# Re-run migrations to recreate tables
echo "Running Alembic migrations..."
kubectl run alembic-migrate --rm -i --restart=Never -n $NAMESPACE --context=$CONTEXT \
  --image=magnus-registry-registry.ap-southeast-5.cr.aliyuncs.com/kainatledger:latest \
  --env="DATABASE_URL=postgresql+asyncpg://kainat:kainat_secure_password@postgres:5432/kainatledger" \
  -- alembic upgrade head || true

# 6. Verify deployment
echo "[6/6] Verifying deployment..."
kubectl rollout status deployment/kainatledger-backend -n $NAMESPACE --context=$CONTEXT --timeout=180s

echo ""
echo "=== Deployment Complete ==="
echo "Backend: https://kainatledger-api.vanapp.co.id"
echo "Health check: https://kainatledger-api.vanapp.co.id/health"
echo ""
echo "To check logs: kubectl logs -n $NAMESPACE -l app=kainatledger-backend --context=$CONTEXT -f"
echo "To check pods: kubectl get pods -n $NAMESPACE --context=$CONTEXT"
