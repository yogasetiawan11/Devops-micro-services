# Gateway Configuration Analysis

## Overview

This document analyzes the Gateway API configuration in `Manifest/gateway/` for the boutique microservices project.

---

## Current State

| File                  | Resource     | Namespace |
|-----------------------|-------------|-----------|
| `Gateway-class.yaml` | GatewayClass | *(cluster-scoped)* |
| `gateway.yml`        | Gateway      | `dev`     |
| `routes.yaml`        | HTTPRoute    | `dev`     |

Backend services (`Manifest/backend/`): all in namespace **`boutique`**.

---

## Issues Found

### 1. BackendRefs Won't Resolve — Namespace Mismatch

Gateway and HTTPRoute are both in `dev` (`allowRoutes: Same` works). But all backend services are in `boutique`:

| Service        | Namespace  | Port |
|----------------|------------|------|
| gateway        | boutique   | 3001 |
| auth           | boutique   | 3002 |
| product        | boutique   | 3003 |
| order-service  | boutique   | 3004 |
| orders         | boutique   | 3005 |
| user           | boutique   | 3006 |

Kubernetes DNS cannot resolve services across namespaces by short name. Every `backendRef` in the HTTPRoute will fail with **500 errors**.

**Fix — Pick one:**

- **Option A:** Move Gateway + HTTPRoute to `boutique` namespace
- **Option B:** Add `namespace: boutique` to each `backendRef` in the HTTPRoute, and change `allowRoutes` to `from: All` on the Gateway
- **Option C:** Move the backend services to `dev`

### 2. Path Singular vs Plural Mismatch

The Express gateway (`src/index.ts`) proxies:

| HTTPRoute Path     | App Gateway Path | Issue              |
|--------------------|------------------|--------------------|
| `/api/auth`        | `/api/auth`      | OK                 |
| `/api/product`     | `/api/products`  | Singular vs plural |
| `/api/order-service`| `/api/orders`   | Different path     |
| `/api/orders`      | `/api/orders`    | OK                 |
| `/api/user`        | `/api/users`     | Singular vs plural |
| `/api/gateway`     | *(none)*         | No app route       |

- `/api/product` should be `/api/products`
- `/api/user` should be `/api/users`
- `/api/gateway` has no matching route in the Express app — unless this is intentional for direct gateway access, consider removing it

### 3. Two Order Services — Intentional

You confirmed `order-service` (3004) and `orders` (3005) are separate services. Both routes are valid.

---

## Summary

| Issue | Severity | Status |
|-------|----------|--------|
| Namespace mismatch (services in `boutique`, routes in `dev`) | **Critical** | Open |
| `/api/product` → should be `/api/products` | Medium | Open |
| `/api/user` → should be `/api/users` | Medium | Open |
| `/api/gateway` has no app route | Low | Open |
| Typo `/api/roduct` | **Critical** | Fixed |
| Gateway + HTTPRoute namespace alignment | **Critical** | Fixed |
