# Docker Practical Guide

A comprehensive guide to Docker with practical, real-world examples and explanations.

## Table of Contents

- [Motivation](#motivation)
- [Needs](#needs)
- [Benefits](#benefits)
- [Problems Docker Does Not Solve](#problems-docker-does-not-solve)
- [What is Docker?](#what-is-docker)
- [Architecture](#architecture)
- [Installation](#installation)
- [Docker Engine](#docker-engine)
- [Docker Registry and Docker Hub](#docker-registry-and-docker-hub)
- [Docker Command Structure](#docker-command-structure)
- [Docker Container](#docker-container)
- [Docker Volumes/Bind Mounts](#docker-volumesbind-mounts)
- [Docker Network](#docker-network)
- [Docker Log](#docker-log)
- [Docker Stats/Memory-CPU Limitations](#docker-statsmemory-cpu-limitations)
- [Docker Environment Variables](#docker-environment-variables)
- [Docker File](#docker-file)
- [Docker Image](#docker-image)
- [Docker Compose](#docker-compose)
- [Docker Swarm](#docker-swarm)
- [Docker Stack / Docker Service](#docker-stack--docker-service)
- [Docker Buildx and BuildKit](#docker-buildx-and-buildkit)
- [Lab8 LocalStack Example](#lab8-localstack-example)

## Motivation

### Why Docker Exists

Traditional software deployment faces numerous challenges:

```
┌─────────────────────────────┐     ┌─────────────────────────────┐
│ Development Environment     │     │ Production Environment      │
│                             │     │                             │
│  ┌─────────┐   ┌─────────┐  │     │  ┌─────────┐   ┌─────────┐  │
│  │ App A   │   │ App B   │  │     │  │ App A   │   │ App B   │  │
│  │ v1.2    │   │ v2.0    │  │     │  │ v1.0    │   │ v1.8    │  │
│  └─────────┘   └─────────┘  │     │  └─────────┘   └─────────┘  │
│                             │     │                             │
│  ┌─────────┐   ┌─────────┐  │     │  ┌─────────┐   ┌─────────┐  │
│  │ Lib X   │   │ Lib Y   │  │     │  │ Lib X   │   │ Lib Y   │  │
│  │ v2.2    │   │ v3.0    │  │     │  │ v1.5    │   │ v2.1    │  │
│  └─────────┘   └─────────┘  │     │  └─────────┘   └─────────┘  │
│                             │     │                             │
│  ┌─────────────────────┐    │     │  ┌─────────────────────┐    │
│  │ OS (macOS/Windows)  │    │     │  │ OS (Linux)          │    │
│  └─────────────────────┘    │     │  └─────────────────────┘    │
└─────────────────────────────┘     └─────────────────────────────┘
                  │                                 │
                  │           Deployment            │
                  └─────────────────────────────────┘
                        "Works on my machine!"
```

Before Docker, developers regularly faced the infamous "it works on my machine" problem due to differences between development, testing, and production environments. Docker emerged to solve these inconsistencies by containerizing applications.

## Needs

### Why We Need Docker

Modern application development requires:

1. **Consistent Environments**: Same environment from development to production
2. **Isolation**: Applications shouldn't interfere with each other
3. **Resource Efficiency**: Better utilization of hardware resources than VMs
4. **Rapid Deployment**: Quick and reliable deployment process
5. **Microservices Support**: Easy deployment and scaling of independent services
6. **DevOps Integration**: Streamlined CI/CD pipelines

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Before Docker:                                             │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐ │
│  │ Developer │→ │ Build     │→ │ Test      │→ │Production │ │
│  │ Machine   │  │ Server    │  │Environment│  │ Server    │ │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘ │
│       ↑              ↑              ↑              ↑        │
│       │              │              │              │        │
│  Different environments, dependencies, configurations       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  With Docker:                                               │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐ │
│  │ Developer │→ │ Build     │→ │ Test      │→ │Production │ │
│  │ Machine   │  │ Server    │  │Environment│  │ Server    │ │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘ │
│       ↑              ↑              ↑              ↑        │
│       │              │              │              │        │
│           Same container runs across all environments       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Benefits

### Key Advantages of Docker

1. **Consistency**: Identical environment from development to production
2. **Portability**: Run anywhere Docker is installed
3. **Isolation**: Applications run independently with their dependencies
4. **Efficiency**: Lightweight compared to traditional VMs
5. **Scalability**: Easy to scale applications horizontally
6. **Version Control**: Images are versioned for easy rollback
7. **Rapid Deployment**: Fast application startup times
8. **Resource Management**: CPU and memory constraints
9. **Microservices Architecture**: Perfect fit for microservices

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Benefits                         │
│                                                             │
│  ┌───────────┐   ┌───────────┐   ┌────────────┐             │
│  │Consistency│   │Portability│   │ Isolation  │             │
│  └───────────┘   └───────────┘   └────────────┘             │
│                                                             │
│  ┌───────────┐   ┌───────────┐   ┌────────────┐             │
│  │Efficiency │   │Scalability│   │  Version   │             │
│  │           │   │           │   │  Control   │             │
│  └───────────┘   └───────────┘   └────────────┘             │
│                                                             │
│  ┌───────────┐   ┌───────────┐   ┌────────────┐             │
│  │  Rapid    │   │ Resource  │   │Microservice│             │
│  │Deployment │   │Management │   │ Support    │             │
│  └───────────┘   └───────────┘   └────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Problems Docker Does Not Solve

Despite its advantages, Docker has limitations:

1. **Stateful Applications**: Containers are ephemeral by design, making stateful applications challenging
2. **GUI Applications**: Not designed for graphical applications
3. **Cross-Container Networking**: Can be complex to set up
4. **Security Concerns**: Containers share the host kernel, potential security risks
5. **Persistent Storage**: Requires careful planning
6. **Windows Application Support**: Limited compared to Linux applications
7. **Learning Curve**: Requires new skills and organizational changes
8. **Container Orchestration**: Docker alone doesn't handle complex orchestration (solved by Kubernetes)
9. **Monitoring**: Requires additional tools for production monitoring

```
┌────────────────────────────────────────────────────────────┐
│               Docker Limitations                           │
│                                                            │
│  ┌───────────────────┐        ┌───────────────────┐        │
│  │Stateful           │        │GUI Applications   │        │
│  │Applications       │        │                   │        │
│  └───────────────────┘        └───────────────────┘        │
│                                                            │
│  ┌───────────────────┐        ┌───────────────────┐        │
│  │Security           │        │Persistent         │        │
│  │Concerns           │        │Storage            │        │
│  └───────────────────┘        └───────────────────┘        │
│                                                            │
│  ┌───────────────────┐        ┌───────────────────┐        │
│  │Complex            │        │Container          │        │
│  │Orchestration      │        │Monitoring         │        │
│  └───────────────────┘        └───────────────────┘        │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## What is Docker?

Docker is an open platform for developing, shipping, and running applications in containers. Containers package an application with all its dependencies into a standardized unit for software development and deployment.

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                         DOCKER                             │
│                                                            │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                       │ │
│  │  Containers: Lightweight, portable units that         │ │
│  │  package applications and dependencies                │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                       │ │
│  │  Images: Read-only templates for creating containers  │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                       │ │
│  │  Docker Engine: Technology that runs containers       │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

Unlike virtual machines that virtualize an entire operating system, Docker containers share the host system's kernel and isolate the application processes from the rest of the system. This makes them significantly more lightweight and efficient.

## Architecture

Docker uses a client-server architecture with multiple components:

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                    Docker Architecture                     │
│                                                            │
│  ┌─────────────┐          ┌───────────────────────────┐    │
│  │             │ REST API │                           │    │
│  │  Docker CLI ├──────────►     Docker Daemon         │    │
│  │             │          │                           │    │
│  └─────────────┘          └────────────┬──────────────┘    │
│                                        │                   │
│                                        │ Manages           │
│                                        ▼                   │
│  ┌─────────────┐          ┌────────────────────────────┐   │
│  │             │  Pull/   │                            │   │
│  │  Registry   ◄──────────┤     Images & Containers    │   │
│  │             │  Push    │                            │   │
│  └─────────────┘          └────────────────────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Docker Client**: Command-line interface (CLI) for interacting with Docker
2. **Docker Daemon (Server)**: Background service managing containers
3. **Docker Objects**:
   - **Images**: Read-only templates for containers
   - **Containers**: Runnable instances of images
   - **Networks**: Communication between containers
   - **Volumes**: Persistent data storage
4. **Docker Registry**: Repository for Docker images

### Docker vs. Virtual Machines

```
┌───────────────────────────────┐    ┌───────────────────────────────┐
│        Virtual Machines       │    │          Docker               │
│                               │    │                               │
│  ┌─────────┐    ┌─────────┐   │    │  ┌─────────┐    ┌─────────┐   │
│  │ App A   │    │ App B   │   │    │  │ App A   │    │ App B   │   │
│  └─────────┘    └─────────┘   │    │  └─────────┘    └─────────┘   │
│  ┌─────────┐    ┌─────────┐   │    │  ┌─────────┐    ┌─────────┐   │
│  │ Bins/   │    │ Bins/   │   │    │  │ Bins/   │    │ Bins/   │   │
│  │ Libs    │    │ Libs    │   │    │  │ Libs    │    │ Libs    │   │
│  └─────────┘    └─────────┘   │    │  └─────────┘    └─────────┘   │
│  ┌─────────┐    ┌─────────┐   │    │                               │
│  │ Guest   │    │ Guest   │   │    │           Docker Engine       │
│  │ OS      │    │ OS      │   │    │                               │
│  └─────────┘    └─────────┘   │    │                               │
│                               │    │                               │
│       Hypervisor              │    │            Host OS            │
│                               │    │                               │
│         Host OS               │    │                               │
│                               │    │                               │
│        Hardware               │    │           Hardware            │
└───────────────────────────────┘    └───────────────────────────────┘
```

Docker containers share the host OS kernel, making them much lighter than VMs which require a full OS for each instance. This results in:

- Faster startup times (seconds vs minutes)
- Lower resource consumption
- Higher density of applications per server

## Installation

Docker can be installed on various operating systems:

### For macOS and Windows

1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Follow the installation wizard
3. Launch Docker Desktop

### For Linux (Ubuntu)

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Add your user to the docker group (to run docker without sudo)
sudo usermod -aG docker $USER
```

### Verify Installation

```bash
# Check Docker version
docker --version

# Run hello-world container to verify installation
docker run hello-world
```

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│           Docker Installation Verification                 │
│                                                            │
│  ┌─────────────┐           ┌────────────────────────┐      │
│  │             │  Step 1   │                        │      │
│  │  Terminal   ├───────────► docker run hello-world │      │
│  │             │           │                        │      │
│  └─────────────┘           └───────────┬────────────┘      │
│                                       │                    │
│                                       │ Step 2             │
│                                       ▼                    │
│  ┌─────────────┐          ┌────────────────────────┐       │
│  │             │  Step 3  │                        │       │
│  │  Terminal   ◄──────────┤ Pull hello-world image │       │
│  │             │          │                        │       │
│  └─────────────┘          └───────────┬────────────┘       │
│                                       │                    │
│                                       │ Step 4             │
│                                       ▼                    │
│  ┌─────────────┐          ┌────────────────────────┐       │
│  │             │  Step 5  │                        │       │
│  │  Terminal   ◄──────────┤ Run container & output │       │
│  │             │          │                        │       │
│  └─────────────┘          └────────────────────────┘       │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Docker Engine

Docker Engine is the core technology that powers Docker. It's a client-server application with these main components:

```
┌────────────────────────────────────────────────────────────┐
│                    Docker Engine                           │
│                                                            │
│  ┌────────────────────────────────────────────────────┐    │
│  │                                                    │    │
│  │  Docker Daemon (dockerd)                           │    │
│  │  - Manages Docker objects                          │    │
│  │  - Listens for API requests                        │    │
│  │  - Handles container lifecycle                     │    │
│  │                                                    │    │
│  └────────────────────────────────────────────────────┘    │
│                          ▲                                 │
│                          │                                 │
│                          │ REST API                        │
│                          │                                 │
│                          ▼                                 │
│  ┌────────────────────────────────────────────────────┐    │
│  │                                                    │    │
│  │  Docker CLI (docker)                               │    │
│  │  - Command-line interface                          │    │
│  │  - Interacts with the daemon via API               │    │
│  │                                                    │    │
│  └────────────────────────────────────────────────────┘    │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Docker Daemon (dockerd)

The Docker daemon is a background service that manages Docker objects such as images, containers, networks, and volumes. It listens for Docker API requests and handles all container-related tasks.

Real-world usage:

- Running as a system service: `systemctl status docker`
- Viewing logs: `journalctl -u docker.service`
- Configuring daemon parameters in `/etc/docker/daemon.json`

### REST API

Docker uses a RESTful API for communication between the client and daemon. This API can be used by applications to interact with Docker programmatically.

Real-world usage:

- Creating custom tools for Docker management
- Integrating Docker with CI/CD systems
- Developing container management platforms

### Docker CLI

The Docker CLI is the user-facing command-line interface for interacting with Docker. It sends commands to the daemon through the REST API.

Real-world usage:

- Running, managing, and inspecting containers
- Building and pushing images
- Setting up networks and volumes

## Docker Registry and Docker Hub

A Docker registry is a storage and distribution system for Docker images.

```
┌─────────────────────────────────────────────────────────────┐
│                 Docker Registry Workflow                    │
│                                                             │
│  ┌────────────┐   Push   ┌─────────────────────┐            │
│  │            │─────────►│                     │            │
│  │  Developers│          │  Docker Registry    │            │
│  │            │◄─────────│  (Public/Private)   │            │
│  └────────────┘   Pull   │                     │            │
│        ▲                 └─────────────────────┘            │
│        │                           ▲                        │
│        │      Pull                 │ Push                   │
│        │                           │                        │
│        ▼                           ▼                        │
│  ┌────────────┐           ┌─────────────────────┐           │
│  │            │           │                     │           │
│  │ Production │           │  CI/CD Systems      │           │
│  │            │           │                     │           │
│  └────────────┘           └─────────────────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Docker Hub

Docker Hub is the default public registry for Docker images, containing official images, community-contributed images, and private repositories.

Real-world usage:

- Accessing official images for popular technologies (e.g., `nginx`, `postgres`, `node`)
- Publishing custom images for distribution
- Setting up automated builds connected to GitHub/BitBucket repositories

```bash
# Pull an image from Docker Hub
docker pull nginx

# Push an image to Docker Hub
docker push username/my-image:tag

# Search for images
docker search ubuntu
```

### Private Registries

Organizations often use private registries to store proprietary images.

Real-world usage:

- Using cloud provider registries (AWS ECR, Google GCR, Azure ACR)
- Self-hosting with Docker Registry or alternatives like Harbor
- Implementing access control and security scanning

```bash
# Log in to a private registry
docker login registry.example.com

# Pull from private registry
docker pull registry.example.com/team/image:tag

# Tag and push to private registry
docker tag myapp:latest registry.example.com/team/myapp:latest
docker push registry.example.com/team/myapp:latest
```

## Docker Command Structure

Docker CLI commands follow a consistent structure:

```
docker [OPTIONS] COMMAND [ARGUMENTS]
```

```
┌─────────────────────────────────────────────────────────────┐
│                 Docker Command Structure                    │
│                                                             │
│  ┌────────────┐   ┌────────────┐   ┌────────────────────┐   │
│  │            │   │            │   │                    │   │
│  │   docker   │─► │  COMMAND   │─► │     ARGUMENTS      │   │
│  │            │   │            │   │                    │   │
│  └────────────┘   └────────────┘   └────────────────────┘   │
│                                                             │
│  Examples:                                                  │
│  docker run -p 8080:80 nginx                                │
│  docker build -t myapp:latest .                             │
│  docker volume create mydata                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Command Categories

Docker commands are organized into logical groups:

1. **Container Management**:

   - `run`, `start`, `stop`, `restart`, `kill`, `rm`, `ps`, `exec`

2. **Image Management**:

   - `build`, `pull`, `push`, `images`, `rmi`, `tag`

3. **Volume Management**:

   - `volume create`, `volume ls`, `volume rm`

4. **Network Management**:

   - `network create`, `network ls`, `network rm`

5. **System Commands**:

   - `info`, `version`, `system prune`

6. **Compose and Swarm**:
   - `compose`, `swarm`, `service`, `stack`

### Practical Examples

```bash
# Container Management
docker run -d -p 80:80 --name webserver nginx  # Run a container
docker ps                                       # List running containers
docker stop webserver                           # Stop a container
docker rm webserver                             # Remove a container

# Image Management
docker pull redis:latest                        # Pull an image
docker images                                   # List images
docker rmi redis:latest                         # Remove an image
docker build -t myapp:v1 .                      # Build an image

# System Management
docker system df                                # Show disk usage
docker system prune -a                          # Remove unused data
```

## Docker Container

A container is a lightweight, standalone, executable package that includes everything needed to run an application: code, runtime, system tools, libraries, and settings.

```
┌────────────────────────────────────────────────────────────┐
│                     Docker Container                       │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Application + Dependencies                         │   │
│  │                                                     │   │
│  │  ┌───────────────┐  ┌───────────────┐               │   │
│  │  │ Application   │  │ Libraries     │               │   │
│  │  │ Code          │  │ & Dependencies│               │   │
│  │  └───────────────┘  └───────────────┘               │   │
│  │                                                     │   │
│  │  ┌───────────────┐  ┌───────────────┐               │   │
│  │  │ File System   │  │ Environment   │               │   │
│  │  │ Snapshot      │  │ Variables     │               │   │
│  │  └───────────────┘  └───────────────┘               │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
│                  Docker Engine                             │
│                                                            │
│                    Host OS                                 │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Container Lifecycle

Containers follow a defined lifecycle from creation to removal:

```
┌────────────────────────────────────────────────────────────┐
│                 Container Lifecycle                        │
│                                                            │
│                                                            │
│     ┌──────────┐     ┌──────────┐     ┌──────────┐         │
│     │          │     │          │     │          │         │
│     │ Created  │────►│ Running  │────►│ Stopped  │         │
│     │          │     │          │     │          │         │
│     └──────────┘     └──────────┘     └────┬─────┘         │
│          ▲                                 │               │
│          │                                 │               │
│          │                                 ▼               │
│     ┌──────────┐                     ┌──────────┐          │
│     │          │                     │          │          │
│     │ Removed  │◄────────────────────│ Paused   │          │
│     │          │                     │          │          │
│     └──────────┘                     └──────────┘          │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Basic Container Operations

```bash
# Create and run a container
docker run -d --name web nginx

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop web

# Start a stopped container
docker start web

# Pause a container (freeze processes)
docker pause web

# Unpause a container
docker unpause web

# Remove a container
docker rm web

# Force remove a running container
docker rm -f web

# Execute a command in a running container
docker exec -it web bash
```

### Real-world Container Usage Examples

1. **Web Server**:

   ```bash
   docker run -d -p 80:80 --name webserver nginx
   ```

2. **Database Server**:

   ```bash
   docker run -d -p 5432:5432 \
     -e POSTGRES_PASSWORD=mysecretpassword \
     -v postgres_data:/var/lib/postgresql/data \
     --name db postgres
   ```

3. **Application with Health Check**:
   ```bash
   docker run -d --name myapp \
     --health-cmd="curl -f http://localhost/health || exit 1" \
     --health-interval=5s \
     --restart=unless-stopped \
     myapp:latest
   ```

## Docker Volumes/Bind Mounts

Docker containers are ephemeral—when a container is removed, all data within it is lost. Volumes and bind mounts provide persistent storage solutions.

```
┌─────────────────────────────────────────────────────────────┐
│               Docker Storage Options                        │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │                 │    │                 │                 │
│  │   Container 1   │    │   Container 2   │                 │
│  │                 │    │                 │                 │
│  └────────┬────────┘    └────────┬────────┘                 │
│           │                      │                          │
│           │                      │                          │
│           ▼                      ▼                          │
│  ┌────────────────┐    ┌────────────────┐   ┌────────────┐  │
│  │                │    │                │   │            │  │
│  │ Docker Volume  │    │  Bind Mount    │   │ tmpfs      │  │
│  │                │    │                │   │            │  │
│  └────────────────┘    └────────────────┘   └────────────┘  │
│          │                     │                            │
│          ▼                     ▼                            │
│  ┌────────────────┐    ┌────────────────┐                   │
│  │                │    │                │                   │
│  │Docker Managed  │    │   Host File    │                   │
│  │Storage         │    │   System       │                   │
│  │                │    │                │                   │
│  └────────────────┘    └────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Types of Docker Storage

1. **Volumes**: Managed by Docker, stored in the Docker filesystem area
2. **Bind Mounts**: Direct mapping to a path on the host filesystem
3. **tmpfs Mounts**: Stored in the host system's memory only (non-persistent)

### Understanding Docker Volumes

Volumes are the preferred mechanism for persisting data generated by and used by Docker containers. Some key characteristics of volumes include:

```
┌───────────────────────────────────────────────────────────────┐
│                  Docker Volume Lifecycle                      │
│                                                               │
│                                                               │
│  ┌─────────────┐       ┌─────────────┐       ┌─────────────┐  │
│  │             │       │             │       │             │  │
│  │ 1. Create   │──────►│ 2. Use in   │──────►│ 3. Persist  │  │
│  │    Volume   │       │  Container  │       │   Data      │  │
│  │             │       │             │       │             │  │
│  └─────────────┘       └─────────────┘       └─────────────┘  │
│         │                     ▲                    │          │
│         │                     │                    │          │
│         │                     │                    │          │
│         │                     │                    ▼          │
│  ┌─────────────┐              │              ┌─────────────┐  │
│  │             │              │              │             │  │
│  │ 4. Reuse    │──────────────┘              │ Container   │  │
│  │   Volume    │                             │ Removal     │  │
│  │             │                             │             │  │
│  └─────────────┘                             └─────────────┘  │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

**Benefits of Docker Volumes:**

1. **Decoupling container lifecycle from data:** Data persists even if the container is removed
2. **Sharing data between containers:** Multiple containers can mount the same volume
3. **Safer host filesystem access:** Containers only have access to designated volumes
4. **Volume drivers:** Support for remote storage, encryption, and other advanced features
5. **Better performance:** Volumes are often more efficient than bind mounts, especially on macOS and Windows
6. **Easier backup and migration:** Volumes can be backed up, restored, and moved between hosts

### Volume vs. Bind Mount Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│                    Storage Type Comparison                      │
│                                                                 │
│  ┌─────────────────────┐           ┌─────────────────────────┐  │
│  │    Docker Volume    │           │      Bind Mount         │  │
│  │                     │           │                         │  │
│  │ • Docker managed    │           │ • Host filesystem path  │  │
│  │ • Isolated location │           │ • Direct host mapping   │  │
│  │ • More portable     │           │ • Good for development  │  │
│  │ • Easier to backup  │           │ • Host controls content │  │
│  │ • Volume drivers    │           │ • Limited portability   │  │
│  │ • Best for prod     │           │ • IDE integration       │  │
│  └─────────────────────┘           └─────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Working with Volumes

```bash
# Create a named volume
docker volume create mydata

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect mydata

# Remove a volume
docker volume rm mydata

# Run a container with a volume
docker run -d \
  -v mydata:/app/data \
  --name myapp \
  myapp:latest

# Use a volume with specific options
docker run -d \
  -v mydata:/app/data:ro \  # Read-only mount
  --name myapp \
  myapp:latest
```

### Working with Bind Mounts

```bash
# Run a container with a bind mount
docker run -d \
  -v /host/path:/container/path \
  --name myapp \
  myapp:latest

# Modern syntax using --mount
docker run -d \
  --mount type=bind,source=/host/path,target=/container/path \
  --name myapp \
  myapp:latest
```

### Volume Persistence Scenarios

```
┌─────────────────────────────────────────────────────────────┐
│             Volume Persistence Demonstration                │
│                                                             │
│  ┌────────────────┐    ┌────────────────┐                   │
│  │                │    │                │                   │
│  │  Container 1   │    │  Container 2   │                   │
│  │  (Original)    │    │  (New)         │                   │
│  │                │    │                │                   │
│  └───────┬────────┘    └───────┬────────┘                   │
│          │                     │                            │
│          │      Removed        │     Created                │
│          │                     │                            │
│          ▼                     ▼                            │
│  ┌──────────────────────────────────────────────┐           │
│  │                                              │           │
│  │                Docker Volume                 │           │
│  │          (Data persists throughout)          │           │
│  │                                              │           │
│  └──────────────────────────────────────────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Persistence Test Workflow:

1. Create and run a container with a volume
2. Add or modify data in the volume
3. Stop and remove the container
4. Create a new container using the same volume
5. Verify the data is still present

### Real-world Volume Usage Examples

1. **Database Data Persistence**:

   ```bash
   docker run -d \
     -v postgres_data:/var/lib/postgresql/data \
     --name postgres \
     postgres:13
   ```

2. **Web Server Configuration**:

   ```bash
   docker run -d \
     -v /host/nginx/conf:/etc/nginx/conf.d \
     -p 80:80 \
     --name webserver \
     nginx
   ```

3. **Development Environment**:
   ```bash
   docker run -it \
     -v $(pwd):/app \
     -p 3000:3000 \
     --name dev \
     node:14 bash
   ```

### Docker Compose with Volumes

Using Docker Compose makes volume management more straightforward with declarative syntax:

```yaml
version: "3"
services:
  webapp:
    image: nginx
    volumes:
      - web-content:/usr/share/nginx/html
    ports:
      - "8080:80"

volumes:
  web-content:
    # By default, this creates a named volume
    # Optional: driver: local
```

### Best Practices for Docker Volumes

1. **Use named volumes for production data**: Named volumes are easier to manage and back up
2. **Use bind mounts for development**: Bind mounts make it easy to edit code and see changes immediately
3. **Use read-only volumes where possible**: Add `:ro` to volume mounts when containers only need read access
4. **Set proper ownership and permissions**: Ensure the container process has appropriate access to the volume
5. **Regular backups**: Use Docker volume backup commands or tools to protect your data
6. **Clean up unused volumes**: Run `docker volume prune` periodically to remove unused volumes

### Volume Backup and Restore

```
┌─────────────────────────────────────────────────────────────┐
│                  Volume Backup Process                      │
│                                                             │
│  ┌────────────────┐    ┌────────────────┐                   │
│  │                │    │                │                   │
│  │ Source Volume  │    │ Backup         │                   │
│  │                │    │ Container      │                   │
│  └───────┬────────┘    └───────┬────────┘                   │
│          │                     │                            │
│          │                     │                            │
│          ▼                     ▼                            │
│  ┌──────────────────────────────────────────────┐           │
│  │                                              │           │
│  │      Mount source volume and backup          │           │
│  │      to host or another volume               │           │
│  │                                              │           │
│  └──────────────────────────────────────────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Backing up a volume:

```bash
# Create a temporary container to back up the volume
docker run --rm -v mydata:/source -v $(pwd):/backup alpine tar -czf /backup/mydata-backup.tar.gz -C /source .
```

Restoring a volume:

```bash
# Create a new volume
docker volume create mydata-restored

# Create a temporary container to restore the volume
docker run --rm -v mydata-restored:/target -v $(pwd):/backup alpine sh -c "tar -xzf /backup/mydata-backup.tar.gz -C /target"
```

## Docker Network

Docker networking enables communication between containers and with the outside world.

```
┌───────────────────────────────────────────────────────────┐
│                    Docker Networking                      │
│                                                           │
│  ┌────────────────────────────────────────────────────┐   │
│  │                                                    │   │
│  │  Docker Host                                       │   │
│  │                                                    │   │
│  │  ┌─────────────┐      ┌─────────────┐              │   │
│  │  │             │      │             │              │   │
│  │  │ Container A │◄────►│ Container B │              │   │
│  │  │             │      │             │              │   │
│  │  └─────┬───────┘      └─────┬───────┘              │   │
│  │        │                    │                      │   │
│  │        └─────────┬──────────┘                      │   │
│  │                  │                                 │   │
│  │                  ▼                                 │   │
│  │  ┌─────────────────────────────────┐               │   │
│  │  │                                 │               │   │
│  │  │        Docker Network           │               │   │
│  │  │                                 │               │   │
│  │  └─────────────────┬───────────────┘               │   │
│  │                    │                               │   │
│  └────────────────────┼───────────────────────────────┘   │
│                       │                                   │
│                       ▼                                   │
│                   External                                │
│                   Network                                 │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Network Types

Docker provides several network drivers for different use cases:

1. **Bridge**: Default network driver, containers on the same bridge network can communicate
2. **Host**: Removes network isolation, container uses host's network directly
3. **None**: No networking (isolated containers)
4. **Overlay**: Connects multiple Docker daemons, enabling Swarm services to communicate
5. **Macvlan**: Assigns a MAC address to a container, making it appear as a physical device

### Network Commands

```bash
# List networks
docker network ls

# Create a network
docker network create mynetwork

# Inspect a network
docker network inspect mynetwork

# Connect a container to a network
docker network connect mynetwork container1

# Disconnect a container from a network
docker network disconnect mynetwork container1

# Remove a network
docker network rm mynetwork
```

### Real-world Network Usage Examples

1. **Web Application Stack**:

   ```bash
   # Create a custom network
   docker network create webapp-network

   # Run a database in the network
   docker run -d \
     --name db \
     --network webapp-network \
     -v db_data:/var/lib/mysql \
     -e MYSQL_ROOT_PASSWORD=secret \
     mysql:8.0

   # Run a web server in the same network
   docker run -d \
     --name web \
     --network webapp-network \
     -p 80:80 \
     webapp:latest
   ```

2. **Host Network for Maximum Performance**:

   ```bash
   docker run -d \
     --network host \
     --name nginx \
     nginx
   ```

3. **Exposing Multiple Ports**:

   ```bash
   docker run -d \
     -p 80:80 -p 443:443 \
     --name webserver \
     nginx
   ```

4. **Container DNS Resolution**:
   When using a custom network, containers can communicate using container names as hostnames:
   ```bash
   # In container1, you can ping container2 by name
   ping container2
   ```

## Docker Log

Docker provides a built-in logging mechanism to capture the standard output (stdout) and standard error (stderr) from containers, which is essential for monitoring and troubleshooting applications.

```
┌────────────────────────────────────────────────────────────┐
│                     Docker Logging                         │
│                                                            │
│  ┌─────────────┐                                           │
│  │             │  stdout/stderr                            │
│  │ Container   │─────────────┐                             │
│  │             │             │                             │
│  └─────────────┘             ▼                             │
│                      ┌─────────────────┐                   │
│                      │                 │                   │
│                      │  Docker Daemon  │                   │
│                      │                 │                   │
│                      └────────┬────────┘                   │
│                               │                            │
│                               │                            │
│                               ▼                            │
│  ┌────────────┐      ┌─────────────────┐                   │
│  │            │      │                 │                   │
│  │ docker logs│◄─────┤  Logging Driver │                   │
│  │            │      │                 │                   │
│  └────────────┘      └─────────────────┘                   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Viewing Container Logs

```bash
# Basic log viewing
docker logs container_name

# Follow logs in real-time (like tail -f)
docker logs -f container_name

# Show timestamps
docker logs -t container_name

# Show recent logs (last n lines)
docker logs --tail 100 container_name

# Show logs since a specific time
docker logs --since 2023-04-01T10:00:00 container_name

# Show logs until a specific time
docker logs --until 2023-04-01T11:00:00 container_name
```

### Logging Drivers

Docker supports multiple logging drivers to direct container logs to different destinations:

1. **json-file**: Default driver that stores logs as JSON files
2. **syslog**: Sends logs to syslog facility
3. **journald**: Sends logs to journald (systemd)
4. **fluentd**: Sends logs to fluentd collector
5. **awslogs**: Sends logs to Amazon CloudWatch
6. **splunk**: Sends logs to Splunk
7. **gelf**: Sends logs in GELF format to Graylog or Logstash

### Configuring Logging

```bash
# Run a container with a specific logging driver
docker run -d \
  --log-driver=syslog \
  --name myapp \
  myapp:latest

# Run a container with logging options
docker run -d \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  --name myapp \
  myapp:latest
```

### Real-world Logging Examples

1. **Log Rotation for Production**:

   ```bash
   docker run -d \
     --log-driver=json-file \
     --log-opt max-size=50m \
     --log-opt max-file=5 \
     --name webapp \
     webapp:latest
   ```

2. **Sending Logs to a Centralized Logger**:

   ```bash
   docker run -d \
     --log-driver=fluentd \
     --log-opt fluentd-address=192.168.1.100:24224 \
     --log-opt tag="docker.{{.Name}}" \
     --name myapp \
     myapp:latest
   ```

3. **Debugging with Real-time Logs**:

   ```bash
   # In one terminal, start the container
   docker run --name debugapp debugapp:latest

   # In another terminal, follow the logs
   docker logs -f debugapp
   ```

## Docker Stats/Memory-CPU Limitations

Docker allows you to monitor resource usage and set constraints on container resources to ensure efficient resource utilization.

```
┌────────────────────────────────────────────────────────────┐
│                Docker Resource Management                  │
│                                                            │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │                 │  │                 │                  │
│  │   Container A   │  │   Container B   │                  │
│  │   (2 CPU, 2GB)  │  │   (1 CPU, 1GB)  │                  │
│  │                 │  │                 │                  │
│  └────────┬────────┘  └────────┬────────┘                  │
│           │                    │                           │
│           │                    │                           │
│           ▼                    ▼                           │
│  ┌─────────────────────────────────────────────┐           │
│  │                                             │           │
│  │          cgroups (Control Groups)           │           │
│  │                                             │           │
│  └────────────────────┬────────────────────────┘           │
│                       │                                    │
│                       │                                    │
│                       ▼                                    │
│  ┌─────────────────────────────────────────────┐           │
│  │                                             │           │
│  │          Host System Resources              │           │
│  │          (CPU, Memory, Disk, Network)       │           │
│  │                                             │           │
│  └─────────────────────────────────────────────┘           │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Monitoring Container Resources

```bash
# Show resource usage for all running containers
docker stats

# Show stats for specific containers
docker stats container1 container2

# Show a single snapshot (non-streaming)
docker stats --no-stream
```

### Setting Resource Constraints

Docker uses cgroups (Control Groups) to limit resources available to containers:

```bash
# Memory Limits
docker run -d \
  --memory=1g \        # Maximum memory (1GB)
  --memory-reservation=750m \  # Soft limit (750MB)
  --memory-swap=1.5g \  # Memory + swap (1.5GB)
  --name myapp \
  myapp:latest

# CPU Limits
docker run -d \
  --cpus=1.5 \         # Maximum of 1.5 CPU cores
  --cpuset-cpus=0,1 \  # Use CPU cores 0 and 1 only
  --cpu-shares=512 \   # Relative CPU share weight
  --name myapp \
  myapp:latest

# I/O Limits
docker run -d \
  --device-write-bps /dev/sda:1mb \  # Limit write rate to 1MB/s
  --device-read-iops /dev/sda:1000 \ # Limit read operations to 1000 IOPS
  --name myapp \
  myapp:latest
```

### Real-world Resource Management Examples

1. **Database Container with Adequate Resources**:

   ```bash
   docker run -d \
     --name postgres \
     --memory=4g \
     --memory-reservation=2g \
     --cpus=2 \
     -v pg_data:/var/lib/postgresql/data \
     postgres:13
   ```

2. **Limiting Web Server Worker Processes**:

   ```bash
   docker run -d \
     --name nginx \
     --cpus=0.5 \
     --memory=256m \
     -p 80:80 \
     nginx
   ```

3. **Monitoring High-Load Containers**:
   ```bash
   # Run continuous monitoring on important containers
   watch "docker stats --no-stream app db cache"
   ```

## Docker Environment Variables

Environment variables are a key mechanism for configuring containerized applications, allowing you to pass configuration without modifying application code.

```
┌──────────────────────────────────────────────────────────┐
│              Docker Environment Variables                │
│                                                          │
│  ┌──────────────────────────────────────────────────┐    │
│  │                                                  │    │
│  │  Docker Container                                │    │
│  │                                                  │    │
│  │  ┌───────────────────────────────────────────┐   │    │
│  │  │                                           │   │    │
│  │  │  Application                              │   │    │
│  │  │                                           │   │    │
│  │  │  ┌─────────────────────────────────────┐  │   │    │
│  │  │  │                                     │  │   │    │
│  │  │  │  Environment Variables:             │  │   │    │
│  │  │  │  - DB_HOST=mysql                    │  │   │    │
│  │  │  │  - DB_PORT=3306                     │  │   │    │
│  │  │  │  - API_KEY=secret                   │  │   │    │
│  │  │  │  - LOG_LEVEL=info                   │  │   │    │
│  │  │  │                                     │  │   │    │
│  │  │  └─────────────────────────────────────┘  │   │    │
│  │  │                                           │   │    │
│  │  └───────────────────────────────────────────┘   │    │
│  │                                                  │    │
│  └──────────────────────────────────────────────────┘    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Setting Environment Variables

```bash
# Single environment variable
docker run -e VARIABLE=value myapp

# Multiple environment variables
docker run -e VAR1=value1 -e VAR2=value2 myapp

# From a file
docker run --env-file ./env.list myapp
```

### Environment Variable Sources

1. **Dockerfile**: Using the `ENV` instruction
2. **Command-line**: Using `-e` or `--env` flags
3. **Environment file**: Using `--env-file`
4. **Docker Compose**: In the `environment` or `env_file` sections

### Real-world Environment Variable Examples

1. **Database Configuration**:

   ```bash
   docker run -d \
     --name postgres \
     -e POSTGRES_USER=myapp \
     -e POSTGRES_PASSWORD=secret \
     -e POSTGRES_DB=myappdb \
     postgres:13
   ```

2. **Web Application Settings**:

   ```bash
   docker run -d \
     --name webapp \
     -e NODE_ENV=production \
     -e DB_HOST=db.example.com \
     -e DB_PORT=5432 \
     -e LOG_LEVEL=info \
     -e API_KEY=${API_KEY} \  # Use host environment variable
     webapp:latest
   ```

3. **Using an Environment File**:

   ```
   # Contents of env.file
   DB_HOST=db.internal
   DB_USER=app
   DB_PASS=secret
   CACHE_TTL=3600
   FEATURE_X_ENABLED=true
   ```

   ```bash
   docker run -d \
     --name app \
     --env-file ./env.file \
     myapp:latest
   ```

4. **Sensitive Data**:
   For sensitive information, consider using Docker secrets (with Docker Swarm) or external secret management solutions instead of environment variables.

   ```bash
   # Docker Swarm secrets (more secure than env vars)
   docker service create \
     --name app \
     --secret db_password \
     --secret api_key \
     myapp:latest
   ```

## Docker File

A Dockerfile is a text document containing instructions to build a Docker image. It specifies the base image, application code, dependencies, configurations, and commands to run.

```
┌─────────────────────────────────────────────────────────────┐
│                     Dockerfile                              │
│                                                             │
│  FROM node:14-alpine                                        │
│                                                             │
│  WORKDIR /app                                               │
│                                                             │
│  COPY package*.json ./                                      │
│                                                             │
│  RUN npm install                                            │
│                                                             │
│  COPY . .                                                   │
│                                                             │
│  EXPOSE 3000                                                │
│                                                             │
│  CMD ["npm", "start"]                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                           │
                           │  docker build
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                      Docker Image                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Common Dockerfile Instructions

| Instruction   | Description                                                         |
| ------------- | ------------------------------------------------------------------- |
| `FROM`        | Specifies the base image                                            |
| `WORKDIR`     | Sets the working directory                                          |
| `COPY`        | Copies files from host to image                                     |
| `ADD`         | Copies files with additional features (URL support, tar extraction) |
| `RUN`         | Executes commands during build                                      |
| `ENV`         | Sets environment variables                                          |
| `EXPOSE`      | Documents which ports the container listens on                      |
| `VOLUME`      | Creates a mount point for volumes                                   |
| `CMD`         | Default command when container starts                               |
| `ENTRYPOINT`  | Configures container to run as executable                           |
| `ARG`         | Defines build-time variables                                        |
| `LABEL`       | Adds metadata to the image                                          |
| `USER`        | Sets the user for subsequent instructions                           |
| `HEALTHCHECK` | Defines health check command                                        |

### Dockerfile Best Practices

1. **Use explicit tags for base images** (`FROM node:16.14.0` instead of `FROM node:latest`)
2. **Use multi-stage builds** to reduce image size
3. **Combine RUN instructions** with `&&` to reduce layers
4. **Use .dockerignore** to exclude unnecessary files
5. **Set non-root USER** for security
6. **Use proper HEALTHCHECK** for container health monitoring
7. **Minimize the number of layers** for better performance
8. **Clean up in the same RUN step** where packages are installed
9. **Use environment variables** for configurable values

### Real-world Dockerfile Examples

1. **Node.js Web Application**:

   ```dockerfile
   FROM node:16-alpine

   WORKDIR /app

   COPY package*.json ./

   RUN npm ci --only=production

   COPY . .

   USER node

   EXPOSE 3000

   HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
     CMD curl -f http://localhost:3000/health || exit 1

   CMD ["node", "server.js"]
   ```

2. **Multi-stage Build for Go Application**:

   ```dockerfile
   # Build stage
   FROM golang:1.18-alpine AS build

   WORKDIR /app

   COPY go.* ./
   RUN go mod download

   COPY . .
   RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server

   # Run stage
   FROM alpine:3.15

   RUN addgroup -S appgroup && adduser -S appuser -G appgroup

   WORKDIR /app

   COPY --from=build /app/server /app/
   COPY --from=build /app/config /app/config

   USER appuser

   EXPOSE 8080

   CMD ["/app/server"]
   ```

3. **Python Web Application with Virtual Environment**:

   ```dockerfile
   FROM python:3.10-slim

   WORKDIR /app

   RUN pip install --no-cache-dir poetry

   COPY pyproject.toml poetry.lock* ./

   RUN poetry config virtualenvs.create false \
       && poetry install --no-dev --no-interaction --no-ansi

   COPY . .

   EXPOSE 5000

   CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
   ```

## Docker Image

A Docker image is a read-only template used to create containers. Images contain the application code, libraries, dependencies, tools, and other files needed for an application to run.

```
┌────────────────────────────────────────────────────────────┐
│                     Docker Image                           │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Application Layer                                  │   │
│  │                                                     │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │                                                     │   │
│  │  Dependencies Layer                                 │   │
│  │                                                     │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │                                                     │   │
│  │  Runtime Layer                                      │   │
│  │                                                     │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │                                                     │   │
│  │  Base OS Layer                                      │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Image Management Commands

```bash
# List images
docker images

# Pull an image from a registry
docker pull nginx:latest

# Build an image from a Dockerfile
docker build -t myapp:1.0 .

# Tag an image
docker tag myapp:1.0 username/myapp:1.0

# Push an image to a registry
docker push username/myapp:1.0

# Remove an image
docker rmi myapp:1.0

# Show image history (layers)
docker history myapp:1.0

# Inspect image details
docker inspect myapp:1.0

# Search for images on Docker Hub
docker search nginx
```

### Image Layers and Cache

Docker images consist of multiple read-only layers. When building images, Docker caches layers for faster builds.

```
┌────────────────────────────────────────────────────────────┐
│               Docker Image Layers                          │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Layer 4: COPY application code     [NEW]           │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Layer 3: RUN npm install          [CACHED]         │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Layer 2: COPY package.json        [CACHED]         │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Layer 1: FROM node:16-alpine      [CACHED]         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Real-world Image Management Examples

1. **Tagging with Semantic Versioning**:

   ```bash
   # Build with specific version tags
   docker build -t myapp:1.2.3 .
   docker tag myapp:1.2.3 myapp:1.2
   docker tag myapp:1.2.3 myapp:1
   docker tag myapp:1.2.3 myapp:latest
   ```

2. **Creating Production-Optimized Images**:

   ```bash
   # Build with build arguments
   docker build \
     --build-arg NODE_ENV=production \
     --build-arg VERSION=1.2.3 \
     -t myapp:production .
   ```

3. **Image Cleanup**:

   ```bash
   # Remove dangling images (untagged)
   docker image prune

   # Remove all unused images
   docker image prune -a
   ```

## Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. It uses a YAML file to configure application services, networks, and volumes.

```
┌───────────────────────────────────────────────────────────┐
│                   Docker Compose                          │
│                                                           │
│  docker-compose.yml                                       │
│  ┌────────────────────────────────────────────────────┐   │
│  │  version: '3'                                      │   │
│  │                                                    │   │
│  │  services:                                         │   │
│  │    web:                                            │   │
│  │      image: nginx                                  │   │
│  │      ports:                                        │   │
│  │        - "80:80"                                   │   │
│  │                                                    │   │
│  │    app:                                            │   │
│  │      build: ./app                                  │   │
│  │      depends_on:                                   │   │
│  │        - db                                        │   │
│  │                                                    │   │
│  │    db:                                             │   │
│  │      image: postgres                               │   │
│  │      volumes:                                      │   │
│  │        - db-data:/var/lib/postgresql/data          │   │
│  │                                                    │   │
│  │  volumes:                                          │   │
│  │    db-data:                                        │   │
│  └────────────────────────────────────────────────────┘   │
│                           │                               │
│                           │  docker-compose up            │
│                           ▼                               │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐     │
│  │             │    │             │    │            │     │
│  │ Web         │    │ App         │    │ Database   │     │
│  │ Container   │    │ Container   │    │ Container  │     │
│  │             │    │             │    │            │     │
│  └─────────────┘    └─────────────┘    └────────────┘     │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Docker Compose Commands

```bash
# Start services
docker-compose up

# Start services in detached mode
docker-compose up -d

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs
docker-compose logs

# Follow logs
docker-compose logs -f

# Build or rebuild services
docker-compose build

# Start specific service
docker-compose up -d service-name

# Execute command in a running service
docker-compose exec service-name command

# View running services
docker-compose ps
```

### Docker Compose File Structure

```yaml
version: "3.8"

services:
  service-name:
    image: image-name
    build: ./path/to/dockerfile
    ports:
      - "host-port:container-port"
    volumes:
      - volume-name:/container/path
      - ./host/path:/container/path
    environment:
      - KEY=VALUE
    networks:
      - network-name
    depends_on:
      - other-service
    restart: policy

volumes:
  volume-name:

networks:
  network-name:
```

### Real-world Docker Compose Examples

1. **Web Application with Database and Cache**:

   ```yaml
   version: "3.8"

   services:
     web:
       build: ./frontend
       ports:
         - "80:80"
       depends_on:
         - api

     api:
       build: ./backend
       ports:
         - "3000:3000"
       environment:
         - DB_HOST=db
         - REDIS_HOST=cache
       depends_on:
         - db
         - cache

     db:
       image: postgres:13
       volumes:
         - db_data:/var/lib/postgresql/data
       environment:
         - POSTGRES_PASSWORD=password
         - POSTGRES_USER=myapp
         - POSTGRES_DB=myapp

     cache:
       image: redis:6-alpine
       volumes:
         - redis_data:/data

   volumes:
     postgres_data:
     redis_data:
   ```

2. **Development Environment with Hot Reload**:

   ```yaml
   version: "3.8"

   services:
     frontend:
       build:
         context: ./frontend
         dockerfile: Dockerfile.dev
       ports:
         - "3000:3000"
       volumes:
         - ./frontend:/app
         - /app/node_modules
       environment:
         - REACT_APP_API_URL=http://localhost:8000

     backend:
       build:
         context: ./backend
         dockerfile: Dockerfile.dev
       ports:
         - "8000:8000"
       volumes:
         - ./backend:/app
         - /app/node_modules
       environment:
         - DEBUG=True
         - DB_HOST=db
       depends_on:
         - db

     db:
       image: postgres:13
       volumes:
         - dev_db_data:/var/lib/postgresql/data
       environment:
         - POSTGRES_PASSWORD=devpassword
         - POSTGRES_USER=devuser
         - POSTGRES_DB=devdb
       ports:
         - "5432:5432"

   volumes:
     dev_db_data:
   ```

3. **Production-Ready Microservices**:

   ```yaml
   version: "3.8"

   services:
     traefik:
       image: traefik:v2.4
       ports:
         - "80:80"
         - "443:443"
       volumes:
         - /var/run/docker.sock:/var/run/docker.sock
       command:
         - "--providers.docker=true"
         - "--providers.docker.swarmMode=true"
         - "--entrypoints.web.address=:80"
         - "--api.insecure=true"
       deploy:
         placement:
           constraints:
             - node.role == manager
       networks:
         - traefik_net

     frontend:
       image: myapp/frontend:latest
       deploy:
         replicas: 3
         update_config:
           parallelism: 1
           delay: 10s
         labels:
           - "traefik.enable=true"
           - "traefik.http.routers.frontend.rule=Host(`myapp.example.com`)"
           - "traefik.http.services.frontend.loadbalancer.server.port=80"
       networks:
         - traefik_net
         - backend_net

     api:
       image: myapp/api:latest
       deploy:
         replicas: 3
         update_config:
           parallelism: 1
           delay: 10s
         labels:
           - "traefik.enable=true"
           - "traefik.http.routers.api.rule=Host(`api.example.com`)"
           - "traefik.http.services.api.loadbalancer.server.port=8000"
       networks:
         - traefik_net
         - backend_net

     db:
       image: postgres:13
       environment:
         - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
       volumes:
         - db_data:/var/lib/postgresql/data
       deploy:
         placement:
           constraints:
             - node.labels.data == true
       secrets:
         - db_password
       networks:
         - backend_net

   networks:
     traefik_net:
     backend_net:

   volumes:
     db_data:

   secrets:
     db_password:
       external: true
   ```

## Docker Swarm

Docker Swarm is Docker's native clustering and orchestration solution that turns a group of Docker hosts into a single virtual Docker host.

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Swarm                            │
│                                                             │
│  ┌─────────────┐                 ┌─────────────┐            │
│  │             │                 │             │            │
│  │  Manager    │◄───────────────►│  Manager    │            │
│  │  Node       │                 │  Node       │            │
│  │             │                 │             │            │
│  └─────┬───────┘                 └──────┬──────┘            │
│        │                                │                   │
│        │                                │                   │
│        │                                │                   │
│        ▼                                ▼                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │             │    │             │    │             │      │
│  │  Worker     │    │  Worker     │    │  Worker     │      │
│  │  Node       │    │  Node       │    │  Node       │      │
│  │             │    │             │    │             │      │
│  └─────────────┘    └─────────────┘    └─────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Swarm Architecture

Docker Swarm consists of two types of nodes:

1. **Manager Nodes**: Handle cluster management and API operations
2. **Worker Nodes**: Run containers and services

Key Swarm features:

- **Cluster management** integrated with Docker Engine
- **Declarative service model** for defining desired application state
- **Service scaling** to increase or decrease replicas
- **Multi-host networking** with overlay networks
- **Service discovery** with built-in DNS
- **Load balancing** across services
- **Rolling updates** for zero-downtime deployments
- **Secret management** for sensitive data

### Setting Up a Swarm

```bash
# Initialize a swarm on the first node
docker swarm init --advertise-addr <MANAGER-IP>

# The above command outputs a token for workers to join

# On worker nodes, join the swarm
docker swarm join --token <TOKEN> <MANAGER-IP>:2377

# List nodes in the swarm
docker node ls

# Promote a worker to manager
docker node promote <NODE-ID>

# Demote a manager to worker
docker node demote <NODE-ID>

# Leave the swarm
docker swarm leave --force
```

### Node Management

```bash
# List all nodes
docker node ls

# Inspect a node
docker node inspect <NODE-ID>

# Update node availability
docker node update --availability drain <NODE-ID>  # Prevents scheduling new tasks
docker node update --availability active <NODE-ID>  # Allows scheduling new tasks

# Add labels to nodes
docker node update --label-add region=east <NODE-ID>
```

### Real-world Swarm Usage Examples

1. **Setting Up a Fault-Tolerant Swarm**:

   ```bash
   # On first manager
   docker swarm init --advertise-addr 192.168.1.10

   # Get manager token
   docker swarm join-token manager

   # Add other managers (total 3 or 5 for high availability)
   # On second and third manager nodes, using the token from above
   docker swarm join --token <MANAGER-TOKEN> 192.168.1.10:2377

   # Get worker token
   docker swarm join-token worker

   # Add workers
   # On worker nodes
   docker swarm join --token <WORKER-TOKEN> 192.168.1.10:2377
   ```

2. **Node Labeling for Placement Control**:

   ```bash
   # Label nodes by hardware capability
   docker node update --label-add ssd=true node1
   docker node update --label-add gpu=true node2
   docker node update --label-add memory=high node3

   # Use constraints when deploying services
   docker service create \
     --constraint 'node.labels.ssd == true' \
     --name db \
     postgres
   ```

## Docker Stack / Docker Service

Docker services and stacks provide higher-level abstractions for deploying, scaling, and managing containers in a Swarm environment.

```
┌───────────────────────────────────────────────────────────┐
│                 Docker Service and Stack                  │
│                                                           │
│                                                           │
│    ┌───────────────────────────────────────────────┐      │
│    │ Docker Stack                                  │      │
│    │                                               │      │
│    │  ┌─────────────┐  ┌─────────────┐             │      │
│    │  │             │  │             │             │      │
│    │  │  Service A  │  │  Service B  │             │      │
│    │  │ (5 replicas)│  │ (3 replicas)│             │      │
│    │  │             │  │             │             │      │
│    │  └─────────────┘  └─────────────┘             │      │
│    │                                               │      │
│    │  ┌──────────────────────────────────┐         │      │
│    │  │                                  │         │      │
│    │  │  Overlay Network                 │         │      │
│    │  │                                  │         │      │
│    │  └──────────────────────────────────┘         │      │
│    │                                               │      │
│    │  ┌──────────────────────────────────┐         │      │
│    │  │                                  │         │      │
│    │  │  Volumes & Secrets               │         │      │
│    │  │                                  │         │      │
│    │  └──────────────────────────────────┘         │      │
│    │                                               │      │
│    └───────────────────────────────────────────────┘      │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Docker Services

A service is the definition of tasks to execute on Swarm nodes. When you create a service, you specify which container image to use and which commands to execute inside the containers.

```bash
# Create a service
docker service create \
  --name webapp \
  --replicas 3 \
  --publish 80:80 \
  nginx

# List services
docker service ls

# Inspect a service
docker service inspect webapp

# View service logs
docker service logs webapp

# Scale a service
docker service scale webapp=5

# Update a service
docker service update \
  --image nginx:1.19 \
  --update-parallelism 2 \
  --update-delay 10s \
  webapp

# Remove a service
docker service rm webapp
```

### Docker Stack

A stack is a collection of services that make up an application in a specific environment. Stacks are defined using Compose files and deployed with the `docker stack` command.

```bash
# Deploy a stack from a Compose file
docker stack deploy -c docker-compose.yml myapp

# List stacks
docker stack ls

# List services in a stack
docker stack services myapp

# List tasks in a stack
docker stack ps myapp

# Remove a stack
docker stack rm myapp
```

### Stack Compose File (docker-compose.yml)

Stack Compose files are similar to regular Compose files but include Swarm-specific features:

```yaml
version: "3.8"

services:
  web:
    image: nginx:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    ports:
      - "80:80"
    networks:
      - frontend

  api:
    image: myapi:latest
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role == worker
    networks:
      - frontend
      - backend

  db:
    image: postgres:13
    deploy:
      placement:
        constraints:
          - node.labels.db == true
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - backend
    secrets:
      - db_password

networks:
  frontend:
  backend:

volumes:
  db_data:

secrets:
  db_password:
    external: true
```

### Real-world Stack Examples

1. **Web Application Stack with Load Balancing**:

   ```yaml
   version: "3.8"

   services:
     traefik:
       image: traefik:v2.4
       ports:
         - "80:80"
         - "8080:8080"
       volumes:
         - /var/run/docker.sock:/var/run/docker.sock
       command:
         - "--providers.docker=true"
         - "--providers.docker.swarmMode=true"
         - "--entrypoints.web.address=:80"
         - "--api.insecure=true"
       deploy:
         placement:
           constraints:
             - node.role == manager
       networks:
         - traefik_net

     frontend:
       image: myapp/frontend:latest
       deploy:
         replicas: 3
         update_config:
           parallelism: 1
           delay: 10s
         labels:
           - "traefik.enable=true"
           - "traefik.http.routers.frontend.rule=Host(`myapp.example.com`)"
           - "traefik.http.services.frontend.loadbalancer.server.port=80"
       networks:
         - traefik_net
         - backend_net

     api:
       image: myapp/api:latest
       deploy:
         replicas: 3
         update_config:
           parallelism: 1
           delay: 10s
         labels:
           - "traefik.enable=true"
           - "traefik.http.routers.api.rule=Host(`api.example.com`)"
           - "traefik.http.services.api.loadbalancer.server.port=8000"
       networks:
         - traefik_net
         - backend_net

     db:
       image: postgres:13
       environment:
         - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
       volumes:
         - db_data:/var/lib/postgresql/data
       deploy:
         placement:
           constraints:
             - node.labels.data == true
       secrets:
         - db_password
       networks:
         - backend_net

   networks:
     traefik_net:
     backend_net:

   volumes:
     db_data:

   secrets:
     db_password:
       external: true
   ```

2. **Global Service Deployment**:

   ```yaml
   version: "3.8"

   services:
     monitoring_agent:
       image: prom/node-exporter:latest
       deploy:
         mode: global # Runs one instance on every swarm node
       volumes:
         - /proc:/host/proc:ro
         - /sys:/host/sys:ro
         - /:/rootfs:ro
       command:
         - "--path.procfs=/host/proc"
         - "--path.sysfs=/host/sys"
         - "--path.rootfs=/rootfs"
       networks:
         - monitoring

     prometheus:
       image: prom/prometheus:latest
       deploy:
         placement:
           constraints:
             - node.role == manager
       ports:
         - "9090:9090"
       volumes:
         - prometheus_data:/prometheus
         - ./prometheus.yml:/etc/prometheus/prometheus.yml
       networks:
         - monitoring

     grafana:
       image: grafana/grafana:latest
       deploy:
         placement:
           constraints:
             - node.role == manager
       ports:
         - "3000:3000"
       volumes:
         - grafana_data:/var/lib/grafana
       networks:
         - monitoring

   networks:
     monitoring:

   volumes:
     prometheus_data:
     grafana_data:
   ```

3. **High-Availability Database Cluster**:

   ```yaml
   version: "3.8"

   services:
     pg_master:
       image: bitnami/postgresql:13
       environment:
         - POSTGRESQL_REPLICATION_MODE=master
         - POSTGRESQL_USERNAME=postgres
         - POSTGRESQL_PASSWORD_FILE=/run/secrets/db_password
         - POSTGRESQL_DATABASE=app_db
         - POSTGRESQL_REPLICATION_USER=repl_user
         - POSTGRESQL_REPLICATION_PASSWORD_FILE=/run/secrets/repl_password
       volumes:
         - pg_master_data:/bitnami/postgresql
       deploy:
         placement:
           constraints:
             - node.labels.db_role == master
       networks:
         - db_network
       secrets:
         - db_password
         - repl_password

     pg_replica:
       image: bitnami/postgresql:13
       environment:
         - POSTGRESQL_REPLICATION_MODE=slave
         - POSTGRESQL_MASTER_HOST=pg_master
         - POSTGRESQL_MASTER_PORT_NUMBER=5432
         - POSTGRESQL_USERNAME=postgres
         - POSTGRESQL_PASSWORD_FILE=/run/secrets/db_password
         - POSTGRESQL_REPLICATION_USER=repl_user
         - POSTGRESQL_REPLICATION_PASSWORD_FILE=/run/secrets/repl_password
       volumes:
         - pg_replica_data:/bitnami/postgresql
       deploy:
         replicas: 2
         placement:
           constraints:
             - node.labels.db_role == replica
       networks:
         - db_network
       secrets:
         - db_password
         - repl_password

   networks:
     db_network:

   volumes:
     pg_master_data:
     pg_replica_data:

   secrets:
     db_password:
       external: true
     repl_password:
       external: true
   ```

## Docker Buildx and BuildKit

Docker Buildx is a CLI plugin that extends the Docker build capabilities with BuildKit, providing advanced features for building, caching, and creating multi-platform images.

```
┌────────────────────────────────────────────────────────────┐
│                    Docker Buildx                           │
│                                                            │
│  ┌────────────────────────────────────────────────────┐    │
│  │                                                    │    │
│  │  Docker CLI                                        │    │
│  │                                                    │    │
│  └────────────────────────┬───────────────────────────┘    │
│                           │                                │
│                           │                                │
│                           ▼                                │
│  ┌────────────────────────────────────────────────────┐    │
│  │                                                    │    │
│  │  Buildx Plugin  ───────────► BuildKit Engine       │    │
│  │                                                    │    │
│  └────────────────────────────────────────────────────┘    │
│                                                            │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                       │ │
│  │  Multi-Platform    Improved Caching   Parallel Builds │ │
│  │  ARM/AMD/Intel       Shared Cache      Efficient      │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Key Features of Buildx

1. **Multi-Platform Builds**: Create images for different architectures (AMD64, ARM64, etc.) from a single build command
2. **Enhanced Build Cache**: More efficient layer caching for faster builds
3. **Concurrent Building**: Run multiple build stages in parallel
4. **Exporters**: Export build results in various formats (Docker image, OCI image, local directory)
5. **Custom Builder Instances**: Create and manage different builder environments

### Installing and Setting Up Buildx

Buildx comes included with Docker Desktop. For Linux installations, you may need to install it separately:

```bash
# Download the latest binary
curl -LO https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-amd64

# Make it executable and move to the Docker CLI plugins directory
mkdir -p ~/.docker/cli-plugins
mv buildx-v0.8.2.linux-amd64 ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx

# Verify installation
docker buildx version
```

### Using Buildx for Multi-Platform Images

```bash
# Create a new builder instance
docker buildx create --name mybuilder --use

# Inspect the builder
docker buildx inspect mybuilder

# Bootstrap the builder
docker buildx inspect --bootstrap

# Build and push multi-platform images
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t username/myapp:latest \
  --push .
```

### Buildx with Build Arguments and Cache

```bash
# Build with build arguments and caching
docker buildx build \
  --build-arg VERSION=1.0.0 \
  --cache-from type=registry,ref=username/myapp:cache \
  --cache-to type=registry,ref=username/myapp:cache,mode=max \
  -t username/myapp:latest \
  --push .
```

### Real-world Buildx Examples

1. **Multi-Architecture Microservice**:

   ```bash
   # Create builder with multi-platform support
   docker buildx create --name multiplatform-builder --use

   # Build for multiple platforms
   docker buildx build \
     --platform linux/amd64,linux/arm64 \
     -t username/api-service:v1.2.0 \
     --push .
   ```

2. **Optimized Build Pipeline with Caching**:

   ```bash
   # Create a build pipeline with caching for CI/CD
   docker buildx build \
     --cache-from type=registry,ref=username/webapp:cache \
     --cache-to type=registry,ref=username/webapp:cache,mode=max \
     --build-arg NODE_ENV=production \
     -t username/webapp:latest \
     --push .
   ```

3. **Custom BuildKit Configuration**:

   Create a `buildkitd.toml` file:

   ```toml
   [worker.oci]
     max-parallelism = 4

   [registry."docker.io"]
     mirrors = ["mirror.gcr.io"]
     http = true
   ```

   Use the custom configuration:

   ```bash
   docker buildx create --config buildkitd.toml --name custom-builder --use
   docker buildx build -t username/myapp:latest .
   ```

### Buildx in CI/CD Pipelines

Buildx is particularly valuable in CI/CD workflows for creating portable multi-architecture images:

```yaml
# GitHub Actions workflow example
name: Build and Push Docker Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v1

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: username/myapp:latest
          cache-from: type=registry,ref=username/myapp:cache
          cache-to: type=registry,ref=username/myapp:cache,mode=max
```

### Buildx with Kubernetes

Buildx can use Kubernetes for distributed building:

```bash
# Create a builder using Kubernetes
docker buildx create \
  --driver kubernetes \
  --driver-opt namespace=buildkit,image=moby/buildkit:master \
  --name k8s-builder

# Use the builder
docker buildx use k8s-builder

# Build with Kubernetes-based builder
docker buildx build -t username/myapp:latest .
```

Buildx with BuildKit represents the next generation of Docker image building, offering significant improvements in build speed, flexibility, and multi-platform support compared to traditional Docker builds.

## Practice Labs

This repository includes a series of hands-on lab exercises to help you master Docker concepts through practical examples. Each lab focuses on specific Docker features and provides step-by-step instructions.

### Lab 1: Docker FastAPI Tutorial

[Go to Lab 1](/Lab1)

Learn how to containerize a FastAPI application using Docker and Docker Compose. This lab covers:

- Building and running containers with Docker CLI
- Using Docker Compose for development
- Volume mounting for live code changes
- Understanding Dockerfile structure and best practices

### Lab 2: Docker Persistent Volume Demo

[Go to Lab 2](/Lab2)

Explore Docker volumes for data persistence using an Nginx web server example. This lab demonstrates:

- Creating and managing Docker volumes
- Bind mounts vs. named volumes
- Data persistence across container lifecycle
- Volume commands and management techniques

### Lab 3: Docker Networking Examples

[Go to Lab 3](/Lab3)

Comprehensive guide to Docker networking with multiple scenarios. This lab covers:

- Bridge, host, none, overlay, and macvlan network types
- Custom bridge networks for container communication
- DNS resolution between containers
- Network isolation and security
- Multi-host networking with Docker Swarm

### Lab 4: Docker Multi-Stage Build Examples

[Go to Lab 4](/Lab4)

Master multi-stage builds to create efficient, secure Docker images. This lab includes examples for:

- Go applications with scratch images
- Node.js application builds
- Python applications with poetry
- Java Spring Boot applications
- Size optimization techniques

### Lab 5: Docker Image Management

[Go to Lab 5](/Lab5)

Learn various Docker image management techniques and best practices. This lab covers:

- Different Dockerfile strategies (basic, multi-stage, non-root)
- Image saving, loading, and distribution
- Security best practices for Docker images
- Docker Hub interaction
- Pushing and pulling images

### Lab 6: Docker Swarm Examples

[Go to Lab 6](/Lab6)

Explore Docker's built-in orchestration with Swarm mode. This lab demonstrates:

- Setting up a Docker Swarm cluster
- Deploying various service types
- Multi-service applications
- Global service deployment
- Service scaling and updates
- High availability configurations

### Lab 7: Docker Bake and BuildKit Advanced Features

[Go to Lab 7](/Lab7)

Master advanced Docker build techniques with Docker Bake and BuildKit. This lab covers:

- Multi-target build configurations using Docker Bake
- Different Bake file formats (HCL, JSON, YAML)
- Development vs. production build targets
- Custom build arguments and variables
- Multi-stage builds with inheritance
- Docker Compose integration with Bake
- Build output targeting options
- Interactive build selection

### Lab 8: LocalStack for Local Cloud Development

[Go to Lab 8](/Lab8)

Learn how to use LocalStack to emulate AWS services for local development and testing. This lab covers:

- Setting up LocalStack as a cloud service emulator
- Running AWS applications locally without a remote AWS account
- Configuring Docker Compose for LocalStack integration
- Working with emulated AWS services like S3, SQS, and Lambda
- Deploying applications to LocalStack using AWS CDK
- Troubleshooting common LocalStack configuration issues
- Development workflow with local cloud resources

#### Known Issues and Fixes

1. **Docker Compose Command Issue**:

   - **Problem**: The example uses `docker-compose` command which is deprecated in newer Docker versions.
   - **Fix**: Use `docker compose` (without the hyphen) instead. The `local-deploy.sh` script has been updated to use the new command format.

2. **Port Conflict**:

   - **Problem**: The default nginx configuration uses port 80 which might be already in use on your system.
   - **Fix**: Updated `docker-compose.yml` to use port 8080 instead of 80 for the nginx service.

3. **LocalStack Volume Issue**:

   - **Problem**: The LocalStack container fails to start due to "Device or resource busy" error with the mounted volume.
   - **Fix**: Remove the following volume configuration from the LocalStack service in `docker-compose.yml`:
     ```yaml
     - DATA_DIR=/tmp/localstack/data # Remove this environment variable
     - "localstack_data:/tmp/localstack/data" # Remove this volume mapping
     ```
   - Also remove the `localstack_data:` entry from the volumes section.

4. **LocalStack Service Limitations**:

   - **Problem**: The free version of LocalStack doesn't support ECR services which are required for the full CDK deployment.
   - **Solution**: For complete functionality, consider using LocalStack Pro or deploying to an actual AWS environment.

5. **Node.js Version Compatibility**:

   - **Problem**: The CDK deployment requires Node.js version 14.15.0 or later, but the scripts may be run on an older version.
   - **Solution**: Update to a compatible Node.js version (18.x recommended) before running the CDK deployment.

6. **API Endpoints and NGINX Rewrite Mismatch**:
   - **Problem**: The messaging queue functionality fails because of a mismatch between the backend API endpoints and NGINX URL rewriting.
   - **Fix**: Update the endpoints in backend/server.js to match what NGINX is sending after the rewrite (change from `/api/messages` to just `/messages`), then rebuild the backend container.

### Running the Example

After applying the fixes above, you can run the example with:

```bash
cd lab8
docker compose up -d  # Start all services including LocalStack
./local-deploy.sh     # Deploy to LocalStack (note: ECR features require LocalStack Pro)
```

Access the application at http://localhost:8080 and the LocalStack services at http://localhost:4566.

### Cleaning Up

When you're done with the Lab8 example, you can clean up all resources with:

```bash
cd lab8
./cleanup.sh  # Automated cleanup of all resources
```

Or manually:

```bash
cd lab8
docker compose down --volumes --remove-orphans  # Remove all containers, networks, and volumes
```

For a more thorough cleanup including images and LocalStack resources, see the detailed cleanup instructions in the [Lab8 README](lab8/README.md#clean-up).

Each lab contains its own detailed README with instructions, explanations, and diagrams. Work through them sequentially for a comprehensive Docker learning experience.
