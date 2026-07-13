# Container Issues

## Issue 1: Gateway builds from wrong service directory

**File:** `projects/docker-compose.yaml:57`

The `gateway` service build context points to `./boutique-microservices/backend/services/auth` instead of `./boutique-microservices/backend/services/gateway`. This causes the gateway container to build and run the auth service code instead of the API gateway.

**Fix:** Change the context path to the gateway service directory.

## Issue 2: Gateway env var name mismatch for user service

**File:** `projects/boutique-microservices/backend/services/gateway/src/index.ts:24`

The code reads `USERS_SERVICE_URL` (plural) but docker-compose.yaml sets `USER_SERVICE_URL` (singular). The fallback port `3005` is also incorrect — it belongs to the orders service, while the user service runs on port `3006`.

**Fix:** Change to `process.env.USER_SERVICE_URL || 'http://user:3006'`.
