# Task 2: Multi-Stage Docker Build

- Name: Jenil
- Enrollment No: 10323

---

## Steps Done

1. Created a multi-stage Dockerfile using `node:18-alpine`.
   - Stage 1 (build stage) installs app dependencies.
   - Stage 2 (production stage) copies the built server files and runs the lightweight app.

2. Built the multi-stage docker image:
   ```bash
   docker build -t multistage-app .
   ```

3. Started the container on port 8080:
   ```bash
   docker run -d --name multistage-container -p 8080:8080 multistage-app
   ```

---

## Outputs & Verification

### 1. App Output Check
```bash
curl http://localhost:8080
```
Output:
```text
Hello World from Docker multi-stage build
```

### 2. Docker PS Container Check (Port 8080)
```bash
docker ps
```
Output:
```text
CONTAINER ID   IMAGE                     COMMAND                  CREATED              STATUS                PORTS                                         NAMES
fe72a7919486   multistage-app            "docker-entrypoint.s…"   About a minute ago   Up About a minute     0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp   multistage-container
7eef9ffd1ddd   searchtypehead_frontend   "/docker-entrypoint.…"   2 months ago         Up 4 days             0.0.0.0:8081->80/tcp, [::]:8081->80/tcp       typeahead_frontend
18065d547dbf   postgres:15-alpine        "docker-entrypoint.s…"   2 months ago         Up 4 days (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp   typeahead_postgres
84e2fe1b93d5   redis:7-alpine            "docker-entrypoint.s…"   2 months ago         Up 4 days (healthy)   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp   typeahead_redis
```

---

## Screenshot

![Task 2 Screenshot](./screenshot.png)
