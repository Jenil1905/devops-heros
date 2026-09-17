# Task: Kubernetes ReplicaSet — Hands-on Output

## Overview

A **ReplicaSet** maintains a stable set of replica Pods running at any given time. It is used to guarantee the availability of a specified number of identical Pods.

---

## Commands Run & Output Screenshots

### Step 1 — Deploy and Inspect ReplicaSet

**Commands:**
```bash
kubectl apply -f replicaset/backend-rs.yaml
kubectl get replicaset yatri-backend-rs
kubectl get pods -l app=yatri-backend
```

**Output:**

![Step 1 - ReplicaSet created with 3 replicas and matching pods](./screenshots/step1-rs-deploy.png)

---

### Step 2 — Cleanup

**Command:**
```bash
kubectl delete -f replicaset/backend-rs.yaml
```

---

## Key Takeaways

- ReplicaSet uses **label selectors** to acquire and manage Pods.
- Automatically replaces failed, deleted, or evicted Pods to maintain `desired` replica count.
- Usually managed automatically via higher-level **Deployments** rather than created directly.
