# DevOps Pipeline Demo API

Simple Express API built with TypeScript to practice AWS DevOps pipeline concepts with Docker, Terraform, and Kubernetes.

## Available routes

| Route       | Method | Description               |
|-------------|--------|---------------------------|
| `/health`   | GET    | Returns `{ status: "ok" }` |
| `/hello`    | GET    | Responds with `Hello from EKS!` |
| `/users`    | GET    | Returns a dummy list of users |

## Local development

```bash
cd app
npm install
npm run dev
```

The server listens on `http://localhost:8080` by default. Override using `PORT`.

### Testing

```
npm test
```

### Production build

```
npm run build
npm start
```

## Docker usage

```
docker build -t devops-demo-api .
docker run -p 8080:8080 devops-demo-api
```

A Docker health check continuously pings `/health` to keep containers supervised.
