# Gateway Configuration Analysis

## Overview

This document analyzes the Gateway API configuration in `Manifest/gateway/` and identifies issues with the route setup for the boutique microservices project.

---

## Critical Issues

### 1. Namespace Mismatch Between HTTPRoute and Backend Services

`routes.yaml:5` — the HTTPRoute is declared in namespace `dev`:

```yaml
metadata:
  name: microservices-routes
  namespace: dev
```

However, **every backend service** in `Manifest/backend/` is deployed in the `boutique` namespace:

| Service        | Namespace  |
|----------------|------------|
| gateway        | boutique   |
| auth           | boutique   |
| product        | boutique   |
| order-service  | boutique   |
| orders         | boutique   |
| user           | boutique   |

Since the HTTPRoute lives in `dev` but the backend services live in `boutique`, Envoy Gateway will **fail to resolve the backendRefs**. The services `gateway`, `auth`, `product`, `order-service`, `orders`, and `user` do not exist in the `dev` namespace.

### 2. Gateway `allowRoutes` Policy Blocks Cross-Namespace Routes

`gateway.yml:11-13` — the Gateway listener restricts route access:

```yaml
allowRoutes:
  namespace:
    from: Same
```

This means the Gateway will **only accept HTTPRoutes from the same namespace** it resides in. The Gateway has no `namespace` field set, so it will inherit whatever namespace it is applied to (likely `boutique` based on the Kustomize overlays). Since the HTTPRoute is in `dev`, the Gateway will **reject the route attachment**.

### 3. Gateway Missing Namespace Declaration

`gateway.yml` — the Gateway resource has no `namespace` field:

```yaml
metadata:
  name: gateway-boutique
  # namespace: ???
```

This should explicitly declare `namespace: boutique` to match the services and avoid ambiguity during deployment.

### 4. Path Names Do Not Match Application Routes

The HTTPRoute paths in `routes.yaml` do not align with the app-level gateway proxy routes defined in `src/index.ts`:

| HTTPRoute Path (`routes.yaml`) | App Gateway Path (`src/index.ts`) | Match? |
|-------------------------------|-----------------------------------|--------|
| `/gateway`                    | *(none)*                          | No     |
| `/auth`                       | `/api/auth`                       | No     |
| `/product`                    | `/api/products`                   | No (singular vs plural) |
| `/order-service`              | `/api/orders`                     | No     |
| `/orders`                     | `/api/orders`                     | No (duplicate target) |
| `/user`                       | `/api/users`                      | No (singular vs plural) |

If the goal is to route traffic through the app-level gateway service (port 3001), a single `/api` prefix rule pointing to the `gateway` service would suffice. If the goal is to bypass the app gateway and hit services directly, the paths still need to match what clients actually call.

### 5. Duplicate/Conflicting Order Routes

`routes.yaml:38-49` — two separate routes both target order-related services:

- `/order-service` → `order-service:3004`
- `/orders` → `orders:3005`

These are two distinct services. If only one is intended to handle order traffic, the other is dead configuration that could cause confusion.

---

## Helm Chart Route Mismatch (`charts/dev-manifest/`)

The Helm chart `values.yaml:79-112` has additional issues:

- **Disabled by default**: `httpRoute.enabled: false`
- **Wrong path**: Only rule matches `/headers` — not a real application path
- **Placeholder hostname**: `chart-example.local`
- **Wrong parent ref**: References Gateway named `gateway` — no such resource exists (the actual Gateway is `gateway-boutique`)
- **Missing namespace in parentRef**: No namespace specified, so it defaults to the release namespace

---

## Recommended Fix

### A. Fix the namespace in `routes.yaml`

Change the HTTPRoute namespace to `boutique` to match the backend services:

```yaml
metadata:
  name: microservices-routes
  namespace: boutique
```

### B. Add namespace to `gateway.yml`

```yaml
metadata:
  name: gateway-boutique
  namespace: boutique
```

### C. Align HTTPRoute paths with application routes

Either:
- Route everything through the app gateway: single rule with `/api` prefix → `gateway:3001`
- Or fix individual paths to use `/api/` prefix and correct pluralization (`/api/auth`, `/api/products`, `/api/orders`, `/api/users`)

### D. Resolve the two order services

Determine whether `order-service` (3004) and `orders` (3005) are both needed, and remove the unused one from `routes.yaml`.

### E. Update Helm chart values

Fix `parentRefs` to reference `gateway-boutique` in namespace `boutique`, and update path rules to match actual application routes.
