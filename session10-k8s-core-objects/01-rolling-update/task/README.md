# Task: Rolling Update Strategy — Hands-on Output

## Overview

This task demonstrates the **Rolling Update** deployment strategy in Kubernetes.  
A Rolling Update incrementally replaces old pods with new ones with **zero downtime**.

---

## Commands Run & Output Screenshots

### Step 1 — Deploy v1 and Verify Pods

**Commands:**
```bash
kubectl apply -f 01-rolling-update/deployment-v1.yaml
kubectl apply -f 01-rolling-update/service.yaml
kubectl rollout status deployment/app-rolling
kubectl get pods -l app=app-rolling --show-labels
```

**Output:**

![Step 1 - Deploy v1 and verify pods running](./screenshots/step1-deploy-v1.png)

---

### Step 2 — Access v1 via curl

**Command:**
```bash
curl http://$(minikube ip):30010
```

**Output:**

![Step 2 - curl v1 showing VERSION v1](./screenshots/step2-curl-v1.png)

---

### Step 3 — Trigger Rolling Update to v2 (Watch Pod Churn)

**Commands:**
```bash
kubectl apply -f 01-rolling-update/deployment-v2.yaml
kubectl get pods -l app=app-rolling -w
```

**Output (v1 pods Terminating, v2 pods starting):**

![Step 3 - Rolling update in progress, v1 terminating and v2 creating](./screenshots/step3-rollout-watch.png)

---

### Step 4 — Verify v2 Fully Deployed + Rollout History

**Commands:**
```bash
kubectl rollout status deployment/app-rolling
kubectl get pods -l app=app-rolling --show-labels
kubectl rollout history deployment/app-rolling
```

**Output:**

![Step 4 - All pods on v2, rollout history showing revision 1 and 2](./screenshots/step4-v2-deployed.png)

---

### Step 5 — Rollback to v1

**Commands:**
```bash
kubectl rollout undo deployment/app-rolling
kubectl get pods -l app=app-rolling --show-labels
```

**Output:**

![Step 5 - Rollback complete, all pods show version=v1](./screenshots/step5-rollback.png)

---

### Step 6 — Cleanup

**Commands:**
```bash
kubectl delete -f 01-rolling-update/service.yaml
kubectl delete -f 01-rolling-update/deployment-v1.yaml
```

**Output:**

![Step 6 - Resources deleted successfully](./screenshots/step6-cleanup.png)

---

## Key Takeaways

- Rolling Update is the **default** Kubernetes deployment strategy
- Uses `maxSurge` and `maxUnavailable` to control the rollout pace
- Pods are replaced **gradually** — zero downtime guaranteed
- `kubectl rollout undo` provides instant rollback to previous revision
- Always use a **readinessProbe** so Kubernetes only routes traffic to healthy pods
