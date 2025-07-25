# Supply Chain Management System (Food Industry)

This project is a full-stack, production-ready solution for supply chain management in the food industry. It features a secure Node.js/Express backend, a modern React frontend, PostgreSQL database, and is ready for cloud deployment with Docker and Kubernetes.

---

## Architecture Overview

```
[ React Frontend ] <--> [ Node.js API ] <--> [ PostgreSQL DB ]
         |                    |                |
         |                [Monitoring, Logging, Alerts]
         |                    |
      [Kubernetes, Docker, Ingress, CI/CD]
```

- **Frontend:** React (TypeScript, PWA, secure API calls, error boundaries)
- **Backend:** Node.js, Express, Prisma ORM, JWT auth, security best practices
- **Database:** PostgreSQL (schema managed by Prisma)
- **Deployment:** Docker, Kubernetes (manifests in `k8s/`), Ingress, resource limits
- **Monitoring:** Prometheus metrics, health endpoints, logging

---

## Local Development

### Prerequisites
- Node.js 18+ and npm
- Docker (for DB or full stack)
- PostgreSQL (local or Docker)

### 1. Clone and Install
```sh
git clone <repo-url>
cd <repo-root>
cd backend && npm install
cd ../frontend && npm install
```

### 2. Set Up Environment Variables
- Copy `.env.example` to `.env` in `backend/` and fill in DB, JWT, SMTP, etc.
- Example for backend:
  ```
  DATABASE_URL=postgresql://user:pass@localhost:5432/supplychain
  JWT_SECRET=your_jwt_secret
  SMTP_HOST=...
  ...
  ```
- For frontend, set `REACT_APP_API_URL` if backend is not on localhost:4000.

### 3. Run PostgreSQL (Docker example)
```sh
docker run --name supplychain-db -e POSTGRES_PASSWORD=pass -e POSTGRES_DB=supplychain -p 5432:5432 -d postgres:15
```

### 4. Run Backend
```sh
cd backend
npx prisma migrate dev --name init
npm start
```

### 5. Run Frontend
```sh
cd frontend
npm start
```

- Frontend: http://localhost:3000
- Backend API: http://localhost:4000/api/v1
- Swagger docs: http://localhost:4000/api-docs

---

## Docker Compose (Optional)
You can create a `docker-compose.yml` to run backend, frontend, and db together for local dev.

---

## Production Deployment (Cloud/Kubernetes)

### 1. Build and Push Docker Images
```sh
# Backend
cd backend
docker build -t your-docker-repo/backend:latest .
docker push your-docker-repo/backend:latest
# Frontend
cd ../frontend
docker build -t your-docker-repo/frontend:latest .
docker push your-docker-repo/frontend:latest
```

### 2. Set Up Kubernetes Secrets
- Store sensitive env vars (DB, JWT, SMTP) as Kubernetes secrets.
- Example:
  ```sh
  kubectl create secret generic backend-secrets --from-literal=DATABASE_URL=... --from-literal=JWT_SECRET=...
  ```

### 3. Deploy to Kubernetes
```sh
kubectl apply -f k8s/
```
- This will deploy backend, frontend, and Ingress.
- Update `your-domain.com` in `k8s/ingress.yaml` and DNS as needed.

### 4. Monitoring & Health
- `/api/v1/health` and `/api/v1/metrics` for health and Prometheus metrics.
- Use Prometheus/Grafana for cluster monitoring.

---

## Security & Best Practices
- All API endpoints are protected by JWT and role-based access.
- Rate limiting, CORS, and secure headers are enabled.
- Never commit secrets to git.
- Use HTTPS in production (Ingress/TLS).
- Regularly update dependencies and monitor for vulnerabilities.

---

## Documentation
- [backend/README.md](backend/README.md): Backend structure, API, security
- [frontend/README.md](frontend/README.md): Frontend structure, API usage
- [k8s/](k8s/): Kubernetes manifests

---

## CI/CD (Optional)
- Add a `.github/workflows/ci-cd.yml` for automated build, test, and deploy.
- Example steps: lint, test, build Docker, push, deploy to K8s.

---

## License
MIT (or your choice) 