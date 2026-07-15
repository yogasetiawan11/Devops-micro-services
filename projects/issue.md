# Issue: Frontend Service Returning 403 Forbidden

## Symptom

All Docker containers are running (`docker ps` shows STATUS "Up"), but accessing the frontend at `http://localhost:3000` returns **403 Forbidden**.

## Root Cause

The `frontend` container runs `nginx:alpine` with a volume mount:

```yaml
volumes:
  - ./boutique-microservices/frontend/build:/usr/share/nginx/html
```

The `build/` directory was **empty** — the React app was never compiled. Nginx has no files to serve and returns 403 (`directory index of "/usr/share/nginx/html/" is forbidden`).

## Environment

| Service       | Container     | Port      | Status |
|---------------|---------------|-----------|--------|
| Frontend      | frontend      | 3000:80   | Up     |
| API Gateway   | gateway       | 3001:3001 | Up     |
| Auth          | auth          | 3002:3002 | Up     |
| Product       | product       | 3003:3003 | Up     |
| Order Service | order-service | 3004:3004 | Up     |
| Orders        | orders        | 3005:3005 | Up     |
| User          | user          | 3006:3006 | Up     |
| Grafana       | grafana-dev   | 3007:3000 | Up     |
| Prometheus    | prometheus-dev| 9090:9090 | Up     |
| PostgreSQL    | boutique_db   | 5432:5432 | Up     |

## Diagnosis Steps

1. `docker ps` — all containers running with correct port mappings.
2. `curl http://localhost:3000` — returned **403**.
3. `docker exec frontend ls /usr/share/nginx/html/` — directory was **empty**.
4. `docker logs frontend` — showed `directory index of "/usr/share/nginx/html/" is forbidden`.
5. Checked `docker-compose.yaml` — frontend volume-mounts `./boutique-microservices/frontend/build`, which was an empty directory created by Docker (owned by root).

## Fix

```bash
cd boutique-microservices/frontend
rm -rf build
npm install
npm run build
docker restart frontend
```

After restart, `curl http://localhost:3000` returns **200 OK**.

## Prevention

The `build/` directory should be populated before running `docker compose up`. Either:

- Run `npm run build` in the frontend directory before starting Docker, or
- Change `docker-compose.yaml` to build the frontend image from its Dockerfile instead of using a volume mount:

```yaml
frontend:
  build: ./boutique-microservices/frontend
  container_name: frontend
  ports:
    - "3000:80"
  networks:
    - boutique_networks
```

Note: the existing Dockerfile uses `serve` on port 3000, not nginx on port 80. It would need adjustment to match the current nginx-based setup.
