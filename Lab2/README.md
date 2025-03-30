# Docker Persistent Volume Demo

This tutorial demonstrates how to use Docker volumes to persist data across container restarts and rebuilds using Nginx as a web server.

## Project Structure

```
Lab2/
├── Dockerfile
├── docker-compose.yml
├── html/
│   └── index.html
└── README.md
```

## Prerequisites

- Docker installed on your machine
- Basic understanding of Docker concepts

## Option 1: Using Docker CLI

### Step 1: Build the Docker image

```bash
docker build -t nginx-volume-demo .
```

### Step 2: Create a Docker volume

```bash
docker volume create web-content
```

### Step 3: Run the container with a volume mount

```bash
docker run -d --name nginx-volume-container \
  -p 8080:80 \
  -v $(pwd)/html:/usr/share/nginx/html \
  nginx-volume-demo
```

#### Alternative: Using a named volume instead of a bind mount

```bash
docker run -d --name nginx-volume-container \
  -p 8080:80 \
  -v web-content:/usr/share/nginx/html \
  nginx-volume-demo
```

### Step 4: Access the website

Open your browser and navigate to http://localhost:8080

### Step 5: Test persistence

1. Modify the html/index.html file
2. Refresh your browser to see changes immediately
3. Stop and remove the container:
   ```bash
   docker stop nginx-volume-container
   docker rm nginx-volume-container
   ```
4. Start a new container with the same volume:
   ```bash
   docker run -d --name nginx-volume-container-new \
     -p 8080:80 \
     -v $(pwd)/html:/usr/share/nginx/html \
     nginx-volume-demo
   ```
5. Verify your changes are still there at http://localhost:8080

## Option 2: Using Docker Compose

### Step 1: Start services with Docker Compose

```bash
docker-compose up -d
```

### Step 2: Access the website

Open your browser and navigate to http://localhost:8080

### Step 3: Test persistence

1. Modify the html/index.html file
2. Refresh your browser to see changes immediately
3. Stop and remove containers:
   ```bash
   docker-compose down
   ```
4. Start services again:
   ```bash
   docker-compose up -d
   ```
5. Verify your changes are still there at http://localhost:8080

## Understanding Docker Volumes

### Types of Volumes Demonstrated

1. **Bind Mounts**: We're mapping a directory from the host (./html) to a directory in the container (/usr/share/nginx/html).
2. **Named Volumes**: Shown in the Docker CLI alternative approach.

### Key Benefits

- Data persists independently of container lifecycle
- Easy sharing of data between host and container
- Improved performance (especially for databases or file-intensive applications)
- Can be shared across multiple containers

### Common Use Cases

- Databases (MySQL, PostgreSQL, MongoDB)
- Web server content (as demonstrated here)
- Application logs
- Configuration files

## Cleaning Up

```bash
# For Docker CLI approach
docker stop nginx-volume-container
docker rm nginx-volume-container
docker volume rm web-content

# For Docker Compose approach
docker-compose down
```

## Additional Commands

### Inspect volume details

```bash
docker volume inspect web-content
```

### List all volumes

```bash
docker volume ls
```

### Remove all unused volumes

```bash
docker volume prune
```
