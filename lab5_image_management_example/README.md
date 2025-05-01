# Docker Examples Lab

This lab demonstrates various Docker concepts including:

- Different types of Docker image builds
- Image loading and unloading
- Pushing images to Docker Hub
- Using Docker CLI and Docker Compose

## Table of Contents

- [Application Overview](#application-overview)
- [Docker Image Types](#docker-image-types)
- [Architecture Overview](#architecture-overview)
- [Docker CLI Commands](#docker-cli-commands)
- [Docker Compose](#docker-compose)
- [Complete Cleanup](#complete-cleanup)
- [Use Cases and Scenarios](#use-cases-and-scenarios)
- [Troubleshooting](#troubleshooting)

## Application Overview

The example includes a simple Node.js Express application that serves a "Hello from Docker!" message.

```
┌─────────────────────────┐
│                         │
│    Express Web Server   │
│                         │
│  GET / → "Hello from    │
│        Docker!"         │
│                         │
└─────────────────────────┘
```

## Docker Image Types

This lab includes three different Dockerfile examples, each demonstrating important Docker concepts:

### 1. Basic Dockerfile (`Dockerfile.basic`)

A standard single-stage build process that creates a simple container with all build dependencies included.

```
┌────────────────────────────────────┐
│ node:18-alpine                     │
│ ┌──────────────────────────────┐   │
│ │ Application Code             │   │
│ │                              │   │
│ │ ┌────────────────────────┐   │   │
│ │ │ npm dependencies       │   │   │
│ │ │ (production + dev)     │   │   │
│ │ └────────────────────────┘   │   │
│ └──────────────────────────────┘   │
└────────────────────────────────────┘
```

**Key features:**

- Simple to understand and build
- Contains all dependencies in a single layer
- Larger image size due to included dev dependencies and build tools

### 2. Multi-stage Dockerfile (`Dockerfile.multistage`)

Optimizes the image by separating build and runtime environments to create smaller, more efficient containers.

```
┌────────────────────────┐    ┌────────────────────────┐
│ BUILD STAGE            │    │ PRODUCTION STAGE       │
│                        │    │                        │
│ node:18-alpine         │    │ node:18-alpine         │
│ ┌──────────────────┐   │    │ ┌──────────────────┐   │
│ │ App code         │   │    │ │ App code         │   │
│ │                  │   │    │ │ (only .js files) │   │
│ │ npm install      │   │    │ │                  │   │
│ │ (all deps)       │   │    │ │ node_modules     │   │
│ └──────────────────┘   │    │ │ (prod only)      │   │
│                        │    │ └──────────────────┘   │
└───────────┬────────────┘    └────────────────────────┘
            │                              ▲
            │                              │
            └──────────────────────────────┘
                     Copy artifacts
```

**Key features:**

- Smaller final image size
- Excludes build tools and development dependencies
- More secure with fewer unnecessary packages
- Best for production environments

### 3. Non-root Dockerfile (`Dockerfile.nonroot`)

Security-focused approach running the app as a non-root user to limit potential container escape vulnerabilities.

```
┌──────────────────────────────────────────┐
│ node:18-alpine                           │
│ ┌────────────────────────────────────┐   │
│ │ Custom non-root user: appuser      │   │
│ │                                    │   │
│ │ ┌────────────────────────────────┐ │   │
│ │ │ Application code               │ │   │
│ │ │                                │ │   │
│ │ │ ┌────────────────────────────┐ │ │   │
│ │ │ │ npm dependencies           │ │ │   │
│ │ │ └────────────────────────────┘ │ │   │
│ │ └────────────────────────────────┘ │   │
│ └────────────────────────────────────┘   │
└──────────────────────────────────────────┘
```

**Key features:**

- Enhanced security through principle of least privilege
- Application runs as non-root user
- File permissions explicitly set
- Prevents privilege escalation in case of vulnerabilities

## Architecture Overview

The following diagram illustrates how the different components interact in this lab:

```
                                     ┌─────────────────┐
                                     │  Docker Hub     │
                                     │                 │
                                     │  Remote Registry│
                                     └────────┬────────┘
                                              │
                                              │ Push/Pull
                                              │
┌──────────────────────────┐        ┌────────▼────────┐
│    Local Development     │        │ Docker Images    │
│    Environment           │        │                  │
│                          │ Build  │ ┌──────────────┐ │
│  ┌─────────────────────┐ ├───────►│ │Basic Image   │ │
│  │Application Source   │ │        │ └──────────────┘ │      ┌──────────────────┐
│  │                     │ │        │ ┌──────────────┐ │      │ Docker Containers│
│  │server.js            │ │        │ │Multi-stage   │ │      │                  │
│  │package.json         │ │        │ │Image         │ │      │ ┌──────────────┐ │
│  └─────────────────────┘ │        │ └──────────────┘ │      │ │App Container │ │
│                          │        │ ┌──────────────┐ │      │ │Port: 3000    │ │
│                          │        │ │Non-root      │ │      │ └──────────────┘ │
│                          │        │ │Image         │ │      │ ┌──────────────┐ │
└──────────────────────────┘        │ └──────────────┘ ├─────►│ │Multistage    │ │
                                    └──────────────────┘      │ │Port: 3001    │ │
                                              │               │ └──────────────┘ │
                                              │ Save/Load     │ ┌──────────────┐ │
                                              │               │ │Non-root      │ │
                                     ┌────────▼────────┐      │ │Port: 3002    │ │
                                     │ .tar Image File │      │ └──────────────┘ │
                                     │                 │      └──────────────────┘
                                     └─────────────────┘
```

### How Data Flows

1. Source code is built into Docker images using different Dockerfile strategies
2. Images can be:
   - Run locally as containers
   - Saved to tar files for transfer
   - Pushed to Docker Hub for distribution
3. Each container exposes the application on different ports

## Docker CLI Commands

### Building Images

```bash
# Build the basic image
docker build -t docker-example:basic -f Dockerfile.basic .

# Build the multi-stage image
docker build -t docker-example:multistage -f Dockerfile.multistage .

# Build the non-root user image
docker build -t docker-example:nonroot -f Dockerfile.nonroot .
```

### Running Containers

```bash
# Run the basic image
docker run -p 3000:3000 docker-example:basic

# Run the multi-stage image
docker run -p 3001:3000 docker-example:multistage

# Run the non-root image
docker run -p 3002:3000 docker-example:nonroot
```

### Listing Images and Containers

```bash
# List all images
docker images

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a
```

### Stopping and Removing Containers

```bash
# Stop a container
docker stop <container_id>

# Remove a container
docker rm <container_id>

# Stop and remove in one command
docker rm -f <container_id>
```

### Image Management

#### Saving Images to Files

```bash
# Save an image to a tar file
docker save -o docker-example-basic.tar docker-example:basic
```

Image saving process:

```
┌──────────────────┐     ┌───────────────────┐
│ Docker Image     │     │ Filesystem        │
│                  │     │                   │
│ docker-example:  │     │ docker-example-   │
│ basic            │────►│ basic.tar         │
│                  │     │                   │
└──────────────────┘     └───────────────────┘
     docker save
```

#### Loading Images from Files

```bash
# Load an image from a tar file
docker load -i docker-example-basic.tar
```

Image loading process:

```
┌───────────────────┐     ┌──────────────────┐
│ Filesystem        │     │ Docker Image     │
│                   │     │                  │
│ docker-example-   │     │ docker-example:  │
│ basic.tar         │────►│ basic            │
│                   │     │                  │
└───────────────────┘     └──────────────────┘
     docker load
```

#### Tagging Images for Docker Hub

```bash
# Tag with your Docker Hub username
docker tag docker-example:basic username/docker-example:latest
```

#### Pushing to Docker Hub

```bash
# Log in to Docker Hub
docker login

# Push the image
docker push username/docker-example:latest

# Log out when done
docker logout
```

Push process visualization:

```
┌─────────────────┐     ┌───────────────────┐     ┌─────────────────────┐
│ Local Image     │     │                   │     │ Docker Hub Registry │
│                 │     │  docker push      │     │                     │
│ username/docker-│────►│                   │────►│ username/docker-    │
│ example:latest  │     │                   │     │ example:latest      │
│                 │     │                   │     │                     │
└─────────────────┘     └───────────────────┘     └─────────────────────┘
```

### Docker Image Inspection and Cleanup

```bash
# Inspect image details
docker inspect docker-example:basic

# Remove an image
docker rmi docker-example:basic

# Remove unused images
docker image prune

# Remove all unused images (not just dangling ones)
docker image prune -a
```

## Docker Compose

Docker Compose allows you to define and run multi-container Docker applications.

### Running with Docker Compose

```bash
# Start all services
docker compose up

# Start in detached mode (background)
docker compose up -d

# Stop all services
docker compose down

# Build and start
docker compose up --build

# View logs
docker compose logs
```

### Services in docker-compose.yml

The compose file includes three services using the different Dockerfile types:

- `app` - Uses the basic Dockerfile (port 3000)
- `app-multistage` - Uses the multi-stage Dockerfile (port 3001)
- `app-nonroot` - Uses the non-root Dockerfile (port 3002)

Visualizing the Docker Compose setup:

```
┌─────────────────────────────────────────────────────────────────┐
│ Docker Compose Environment                                      │
│                                                                 │
│  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐│
│  │ app             │   │ app-multistage  │   │ app-nonroot     ││
│  │                 │   │                 │   │                 ││
│  │ Dockerfile.basic│   │ Dockerfile.     │   │ Dockerfile.     ││
│  │                 │   │ multistage      │   │ nonroot         ││
│  │                 │   │                 │   │                 ││
│  │ Port: 3000      │   │ Port: 3001      │   │ Port: 3002      ││
│  └─────────────────┘   └─────────────────┘   └─────────────────┘│
│                                                                 │
│                   Shared Docker Network                         │
└─────────────────────────────────────────────────────────────────┘
                               │
                               │
                               ▼
┌───────────────────────────────────────────────────────────────────┐
│                         Host Machine                              │
│                                                                   │
│   localhost:3000        localhost:3001        localhost:3002      │
└───────────────────────────────────────────────────────────────────┘
```

## Complete Cleanup

To clean up all resources created by this lab, you can use the provided cleanup script:

```bash
# Make the script executable
chmod +x cleanup.sh

# Run the cleanup script
./cleanup.sh
```

The cleanup script will:

1. Stop and remove all running containers from docker-compose
2. Remove any standalone containers from manual runs
3. Remove all Docker images created in this lab
4. Remove saved Docker image tar files
5. Prune unused Docker resources

Cleanup process visualization:

```
┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
│ Running           │      │ Docker            │      │ Docker            │
│ Containers        │─────►│ Images            │─────►│ Volumes/Networks  │
│                   │stop  │                   │remove│                   │
└───────────────────┘      └───────────────────┘      └───────────────────┘
          │                          │                          │
          │                          │                          │
          ▼                          ▼                          ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                       ./cleanup.sh                                    │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
          │                          │                          │
          │                          │                          │
          ▼                          ▼                          ▼
┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
│ Local .tar        │      │ Tagged Images     │      │ Unused Resources  │
│ Files             │      │ (Docker Hub)      │      │ (cache, etc.)     │
│                   │      │                   │      │                   │
└───────────────────┘      └───────────────────┘      └───────────────────┘
```

## Use Cases and Scenarios

### Local Development

For local development, you can use the basic Dockerfile with volumes for hot-reloading:

```bash
# Uncomment the volumes section in docker-compose.yml
# Then run:
docker compose up app
```

Changes to your local code will be reflected in the container without rebuilding.

Local development workflow:

```
┌─────────────────────┐        ┌─────────────────────┐
│ Local Source Code   │        │ Container           │
│                     │        │                     │
│  Edit files         │───────►│  App automatically  │
│                     │ Volume │  reloads            │
│                     │ Mount  │                     │
└─────────────────────┘        └─────────────────────┘
```

### Production Deployment

For production, the multi-stage build creates a smaller, optimized image:

```bash
docker build -t myapp:prod -f Dockerfile.multistage .
docker run -d -p 80:3000 myapp:prod
```

Benefits of multi-stage build for production:

- Smaller image size (fewer layers)
- Only production dependencies included
- Faster deployment times
- Reduced attack surface

### Security-Focused Deployment

The non-root Dockerfile improves security by not running the application as root:

```bash
docker build -t myapp:secure -f Dockerfile.nonroot .
docker run -d -p 80:3000 myapp:secure
```

Security benefits:

- Prevents privilege escalation
- Follows principle of least privilege
- Reduces impact of potential container breakout
- Complies with security best practices for containerized applications

### CI/CD Pipeline Integration

Example GitHub Actions workflow to build and push your image:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          file: ./Dockerfile.multistage
          push: true
          tags: username/docker-example:latest
```

CI/CD workflow visualization:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Git Push    │     │ GitHub      │     │ Docker      │     │ Docker Hub  │
│             │────►│ Actions     │────►│ Build       │────►│             │
│             │     │             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                                                   │
                                                                   │
                          ┌─────────────────────────────┐          │
                          │ Production Environment      │          │
                          │                             │          │
                          │ docker pull username/docker ◄──────────┘
                          │ -example:latest             │
                          │                             │
                          └─────────────────────────────┘
```

## Troubleshooting

- **Container exits immediately**: Check your CMD instruction and ensure your application is properly configured
- **Can't access the application**: Verify port mappings and that the application is listening on the correct interface
- **Permission denied errors**: Use the non-root Dockerfile or check volume mount permissions

Common troubleshooting workflow:

```
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  Issue Detection                                                      │
│                                                                       │
└───────────────┬───────────────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  Investigation                                                        │
│  • Check logs: docker logs <container_id>                             │
│  • Inspect container: docker inspect <container_id>                   │
│  • Access container shell: docker exec -it <container_id> /bin/sh     │
│                                                                       │
└───────────────┬───────────────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────────────┐
│                                                                       │
│  Resolution                                                           │
│  • Modify Dockerfile                                                  │
│  • Update application code                                            │
│  • Adjust container configuration                                     │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```
