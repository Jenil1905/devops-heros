# Task 2: Multi-Stage Docker Build

- Name: Jenil
- Enrollment No: 10323

---

## Steps to Run Cloned Multi-Stage Repository

1. Navigate into the cloned repository:
   ```bash
   cd ~/Desktop/Devops-Practice/session6-7-docker/multi-stage-dockerfile
   ```

2. Build the Docker image from the multi-stage Dockerfile:
   ```bash
   docker build -t multi-stage-app .
   ```

3. Run the container mapping host port 8080 to container port 3000:
   ```bash
   docker run -d --name my-multistage-app -p 8080:3000 multi-stage-app
   ```

---

## Verification & Output

### 1. Web Output Check
Command:
```bash
curl http://localhost:8080
```
Output:
```html
<h1>Hello World from Docker Multi-Stage Build!</h1>
```

### 2. Docker PS Check (Port 8080)
Command:
```bash
docker ps
```
Output:
```text
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                         NAMES
3a2c6a5090d5   multi-stage-app   "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds   0.0.0.0:8080->3000/tcp, [::]:8080->3000/tcp   my-multistage-app
```

---

## Screenshot

![Task 2 Screenshot](./screenshot.png)
