#!/bin/bash
set -e

NAMESPACE="kainatledger"
CONTEXT="ack-magnus"

echo "=== KainatLedger Deploy Script ==="
echo "Namespace: $NAMESPACE"
echo "Context: $CONTEXT"
echo ""

# 1. Create namespace
echo "[1/7] Creating namespace..."
kubectl apply -f deploy/k8s/namespace.yaml --context=$CONTEXT

# 2. Deploy Postgres
echo "[2/7] Deploying PostgreSQL..."
kubectl apply -f deploy/k8s/postgres.yaml --context=$CONTEXT
echo "Waiting for PostgreSQL to be ready..."
kubectl rollout status statefulset/postgres-kainatledger -n $NAMESPACE --context=$CONTEXT --timeout=120s

# 3. Apply ConfigMap and Secret
echo "[3/7] Applying ConfigMap and Secret..."
kubectl apply -f deploy/k8s/configmap.yaml --context=$CONTEXT
kubectl apply -f deploy/k8s/secret.yaml --context=$CONTEXT

# 4. Deploy backend
echo "[4/7] Deploying backend..."
kubectl apply -f deploy/k8s/deployment.yaml --context=$CONTEXT
kubectl apply -f deploy/k8s/service.yaml --context=$CONTEXT
kubectl apply -f deploy/k8s/ingress.yaml --context=$CONTEXT

# 5. Wipe all dummy data
echo "[5/7] Wiping all data (fresh database)..."
kubectl apply -f deploy/k8s/wipe-job.yaml --context=$CONTEXT
echo "Waiting for wipe job to complete..."
kubectl wait --for=condition=complete job/db-wipe -n $NAMESPACE --context=$CONTEXT --timeout=60s || echo "Wipe job skipped (schema may not exist yet)"

# 6. Run migrations
echo "[6/7] Running Alembic migrations..."
kubectl apply -f deploy/k8s/wipe-job.yaml --context=$CONTEXT
echo "Waiting for migration job to complete..."
kubectl wait --for=condition=complete job/alembic-migrate -n $NAMESPACE --context=$CONTEXT --timeout=120s

# 7. Verify deployment
echo "[7/7] Verifying deployment..."
kubectl rollout status deployment/kainatledger-backend -n $NAMESPACE --context=$CONTEXT --timeout=180s

echo ""
echo "=== Deployment Complete ==="
echo "Backend: https://kainatledger-api.vanapp.co.id"
echo "Health check: https://kainatledger-api.vanapp.co.id/health"
echo ""
echo "To check logs: kubectl logs -n $NAMESPACE -l app=kainatledger-backend --context=$CONTEXT -f"
echo "To check pods: kubectl get pods -n $NAMESPACE --context=$CONTEXT"
