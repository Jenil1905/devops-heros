# Docker Homework Tasks: Hello World Applications

This folder contains simple Hello World web applications containerized using Docker.

## Applications List

- **`nodejs-app/`**: Node.js Express Web Server
- **`python-app/`**: Python Flask Web Application
- **`java-app/`**: Java HTTP Web Server
- **`Apache-app/`**: Apache HTTPD Web Server
- **`React-app/`**: React Web Application (Multi-stage Docker build)
- **`nginx-app/`**: Nginx Web Server

## How to Build and Run

To build and run any application container:

```bash
cd <app-folder>
docker build -t <image-name> .
docker run -d -p <host-port>:<container-port> <image-name>
```
