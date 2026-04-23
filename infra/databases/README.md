# USTBite Database Infrastructure

Each microservice has its own completely isolated
PostgreSQL StatefulSet. No service shares a database
with any other service.

All databases live in the **ustbite-data** namespace,
fully isolated from the application namespaces.

## Database Isolation Map

| Service | StatefulSet | Database | Namespace |
|---------|-------------|----------|-----------|
| user-service | ustbite-user-service-postgres | ustbite_users_db | ustbite-data |
| restaurant-service | ustbite-restaurant-service-postgres | ustbite_restaurants_db | ustbite-data |
| order-service | ustbite-order-service-postgres | ustbite_orders_db | ustbite-data |
| payment-service | ustbite-payment-service-postgres | ustbite_payments_db | ustbite-data |
| delivery-service | ustbite-delivery-service-postgres | ustbite_delivery_db | ustbite-data |
| ai-agent-service | ustbite-ai-agent-service-postgres | ustbite_incidents_db | ustbite-data |

## Deploying All Databases

```bash
kubectl apply -f ustbite-infra/namespaces/all-namespaces.yaml
kubectl apply -f ustbite-infra/databases/user-service-postgres/
kubectl apply -f ustbite-infra/databases/restaurant-service-postgres/
kubectl apply -f ustbite-infra/databases/order-service-postgres/
kubectl apply -f ustbite-infra/databases/payment-service-postgres/
kubectl apply -f ustbite-infra/databases/delivery-service-postgres/
kubectl apply -f ustbite-infra/databases/ai-agent-service-postgres/
```

## Creating Secrets (do this before applying StatefulSets)

Each postgres instance needs credentials in the **ustbite-data** namespace:

```bash
kubectl create secret generic ustbite-user-service-postgres-secret \
  --namespace ustbite-data \
  --from-literal=POSTGRES_USER="ustbite_user" \
  --from-literal=POSTGRES_PASSWORD="<strong-password>"
```

Repeat for each service: restaurant, order, payment, delivery, ai-agent-service.

## Important: Cross-Namespace Connection Strings

Since apps run in ustbite-backend/ops and databases in ustbite-data,
connection strings MUST use the full FQDN:

```
postgresql+asyncpg://USER:PASS@SERVICE-NAME.ustbite-data.svc.cluster.local:5432/DB
```

See ustbite-infra/secrets/README.md for complete per-service connection strings.

Never store real passwords in this repository.
