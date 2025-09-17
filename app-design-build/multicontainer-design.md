# Multi-Container Pod Design Patterns

# 🧠 CKAD: Understanding Multi-Container Pod Design Patterns

In CKAD, you're expected to understand and implement **multi-container pods**, which are pods that include more than one container. This is useful when containers need to **collaborate** within the same Pod (same IP/network/storage).

---

## ✅ Why Use Multi-Container Pods?

All containers in a pod:
- Share the **same network namespace** (same IP and ports)
- Can **communicate via `localhost`**
- Can **share storage volumes**
- Start together and are co-located

---

## 📦 Common Design Patterns

| Pattern       | Purpose                                | Description |
|---------------|----------------------------------------|-------------|
| **Sidecar**   | Enhance or extend the main container   | Runs alongside main app, adds functionality (e.g., logging, proxying) |
| **Ambassador**| Proxy or bridge to external services   | Connects main app to external network/service |
| **Adapter**   | Translates output for monitoring tools | Converts app output to another format (e.g., Prometheus metrics) |

---

## 🔁 1. **Sidecar Pattern**

> 🧠 Most important pattern for CKAD

- Used to **augment** the primary container
- Common uses: logging, monitoring, config reloaders

### ✅ Example: Nginx with a Sidecar Tail Log Container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-sidecar
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  - name: log-watcher
    image: busybox
    command: ["sh", "-c", "tail -f /var/log/nginx/access.log"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  volumes:
  - name: shared-logs
    emptyDir: {}
```

### 🔁 2. Ambassador Pattern
🧠 Useful if container needs to talk to a remote service with extra logic (e.g., TLS)
Ambassador container acts as a proxy
Main container talks to it as if it were the service
#### ✅ Example: Redis client using local proxy
```apiVersion: v1
kind: Pod
metadata:
  name: ambassador-pattern
spec:
  containers:
  - name: redis-client
    image: redis
    command: ["redis-cli", "-h", "localhost"]
  - name: redis-proxy
    image: alpine/socat
    args: ["tcp-listen:6379,fork", "tcp-connect:real.redis.server:6379"]
```


### 🔁 3. Adapter Pattern
Converts output or metrics of main container for scraping/monitoring
Example: Converts app logs into Prometheus metrics
##### ✅ Example: Adapter that reads logs and exposes metrics
```apiVersion: v1
kind: Pod
metadata:
  name: adapter-pattern
spec:
  containers:
  - name: app
    image: custom-logger
    volumeMounts:
    - name: shared-logs
      mountPath: /app/logs
  - name: metrics-adapter
    image: log-to-prometheus
    volumeMounts:
    - name: shared-logs
      mountPath: /logs
  volumes:
  - name: shared-logs
    emptyDir: {}
```