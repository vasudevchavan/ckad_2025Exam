#

## 🔹 Step 1: Define container images (CKAD focus)

✅ Definition (in your own words, try this first):

A container image is a lightweight, standalone, and executable package that includes:
your application code runtime (e.g. Python, Node) system libraries and settings (like environment variables)
You use it to run containers, which are live, running instances of that image.

### Checkpoint Q:
    What’s the difference between a container image and a container?

## 🔹 Step 2: Build container images
The most common way is via a Dockerfile.
What does a Dockerfile do?
It’s a text file that contains a series of instructions to assemble a container image.

🧱 Dockerfile example:
Here’s a simple image that runs a Python HTTP server:

```
# Use a base image
FROM python:3.11-slim
# Set working directory
WORKDIR /app
# Copy source code
COPY . .
# Run the app
CMD ["python3", "app.py"]
```

Then you build it like this:
```
docker build -t my-python-app:1.0 .
```

### Mini Practice:
    What does the FROM instruction do in the Dockerfile?
    (And why is that useful?)


## 🔹 Step 3: Modify container images
    Update the Dockerfile (e.g., install more tools, copy more files)
    Rebuild with docker build
    Push to a registry (like Docker Hub or a private repo)
    You should avoid using docker commit in real workflows — it's not declarative or reproducible.

## 🛠 Common modification tasks:
    Change the base image (FROM)
    Add environment variables (ENV)
    Expose a different port (EXPOSE)
    Add health checks (in Kubernetes, not Dockerfile)



## CheatSheet Docker commands:

### build image:
```
        docker build -t <image-name>:<tag> <path>
        docker build -t myapp:v1 .
        docker build --build-arg APP_ENV=staging -t myapp:staging .
        DOCKER_BUILDKIT=1 docker build \
            --secret id=mysecret,src=./secret.txt \
            -t secure-app .
```

### tag image:
```
    docker tag <source-image>:<tag> <target-image>:<tag>
    docker tag myapp:v1 myregistry/myapp:v1
```

### push image:
```
    docker push myregistry/myapp:v1
```

### list images:
```
    docker images
```

### inspect image:
```
    docker inspect <image name>
```

### remove image:
```
    docker rmi <image-name>
```

### export image to a file:
```
    docker save -o myapp.tar myapp:v1
```

### import image from a file:
```
    docker load -i myapp.tar
```


## docker run Commands

### 🔹 1. Pass environment variables
```    docker run -e ENV_VAR_NAME=value myapp
    From a file:
    docker run --env-file=env.list myapp
    📄 env.list:
    API_KEY=xyz123
    DEBUG=true
```
### 🔹 2. Mount volumes (bind mount or named volume)
```    Bind mount (host directory into container)
    docker run -v $(pwd)/data:/app/data myapp
    Named volume
    docker volume create mydata
    docker run -v mydata:/app/data myapp
```

### 🔹 3. Map ports
```    docker run -p 8080:80 myapp
    Maps host port 8080 → container port 80.
```
### 🔹 4. Limit resources (CPU/memory)
```    docker run --memory=512m --cpus=1 myapp
    Useful for simulating Kubernetes resource limits locally.
```
### 🔹 5. Run in detached mode
```    docker run -d --name myweb myapp
    Starts in background (-d = detached).
```
### 🔹 6. Override entrypoint or command
```    docker run --entrypoint /bin/bash myapp
    Or override CMD:
    docker run myapp ls -la
```
### 🔹 7. Access container with interactive shell
```    docker run -it myapp /bin/bash
    If you just need to test inside:
    docker exec -it <container-name> sh
```
### 🔹 8. Network options
```    docker network create mynet
    docker run --network=mynet myapp
    To connect two containers:
    docker run --name db --network=mynet postgres
    docker run --network=mynet myapp
```
### 🔹 9. Auto-remove container after it exits
```    docker run --rm myapp
```

### 🔹 10. Pass secrets securely (BuildKit-style not supported at runtime)
```    Docker doesn't support secure secrets like Kubernetes at runtime, so you'd typically mount a file:
    docker run -v $(pwd)/secrets:/run/secrets myapp
    Then your app reads /run/secrets/api_key.
```

### 🔍 Example: combo command
```    docker run -d --name webapp \
    -e ENV=prod \
    -v $(pwd)/config:/app/config \
    -p 8080:80 \
    --memory=512m --cpus=1 \
    myapp:latest
```