# CKAD-focused Kubernetes Workload Resource Guide

## 🧠 CKAD Workload Resource Cheat Sheet

### ✅ When to Use Each Workload Resource

| Resource      | Use Case                                                     | CKAD Importance |
|---------------|--------------------------------------------------------------|-----------------|
| **Deployment**| Stateless apps, rolling updates, scaling                     | 🟢 Must know    |
| **Job**       | One-time task (e.g., DB migration)                           | 🟢 Must know    |
| **CronJob**   | Scheduled tasks (e.g., daily backups)                        | 🟢 Must know    |
| **DaemonSet** | Run one pod per node (e.g., logging agent)                   | 🟡 Know basics  |
| **StatefulSet**| Stateful apps needing stable network/storage IDs            | 🟡 Know basics  |
| **ReplicaSet**| Maintain fixed number of identical pods — use Deployment instead | 🔴 Low priority |
| **Pod**       | Simple debugging, single-container test                      | 🟢 Must know    |

---

### 📘 Quick Decision Table

| Use Case                               | Resource     |
|----------------------------------------|--------------|
| Scalable, stateless web app            | Deployment   |
| One-time script or batch process       | Job          |
| Periodic task like cron                | CronJob      |
| Monitoring/logging on every node       | DaemonSet    |
| Persistent storage, stable identity    | StatefulSet  |
| Quick debug or test pod                | Pod          |

---

### ✍️ YAML Examples

#### 🚀 Deployment (Stateless App)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
```

#### Job (One-Time Task)
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    spec:
      containers:
      - name: hello
        image: busybox
        command: ["echo", "Hello CKAD"]
      restartPolicy: Never
```

### ⏰ CronJob (Scheduled Task)
```apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cron
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["echo", "Hello CKAD Cron"]
          restartPolicy: OnFailure
```

#### 🧩 DaemonSet (One Pod Per Node)
```apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      name: node-exporter
  template:
    metadata:
      labels:
        name: node-exporter
    spec:
      containers:
      - name: exporter
        image: prom/node-exporter
```


## 💡 CKAD Tips
    ✅ Use kubectl explain to explore resource structure during exam:
        kubectl explain deployment.spec.template.spec.containers
    ✅ Use --dry-run=client to generate YAML:
        kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml