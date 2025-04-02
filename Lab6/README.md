# Docker Swarm Examples

This repository demonstrates different types of Docker Swarm deployments with a simple Node.js application. Docker Swarm is Docker's native clustering and orchestration solution that turns a group of Docker hosts into a single virtual Docker host.

## Table of Contents

- [Overview](#overview)
- [Docker Swarm Architecture](#docker-swarm-architecture)
- [Example Scenarios](#example-scenarios)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [Using Docker CLI](#using-docker-cli)
  - [Using Docker Compose](#using-docker-compose)
  - [Using the Helper Scripts](#using-the-helper-scripts)
- [Testing](#testing)
- [Node.js Application](#nodejs-application)
- [Monitoring and Scaling](#monitoring-and-scaling)
- [Cleanup](#cleanup)

## Overview

This project demonstrates three common Docker Swarm scenarios:

1. **Basic Service Deployment** - Single replicated service deployment
2. **Multi-Service Application** - Frontend, backend, and database services working together
3. **Global Service Deployment** - Services that run on every node in the swarm

## Docker Swarm Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Swarm Cluster                   │
│                                                             │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐    │
│  │  Manager 1  │     │  Manager 2  │     │  Manager 3  │    │
│  │ (Leader)    │     │ (Reachable) │     │ (Reachable) │    │
│  └─────────────┘     └─────────────┘     └─────────────┘    │
│         │                  │                   │            │
│         └──────────────────┼───────────────────┘            │
│                            │                                │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐    │
│  │  Worker 1   │     │  Worker 2   │     │  Worker 3   │    │
│  │             │     │             │     │             │    │
│  └─────────────┘     └─────────────┘     └─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Docker Swarm consists of:

- **Manager Nodes**: Responsible for cluster management and orchestration
- **Worker Nodes**: Execute containers
- **Services**: Define the tasks to run on the swarm
- **Tasks**: Individual containers running on worker nodes

## Example Scenarios

### 1. Basic Service Deployment

```
┌─────────────────────────┐
│   Node.js Web Service   │
│  (Multiple Replicas)    │
└─────────────────────────┘
```

A simple web service deployed with multiple replicas for high availability.

### 2. Multi-Service Application

```
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│  Frontend     │     │  Backend API  │     │  Database     │
│  (3 replicas) │────▶│  (3 replicas) │────▶│  (1 replica)  │
└───────────────┘     └───────────────┘     └───────────────┘
```

A typical three-tier application with:

- Frontend service (React/Node.js)
- Backend API service (Node.js)
- Database service (MongoDB)

### 3. Global Service Deployment

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Swarm Cluster                   │
│                                                             │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐    │
│  │  Node 1     │     │  Node 2     │     │  Node 3     │    │
│  │ ┌──────────┐│     │ ┌──────────┐│     │ ┌──────────┐│    │
│  │ │Monitoring││     │ │Monitoring││     │ │Monitoring││    │
│  │ │Service   ││     │ │Service   ││     │ │Service   ││    │
│  │ └──────────┘│     │ └──────────┘│     │ └──────────┘│    │
│  └─────────────┘     └─────────────┘     └─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

A monitoring service deployed globally to run on every node in the swarm.

## Prerequisites

- Docker Engine (version 19.03 or higher)
- Multiple machines for creating a true swarm (can use virtual machines)
- Basic understanding of Docker concepts

## Setup Instructions

### Using Docker CLI

#### 1. Initialize a Docker Swarm

On the manager node:

```bash
# Initialize a new swarm (on the manager node)
docker swarm init --advertise-addr <MANAGER-IP>

# You'll get a command to run on worker nodes to join the swarm
# It will look like this:
# docker swarm join --token <TOKEN> <MANAGER-IP>:2377
```

#### 2. Join Worker Nodes to the Swarm

On each worker node:

```bash
# Run the join command that was output when initializing the swarm
docker swarm join --token <TOKEN> <MANAGER-IP>:2377
```

#### 3. Deploy Services

**Basic Service Deployment:**

```bash
# Deploy the Node.js service with 3 replicas
docker service create --name nodejs-service \
  --replicas 3 \
  --publish 3000:3000 \
  nodejs-app:latest
```

**Multi-Service Application:**

```bash
# Create an overlay network for the application
docker network create --driver overlay app-network

# Deploy MongoDB service
docker service create --name mongo \
  --network app-network \
  --mount type=volume,source=mongo-data,destination=/data/db \
  mongo:latest

# Deploy Backend API service
docker service create --name backend \
  --network app-network \
  --replicas 3 \
  --env MONGO_URL=mongodb://mongo:27017/appdb \
  nodejs-backend:latest

# Deploy Frontend service
docker service create --name frontend \
  --network app-network \
  --replicas 3 \
  --publish 8080:80 \
  --env API_URL=http://backend:3000 \
  nodejs-frontend:latest
```

**Global Service Deployment:**

```bash
# Deploy a monitoring service on every node
docker service create --name node-monitor \
  --mode global \
  --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock \
  node-monitor:latest
```

### Using Docker Compose

Create a docker-compose.yml file for deploying services to a swarm.

#### 1. Initialize the Swarm (same as above)

#### 2. Deploy Stack with Docker Compose

```bash
# Deploy the stack using docker-compose.yml
docker stack deploy -c docker-compose.yml app-stack
```

### Using the Helper Scripts

This repository includes helper scripts to make it easier to set up and manage Docker Swarm examples.

#### Setup Script

The `setup-swarm.sh` script helps to initialize a Docker Swarm and deploy the examples:

```bash
# Make the script executable
chmod +x setup-swarm.sh

# Show usage information
./setup-swarm.sh --help

# Initialize a new swarm
./setup-swarm.sh init

# Deploy the basic service example
./setup-swarm.sh deploy-basic

# Deploy the multi-service application example
./setup-swarm.sh deploy-multi

# Deploy the global service example
./setup-swarm.sh deploy-global

# Remove all services and leave the swarm
./setup-swarm.sh destroy
```

#### Cleanup Script

The `cleanup.sh` script provides more granular control over cleaning up Docker resources:

```bash
# Make the script executable
chmod +x cleanup.sh

# Show usage information
./cleanup.sh --help

# Remove all services
./cleanup.sh services

# Remove all stacks
./cleanup.sh stacks

# Remove all overlay networks
./cleanup.sh networks

# Remove all volumes
./cleanup.sh volumes

# Remove all example images
./cleanup.sh images

# Stop and remove all containers
./cleanup.sh containers

# Leave the swarm
./cleanup.sh swarm

# Run all cleanup operations
./cleanup.sh all

# Use force flag to skip confirmation
./cleanup.sh --force all
```

## Testing

The repository includes a test script to verify that the Docker Swarm examples are working correctly in a single-node environment.

### Test Script

The `test-swarm.sh` script can be used to test different deployment scenarios:

```bash
# Make the script executable
chmod +x test-swarm.sh

# Show usage information
./test-swarm.sh help

# Test the basic service deployment
./test-swarm.sh basic

# Test the multi-service application
./test-swarm.sh multi

# Test the global service deployment
./test-swarm.sh global

# Test all deployment scenarios sequentially
./test-swarm.sh all
```

The test script will:

1. Check if Docker is running and if the machine is in swarm mode
2. Initialize a swarm if necessary using local loopback address (127.0.0.1)
3. Deploy the specified services
4. Check if the services are healthy
5. Make a test request to verify the service is accessible
6. Clean up by removing the services

> Note: The test script requires the `jq` tool for JSON output formatting. If `jq` is not installed, the script will still work but JSON output won't be formatted.

## Node.js Application

The repository includes a simple Node.js application that can be used with these Docker Swarm examples. The application consists of:

- A basic HTTP server
- Health check endpoints
- Simple API functionality

See the app directory for source code and Dockerfile.

## Monitoring and Scaling

### View Services and Nodes

```bash
# List all services in the swarm
docker service ls

# View details of a specific service
docker service inspect --pretty <SERVICE-NAME>

# List all nodes in the swarm
docker node ls
```

### Scale Services

```bash
# Scale a service to 5 replicas
docker service scale <SERVICE-NAME>=5
```

### Service Logs

```bash
# View logs for a service
docker service logs <SERVICE-NAME>
```

## Cleanup

Using Docker CLI directly:

```bash
# Remove a service
docker service rm <SERVICE-NAME>

# Remove a stack
docker stack rm <STACK-NAME>

# Leave the swarm (on worker nodes)
docker swarm leave

# Force leave and remove node (on manager node)
docker node rm <NODE-ID>

# Leave swarm and remove all services (on manager node)
docker swarm leave --force
```

Using the provided scripts:

```bash
# Using setup-swarm.sh
./setup-swarm.sh destroy

# Using cleanup.sh
./cleanup.sh all
```

See the [Using the Helper Scripts](#using-the-helper-scripts) section for more details on cleanup operations.
