# Docker Bake Example Project

This project demonstrates the use of Docker Bake for building containerized applications with multiple configurations. Docker Bake is a feature of BuildKit that allows you to define complex build configurations using HCL, JSON, or YAML files.

## Quick Start

For the easiest way to get started, use the quick-start script:

```bash
./quick-start.sh
```

This script provides an interactive menu to:

- Run development environment with Docker Compose
- Run production environment with Docker Compose
- Build with Docker Bake
- Run locally without Docker

## Cleanup

To clean up all Docker resources created by this project, use the cleanup script:

```bash
./cleanup.sh
```

This script will:
- Stop and remove Docker containers
- Remove Docker images
- Clean up local node_modules
- Prune Docker build cache and dangling images

## Project Structure

```
Lab7/
├── app/
│   ├── index.js            # Simple Express.js application
│   ├── package.json        # Node.js dependencies
│   └── run-local.sh        # Script to run app locally
├── Dockerfile              # Multi-stage Dockerfile
├── docker-compose.yml      # Docker Compose configuration
├── docker-bake.hcl         # HCL format Docker Bake file
├── docker-bake.json        # JSON format Docker Bake file
├── docker-bake.yaml        # YAML format Docker Bake file
├── .dockerignore           # Files to exclude from Docker build
├── quick-start.sh          # Interactive startup script
├── cleanup.sh              # Cleanup script to remove Docker resources
└── README.md               # This file
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   Docker Bake Process                   │
└───────────────┬─────────────────────────┬───────────────┘
                │                         │
                ▼                         ▼
┌───────────────────────────┐  ┌───────────────────────────┐
│      Development Build    │  │     Production Build      │
│  ┌─────────────────────┐  │  │  ┌─────────────────────┐  │
│  │   Base Image        │  │  │  │   Base Image        │  │
│  │   (node:18-alpine)  │  │  │  │   (node:18-alpine)  │  │
│  └──────────┬──────────┘  │  │  └──────────┬──────────┘  │
│             │             │  │             │             │
│             ▼             │  │             ▼             │
│  ┌─────────────────────┐  │  │  ┌─────────────────────┐  │
│  │  Development Image  │  │  │  │  Production Build   │  │
│  │  - All dependencies │  │  │  │  - Prune dev deps   │  │
│  │  - Source code      │  │  │  │  - Optimize         │  │
│  └─────────────────────┘  │  │  └──────────┬──────────┘  │
└───────────────────────────┘  │             │             │
                               │             ▼             │
                               │  ┌─────────────────────┐  │
                               │  │  Production Image   │  │
                               │  │  - Minimal image    │  │
                               │  │  - Only prod deps   │  │
                               │  └─────────────────────┘  │
                               └───────────────────────────┘
```

## Prerequisites

Before you begin, make sure you have the following installed:

1. **Docker Engine** - Version 19.03 or newer (with BuildKit enabled)
2. **Docker Buildx** - Required for Docker Bake functionality
3. **Docker Compose** - For running multi-container setups

To check if Docker is running:

```bash
docker info
```

To enable BuildKit (if not already enabled):

```bash
# For Linux/macOS (add to your shell profile)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# For Windows PowerShell
$env:DOCKER_BUILDKIT=1
$env:COMPOSE_DOCKER_CLI_BUILD=1
```

## Docker Bake Formats

This example showcases three different formats for Docker Bake files:

1. **HCL Format** (docker-bake.hcl): The standard and most flexible format.
2. **JSON Format** (docker-bake.json): Compatible with JSON tooling, good for programmatic generation.
3. **YAML Format** (docker-bake.yaml): Human-readable alternative, good for YAML-based infrastructures.

## Application

A simple Node.js Express application that:

- Returns a JSON response with a message, environment information, and timestamp
- Uses different configurations for development, production, and test environments

## Instructions

### Using Docker CLI

