# Task: Blue-Green Deployment Strategy — Hands-on Output

## Overview

This task demonstrates the **Blue-Green Deployment** strategy in Kubernetes.  
Blue-Green maintains two identical environments simultaneously and switches traffic instantly with a single Service selector change — **zero downtime, instant rollback**.

---

## Commands Run & Output Screenshots

### Step 1 — Deploy Both Blue (v1) and Green (v2) Environments

**Commands:**
```bash
kubectl apply -f 02-blue-green/deployment-blue.yaml
kubectl apply -f 02-blue-green/deployment-green.yaml
kubectl get pods -l app=myapp --show-labels
```

**Output (6 pods total — 3 blue, 3 green):**

![Step 1 - Both blue and green pods running simultaneously](./screenshots/step1-deploy-both.png)

---

### Step 2 — Point Service to BLUE (v1 goes LIVE)

**Commands:**
```bash
kubectl apply -f 02-blue-green/service-blue.yaml
curl http://$(minikube ip):30020
```

**Output (Blue environment serving traffic):**

![Step 2 - Service pointing to blue, curl shows BLUE ENVIRONMENT v1](./screenshots/step2-blue-live.png)

---

### Step 3 — Confirm Service Selector Before the Switch

**Commands:**
```bash
kubectl describe svc myapp-service | grep Selector
kubectl get endpoints myapp-service
```

**Output (selector shows slot=blue, 3 blue pod IPs):**

![Step 3 - Service selector showing slot=blue, 3 endpoints](./screenshots/step3-selector-before.png)

---

### Step 4 — THE SWITCH — Flip 100% Traffic to GREEN Instantly

**Commands:**
```bash
kubectl apply -f 02-blue-green/service-green.yaml
curl http://$(minikube ip):30020
kubectl describe svc myapp-service | grep Selector
```

**Output (Green now serving, selector changed to slot=green):**

![Step 4 - Service switched to green, curl shows GREEN ENVIRONMENT v2](./screenshots/step4-green-live.png)

---

### Step 5 — Verify Endpoints Changed to Green Pod IPs

**Command:**
```bash
kubectl get endpoints myapp-service
```

**Output (3 green pod IPs now):**

![Step 5 - Endpoints updated to 3 green pod IPs](./screenshots/step5-endpoints-green.png)

---

### Step 6 — Rollback — Flip Back to Blue in Under 5 Seconds

**Commands:**
```bash
kubectl apply -f 02-blue-green/service-blue.yaml
curl http://$(minikube ip):30020
```

**Output (Blue serving again instantly):**

![Step 6 - Rollback complete, blue environment live again](./screenshots/step6-rollback-blue.png)

---

### Step 7 — Cleanup

**Commands:**
```bash
kubectl delete -f 02-blue-green/service-blue.yaml
kubectl delete -f 02-blue-green/deployment-blue.yaml
kubectl delete -f 02-blue-green/deployment-green.yaml
```

**Output:**

![Step 7 - All blue-green resources deleted](./screenshots/step7-cleanup.png)

---

## Key Takeaways

- Blue-Green requires **2x compute resources** — the cost of instant switchover
- Traffic flip takes **milliseconds** — just a Service selector change
- **No mixed traffic** at any point — users are always on v1 OR v2, never both
- **Instant rollback** — just apply service-blue.yaml again
- Keep Blue running for 24h after switching to Green as a safety net
