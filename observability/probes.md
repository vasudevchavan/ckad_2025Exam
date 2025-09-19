🔍 1. Liveness Probe
✅ Purpose:
To detect if a container is still alive or hung. If the check fails, Kubernetes will kill and restart the container.
🧪 A. Liveness with httpGet
Example: Web server must respond to /health on port 8080.

```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-http
spec:
  containers:
  - name: web-server
    image: nginx
    ports:
    - containerPort: 8080
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
      timeoutSeconds: 2
      failureThreshold: 3
```


🟡 Behavior:
Wait 10 seconds after start.
Call /health every 5s.
If 3 consecutive failures occur, the pod is restarted.
🧪 B. Liveness with exec (command)
Example: Check if /tmp/healthy file exists.

```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-exec
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "touch /tmp/healthy; sleep 3600"]
    livenessProbe:
      exec:
        command: ["cat", "/tmp/healthy"]
      initialDelaySeconds: 5
      periodSeconds: 10
```


🟡 Behavior:
cat /tmp/healthy must succeed.
If it fails, the container is restarted.
🧪 C. Liveness with tcpSocket
Example: App must be listening on port 3306 (e.g., MySQL)

```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-tcp
spec:
  containers:
  - name: mysql
    image: mysql:5.7
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: root
    ports:
    - containerPort: 3306
    livenessProbe:
      tcpSocket:
        port: 3306
      initialDelaySeconds: 10
      periodSeconds: 15
```

🟡 Behavior:
TCP connection to port 3306 must succeed.
If it can't connect, the pod is restarted.
🚦 2. Readiness Probe
✅ Purpose:
To detect if a container is ready to serve traffic. If it fails, Kubernetes removes the pod from the Service endpoints, but doesn't restart it.
🧪 A. Readiness with httpGet
Example: App is ready only after /ready responds OK.

```apiVersion: v1
kind: Pod
metadata:
  name: readiness-http
spec:
  containers:
  - name: app
    image: my-app
    ports:
    - containerPort: 8080
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      failureThreshold: 3
```


🟡 Behavior:
Pod only receives traffic when /ready returns success.
If it fails, it's removed from Service endpoints.
🧪 B. Readiness with exec
Example: App is ready only if /tmp/ready exists.

```
apiVersion: v1
kind: Pod
metadata:
  name: readiness-exec
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "touch /tmp/ready; sleep 3600"]
    readinessProbe:
      exec:
        command: ["cat", "/tmp/ready"]
      initialDelaySeconds: 5
      periodSeconds: 5
```


🧪 C. Readiness with tcpSocket
Example: App is ready when port 9090 is accepting TCP connections.

```
apiVersion: v1
kind: Pod
metadata:
  name: readiness-tcp
spec:
  containers:
  - name: app
    image: my-app
    ports:
    - containerPort: 9090
    readinessProbe:
      tcpSocket:
        port: 9090
      initialDelaySeconds: 5
      periodSeconds: 10
```

🚀 3. Startup Probe
✅ Purpose:
Used when an application needs a long time to start. Prevents Kubernetes from killing the container too early during initialization.
Once the startup probe passes, liveness and readiness probes take over.
If it fails repeatedly, the container is restarted.
🧪 A. Startup Probe with httpGet

```
apiVersion: v1
kind: Pod
metadata:
  name: startup-http
spec:
  containers:
  - name: app
    image: my-app
    ports:
    - containerPort: 8080
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 10
```

🟡 Behavior:
Kubernetes gives the app 10 x 10 = 100 seconds to start.
If the probe passes once, it's considered started.
If not, the container is killed.
🧪 B. Startup Probe with exec

```
apiVersion: v1
kind: Pod
metadata:
  name: startup-exec
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "sleep 40 && touch /tmp/started && sleep 3600"]
    startupProbe:
      exec:
        command: ["cat", "/tmp/started"]
      initialDelaySeconds: 5
      periodSeconds: 5
      failureThreshold: 12
```


🟡 Behavior:
Waits up to 12 × 5 = 60 seconds for /tmp/started to exist.
After success, readiness/liveness take over.
🧪 C. Startup Probe with tcpSocket

```
apiVersion: v1
kind: Pod
metadata:
  name: startup-tcp
spec:
  containers:
  - name: app
    image: my-app
    ports:
    - containerPort: 9090
    startupProbe:
      tcpSocket:
        port: 9090
      initialDelaySeconds: 15
      periodSeconds: 10
      failureThreshold: 6
```


🟡 Behavior:
Waits up to 60s (6 × 10s) for port 9090 to accept TCP connections.
🧠 Summary Table


|Probe Type	|Purpose	|Actions Taken on Failure|
|----|----|----|
|Liveness	|Is the container alive?	|Container is restarted|
|Readiness	|Is the container ready for traffic?	|Pod is removed from endpoints|
|Startup	|Has the container finished startup?	|Container is restarted|