Before using Docker Bake, you can try a simple build to ensure Docker is working properly:

```bash
docker build -t docker-bake-test --target development .
docker run -p 3000:3000 docker-bake-test
```

Visit http://localhost:3000 in your browser to see the app running.

#### Building with Docker Bake

Build the development image:

```bash
# Using the HCL file
docker buildx bake -f docker-bake.hcl app-dev

# Using the JSON file
docker buildx bake -f docker-bake.json app-dev

# Using the YAML file
docker buildx bake -f docker-bake.yaml app-dev
```

Build the production image:

```bash
docker buildx bake -f docker-bake.hcl app-prod
```

Build all targets:

```bash
docker buildx bake -f docker-bake.hcl all
```

Override variables when building:

```bash
docker buildx bake -f docker-bake.hcl --set VERSION=2.0.0 --set REGISTRY=mycompany app-prod
```

Run the development image:

```bash
docker run -p 3000:3000 myregistry.io/docker-bake-example:dev
```

### Using Docker Compose

> **Note:** This example uses Docker Compose V2. Use `docker compose` (without hyphen) instead of `docker-compose` command. In docker-compose.yml, the `version` attribute is obsolete in Compose V2 and should be removed to avoid warnings.

Start the development environment:

```bash
docker compose up app
```

Start the production environment:

```bash
docker compose up app-prod
```

Start both environments:

```bash
docker compose up
```

## Troubleshooting

### Common Issues

1. **Docker daemon not running**

   ```
   Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
   ```

   Solution: Start the Docker Desktop application or the Docker service.

2. **BuildKit not enabled**

   ```
   buildx not found: buildx is a Docker plugin. Try 'docker buildx'
   ```

   Solution: Make sure you have Docker Buildx installed and BuildKit is enabled.

3. **Port already in use**

   ```
   Error starting userland proxy: listen tcp4 0.0.0.0:3000: bind: address already in use
   ```

   Solution: Change the port mapping in the docker-compose.yml file or when running the container.

4. **Node modules issues**
   If you encounter npm errors, try rebuilding the image with the `--no-cache` option:
   ```bash
   docker build --no-cache -t docker-bake-test --target development .
   ```

## Benefits of Docker Bake

1. **Parameterization**: Define variables that can be overridden at build time
2. **Inheritance**: Reuse and extend configuration across targets
3. **Grouping**: Define groups of targets to build together
4. **Platform Support**: Easily build for multiple platforms
5. **Integration**: Works with Docker Compose and Docker BuildKit

## When to Use Each Format

- **HCL**: When you need the most flexibility and features
- **JSON**: When your tooling or CI/CD system works best with JSON
- **YAML**: When you prefer YAML syntax or have a YAML-based infrastructure

## Docker Bake vs Docker Compose

While Docker Compose focuses on defining and running multi-container applications, Docker Bake focuses on building images with complex configurations.

Docker Compose can use images built by Docker Bake to run your application in different environments.

## Advanced Topics

- **Cache Mounting**: Improve build performance with cache mounts
- **Secret Management**: Use secrets securely in your builds
- **CI/CD Integration**: Integrate Docker Bake into your CI/CD pipelines
- **Custom BuildKit Frontends**: Extend Docker Bake with custom frontends

## Local Development without Docker

If you want to run the application locally without Docker:

```bash
cd app
npm install
npm run dev
```

The application will be available at http://localhost:3000.

## Cross-check Fixes

The following issues were identified and fixed during cross-checking:

1. **Docker Compose V2 Compatibility**:

   - Updated all commands from `docker-compose` to `docker compose` (without hyphen)
   - Removed the obsolete `version: "3.8"` from docker-compose.yml

2. **npm Installation Improvements**:
   - Using `npm install` instead of `npm ci --quiet` in the Dockerfile since we don't have a package-lock.json file

These changes ensure that the project runs smoothly with the latest versions of Docker and Docker Compose.
