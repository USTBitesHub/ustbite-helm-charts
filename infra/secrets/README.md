# Secrets

IMPORTANT: No secret values are stored in this repo.

## NAMESPACE ARCHITECTURE (Updated 2026-04-23)
Services run in:
  ustbite-frontend  → frontend
  ustbite-backend   → user, restaurant, order, payment, delivery, notification
  ustbite-ops       → ai-agent-service, log-aggregator, metrics-collector
  ustbite-data      → ALL postgres databases, redis, rabbitmq

## DATABASE_URL FORMAT (Critical after namespace split)
Since services are in ustbite-backend/ops and databases are in ustbite-data,
the connection strings MUST use the FULL cluster DNS:

  postgresql+asyncpg://USER:PASS@SERVICE_NAME.ustbite-data.svc.cluster.local:5432/DB_NAME

Do NOT use the short form (e.g., just "service-name:5432") — it will only
resolve within the same namespace.

## Creating Application Secrets (per backend service)
Run these MANUALLY in your terminal before deploying.

### user-service
kubectl create secret generic ustbite-user-service-secret \
  --namespace ustbite-backend \
  --from-literal=DATABASE_URL="postgresql+asyncpg://ustbite_user:PASS@ustbite-user-service-postgres.ustbite-data.svc.cluster.local:5432/ustbite_users_db" \
  --from-literal=REDIS_URL="redis://ustbite-redis.ustbite-data.svc.cluster.local:6379" \
  --from-literal=RABBITMQ_URL="amqp://user:PASS@ustbite-rabbitmq.ustbite-data.svc.cluster.local:5672/"

### restaurant-service
kubectl create secret generic ustbite-restaurant-service-secret \
  --namespace ustbite-backend \
  --from-literal=DATABASE_URL="postgresql+asyncpg://ustbite_user:PASS@ustbite-restaurant-service-postgres.ustbite-data.svc.cluster.local:5432/ustbite_restaurants_db" \
  --from-literal=REDIS_URL="redis://ustbite-redis.ustbite-data.svc.cluster.local:6379" \
  --from-literal=RABBITMQ_URL="amqp://user:PASS@ustbite-rabbitmq.ustbite-data.svc.cluster.local:5672/"

### order-service
kubectl create secret generic ustbite-order-service-secret \
  --namespace ustbite-backend \
  --from-literal=DATABASE_URL="postgresql+asyncpg://ustbite_user:PASS@ustbite-order-service-postgres.ustbite-data.svc.cluster.local:5432/ustbite_orders_db" \
  --from-literal=REDIS_URL="redis://ustbite-redis.ustbite-data.svc.cluster.local:6379" \
  --from-literal=RABBITMQ_URL="amqp://user:PASS@ustbite-rabbitmq.ustbite-data.svc.cluster.local:5672/"

### payment-service
kubectl create secret generic ustbite-payment-service-secret \
  --namespace ustbite-backend \
  --from-literal=DATABASE_URL="postgresql+asyncpg://ustbite_user:PASS@ustbite-payment-service-postgres.ustbite-data.svc.cluster.local:5432/ustbite_payments_db" \
  --from-literal=REDIS_URL="redis://ustbite-redis.ustbite-data.svc.cluster.local:6379" \
  --from-literal=RABBITMQ_URL="amqp://user:PASS@ustbite-rabbitmq.ustbite-data.svc.cluster.local:5672/" \
  --from-literal=RAZORPAY_KEY_ID="rzp_test_..." \
  --from-literal=RAZORPAY_KEY_SECRET="..."

### delivery-service
kubectl create secret generic ustbite-delivery-service-secret \
  --namespace ustbite-backend \
  --from-literal=DATABASE_URL="postgresql+asyncpg://ustbite_user:PASS@ustbite-delivery-service-postgres.ustbite-data.svc.cluster.local:5432/ustbite_delivery_db" \
  --from-literal=REDIS_URL="redis://ustbite-redis.ustbite-data.svc.cluster.local:6379" \
  --from-literal=RABBITMQ_URL="amqp://user:PASS@ustbite-rabbitmq.ustbite-data.svc.cluster.local:5672/"

### notification-service
kubectl create secret generic ustbite-notification-service-secret \
  --namespace ustbite-backend \
  --from-literal=DATABASE_URL="" \
  --from-literal=REDIS_URL="redis://ustbite-redis.ustbite-data.svc.cluster.local:6379" \
  --from-literal=RABBITMQ_URL="amqp://user:PASS@ustbite-rabbitmq.ustbite-data.svc.cluster.local:5672/" \
  --from-literal=SENDGRID_API_KEY="SG...."

### ai-agent-service
kubectl create secret generic ustbite-ai-agent-service-secret \
  --namespace ustbite-ops \
  --from-literal=DATABASE_URL="postgresql+asyncpg://ustbite_user:PASS@ustbite-ai-agent-service-postgres.ustbite-data.svc.cluster.local:5432/ustbite_aiagent_db" \
  --from-literal=REDIS_URL="redis://ustbite-redis.ustbite-data.svc.cluster.local:6379" \
  --from-literal=RABBITMQ_URL="amqp://user:PASS@ustbite-rabbitmq.ustbite-data.svc.cluster.local:5672/" \
  --from-literal=AI_API_KEY="sk-..."

## Creating Database Secrets (per postgres StatefulSet)
Each postgres instance needs its own credentials secret in ustbite-data:

kubectl create secret generic ustbite-user-service-postgres-secret \
  --namespace ustbite-data \
  --from-literal=POSTGRES_USER="ustbite_user" \
  --from-literal=POSTGRES_PASSWORD="<strong-password>"

# Repeat for: restaurant, order, payment, delivery, ai-agent-service postgres

## NEVER
- Never commit real credentials to Git
- Never use kubectl apply -f with files containing real secret values
- Never use short-form hostnames in DATABASE_URL (always use FQDN with .svc.cluster.local)
