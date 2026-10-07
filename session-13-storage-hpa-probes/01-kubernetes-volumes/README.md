# Kubernetes Volumes & Storage Deep Dive

In Kubernetes, container filesystems are ephemeral. When a container crashes, Kubelet restarts it with a clean slate, discarding any state written to the container layer. Furthermore, when multiple containers in a single Pod need to share files, a container-isolated filesystem cannot facilitate this.

Kubernetes solves this with **Volumes** — abstractions that provide persistent, sharable, and lifecycle-managed storage.

---

## 1. Volume Types at a Glance

| Volume Type | Lifecycle / Scope | Typical Use Case | Persistence across Pod Recreate? |
| :--- | :--- | :--- | :--- |
| **`emptyDir`** | Bound to Pod lifespan | Temporary workspace, scratchpads, inter-container shared cache | ❌ No |
| **`hostPath`** | Bound to Node filesystem | Accessing Docker daemon socket, node log auditing, single-node testing | ⚠️ Node-dependent only |
| **`PersistentVolume` (PV)** | Cluster resource lifecycle | Production databases, shared object/file stores (NFS, CSI, EBS, GPD) |  Yes |
| **`PersistentVolumeClaim` (PVC)** | User storage request | Decoupled consumption of PV storage |  Yes |
| **`StorageClass`** | Dynamic storage provisioner | Automating on-demand volume creation without manual admin PV provisioning |  Yes |

---

## 2. `emptyDir`

An `emptyDir` volume is created as an empty directory when a Pod is assigned to a Node. It exists for the exact lifespan of that Pod on that node.

### Characteristics:
- **Shared Access:** All containers within the Pod can mount the same `emptyDir` path simultaneously.
- **Medium:** By default stored on whatever medium is backing the node (disk/SSD). Can alternatively be backed by RAM (`medium: Memory`) for high-speed scratch caching (tmpfs).
- **Deletion:** Data is permanently deleted when the Pod is deleted from the node.

### Practical Example: Sidecar Log Processing

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-cache-demo
spec:
  containers:
    - name: web-app
      image: nginx:alpine
      volumeMounts:
        - name: shared-cache
          mountPath: /var/cache/nginx
    - name: cache-cleaner
      image: busybox
      command: ["/bin/sh", "-c", "while true; do rm -rf /cache/*; sleep 3600; done"]
      volumeMounts:
        - name: shared-cache
          mountPath: /cache
  volumes:
    - name: shared-cache
      emptyDir: {}
```

---

## 3. `hostPath`

A `hostPath` volume mounts a file or directory from the host node's filesystem directly into your Pod.

### Characteristics:
- **Node-Bound:** If the Pod is rescheduled to a different node, it cannot access the files left on the previous host node.
- **Security Implications:** Gives Pods raw access to the underlying host node. Typically restricted via Pod Security Standards / Admission Controllers.
- **Best Use Cases:** System daemonsets (e.g. Fluentd reading `/var/log` from the node, or monitoring agents mounting `/sys` or `/var/run/docker.sock`).

### Practical Example: Host Log Collector

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-demo
spec:
  containers:
    - name: log-collector
      image: busybox
      command: ["/bin/sh", "-c", "tail -f /host-logs/syslog"]
      volumeMounts:
        - name: node-syslog
          mountPath: /host-logs
          readOnly: true
  volumes:
    - name: node-syslog
      hostPath:
        path: /var/log
        type: Directory
```

---

## 4. PersistentVolume (PV) & PersistentVolumeClaim (PVC)

To separate developer storage requests from infrastructure administration, Kubernetes introduces the **PV & PVC abstraction model**.

### Architecture Workflow

```text
Cluster Admin / Provisioner                 Developer / Application
┌─────────────────────────┐               ┌─────────────────────────┐
│     PersistentVolume    │               │  PersistentVolumeClaim  │
│  - Capacity: 5Gi        │   ◄─ Bound ─► │  - Requests: 2Gi        │
│  - AccessModes: RWO     │               │  - AccessModes: RWO     │
│  - StorageClass: manual │               │  - StorageClass: manual │
└─────────────────────────┘               └────────────┬────────────┘
                                                       │ mounted in
                                                       ▼
                                          ┌─────────────────────────┐
                                          │           Pod           │
                                          │  - VolumeMount: /data   │
                                          └─────────────────────────┘
```

### Definitions:
- **PersistentVolume (PV):** A piece of storage in the cluster provisioned by an administrator or dynamically provisioned using Storage Classes. It is an independent cluster-scoped resource with a lifecycle separate from any individual Pod.
- **PersistentVolumeClaim (PVC):** A user's request for storage. Users specify size, access modes (`ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany`), and storage classes without needing to understand underlying storage hardware.

### Access Modes:
- `ReadWriteOnce` (RWO): Mounted as read-write by a single Node.
- `ReadOnlyMany` (ROX): Mounted as read-only by multiple Nodes.
- `ReadWriteMany` (RWX): Mounted as read-write by multiple Nodes concurrently (e.g. NFS, AWS EFS).
- `ReadWriteOncePod` (RWOP): Mounted as read-write by a single Pod across the entire cluster.

### Practical Example: Statically Bound PV & PVC

#### 1. PV Definition (`pv.yaml`):
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: static-pv-5gi
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: /mnt/data
```

#### 2. PVC Definition (`pvc.yaml`):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 2Gi
```

---

## 5. StorageClass & Dynamic Provisioning

Static provisioning requires cluster administrators to manually create PVs in advance. When demand spikes, developers may run out of pre-allocated PVs.

**StorageClass** automates this by enabling **Dynamic Provisioning**:

### Workflow:
1. Administrator defines a `StorageClass` specifying a volume provisioner plugin (e.g., AWS EBS CSI, Google Persistent Disk, Azure Disk, Minikube hostpath).
2. Developer creates a `PersistentVolumeClaim` specifying `storageClassName: <class-name>`.
3. Kubernetes automatically contacts the provisioner, creates the underlying cloud/physical disk, and creates a matching `PersistentVolume` bound to the PVC on-demand.

### Practical Example: Dynamic Storage Provisioning

#### StorageClass (`storageclass.yaml`):
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: k8s.io/minikube-hostpath # Or ebs.csi.aws.com in cloud
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
allowVolumeExpansion: true
```

#### Dynamic PVC (`dynamic-pvc.yaml`):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 10Gi
```

When this PVC is created, Kubernetes automatically triggers the provisioner and binds a new 10Gi PV immediately.

---

## 6. Summary Comparison Matrix

| Feature | `emptyDir` | `hostPath` | `PersistentVolume` | Dynamic Provisioning (`StorageClass`) |
| :--- | :--- | :--- | :--- | :--- |
| **Creation** | Automatic on Pod start | Pre-exists on Node | Admin creates PV manually | Automatically created via StorageClass plugin |
| **Scope** | Pod | Node | Cluster | Cluster |
| **Persistence** | Lost on Pod death | Stays on local Node | Persists across cluster | Persists across cluster |
| **Multi-Node Portability** | No | No | Yes (Cloud/SAN/NFS) | Yes (Cloud/SAN/NFS) |
| **Production Fit** | Temporary cache | System DaemonSets | State-heavy apps | Recommended cloud-native standard |
