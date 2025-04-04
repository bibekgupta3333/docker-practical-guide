# Docker Multi-Stage Build Examples

This lab demonstrates different types of Docker multi-stage builds across various programming languages and scenarios. Multi-stage builds allow you to use multiple FROM statements in your Dockerfile, where each FROM instruction can use a different base image.

## What is a Multi-Stage Build?

Multi-stage builds use multiple `FROM` statements in a single Dockerfile. Each `FROM` instruction begins a new stage of the build process. You can selectively copy artifacts from one stage to another, leaving behind everything you don't need in the final image.

```
┌─────────────────────────┐     ┌────────────────────────┐
│  Stage 1: Build Stage   │     │  Stage 2: Final Image  │
│                         │     │                        │
│ ┌─────────────────────┐ │     │ ┌────────────────────┐ │
│ │ - Build tools       │ │     │ │ - Runtime only     │ │
│ │ - Dependencies      │ │     │ │ - Minimal footprint│ │
│ │ - Source code       │ │     │ │ - Application      │ │
│ │ - Compile/build     │ │     │ │   artifacts only   │ │
│ └─────────────────────┘ │     │ └────────────────────┘ │
└──────────┬──────────────┘     └────────────┬───────────┘
           │                                 │
           │    COPY --from=build-stage      │
           └────────────────────────────────►
```

## Key Benefits

1. **Smaller Images**: Final images only contain what's needed for the application to run

   ```
   ┌───────────────────┐    ┌───────────────┐
   │ Traditional Build │ vs │ Multi-Stage   │
   │ 500-1000MB        │    │ 5-200MB       │
   └───────────────────┘    └───────────────┘
   ```

2. **Improved Security**: Build tools and dependencies don't make it into the final image

   ```
   ┌───────────────────────┐    ┌──────────────────────┐
   │ Traditional Image     │    │ Multi-Stage Image    │
   │ ┌─────────────────┐   │    │ ┌────────────────┐   │
   │ │ Your App        │   │    │ │ Your App       │   │
   │ ├─────────────────┤   │    │ ├────────────────┤   │
   │ │ Runtime         │   │    │ │ Runtime        │   │
   │ ├─────────────────┤   │    │ └────────────────┘   │
   │ │ Build Tools ⚠️   │   │    │                      │
   │ ├─────────────────┤   │    │                      │
   │ │ Dev Dependencies│   │    │                      │
   │ ├─────────────────┤   │    │                      │
   │ │ OS Utilities    │   │    │                      │
   │ └─────────────────┘   │    │                      │
   └───────────────────────┘    └──────────────────────┘
   ```

3. **Better CI/CD Integration**: Complex build processes are encapsulated in the Dockerfile
4. **Simpler Development Experience**: Developers don't need to install language-specific build tools locally

## Multi-Stage Build Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Source Code    │     │  Build Process  │     │  Final Image    │
│  Repository     │──►  │  (Stage 1)      │──►  │  (Stage 2)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │                         │
                              ▼                         ▼
                        ┌──────────────┐        ┌──────────────┐
                        │ Development  │        │ Production   │
                        │ Dependencies │        │ Deployment   │
                        └──────────────┘        └──────────────┘
```

## Examples Overview

- **Example 1: Go Application** - Demonstrates building a Go binary in one stage and creating a minimal image using scratch
- **Example 2: Node.js Application** - Shows how to build a Node.js app with npm and create a production image without dev dependencies
- **Example 3: Python Application** - Illustrates building a Python app with poetry and creating a lean production image
- **Example 4: Java Spring Boot Application** - Demonstrates building a Java application with Maven and creating a minimal JRE image

## Architecture Diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           Multi-Stage Build Examples                      │
│                                                                           │
│  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────────────┐  │
│  │   Go Example    │   │  Node Example   │   │      Python Example     │  │
│  │                 │   │                 │   │                         │  │
│  │ ┌─────────────┐ │   │ ┌─────────────┐ │   │ ┌─────────────────────┐ │  │
│  │ │ Stage 1:    │ │   │ │ Stage 1:    │ │   │ │ Stage 1:            │ │  │
│  │ │ golang:1.21 │ │   │ │ node:18     │ │   │ │ python:3.10 + poetry│ │  │
│  │ └─────────────┘ │   │ └─────────────┘ │   │ └─────────────────────┘ │  │
│  │        │        │   │        │        │   │           │             │  │
│  │        ▼        │   │        ▼        │   │           ▼             │  │
│  │ ┌─────────────┐ │   │ ┌─────────────┐ │   │ ┌─────────────────────┐ │  │
│  │ │ Stage 2:    │ │   │ │ Stage 2:    │ │   │ │ Stage 2: (Optional) │ │  │
│  │ │ scratch     │ │   │ │ node:18     │ │   │ │ Development         │ │  │
│  │ └─────────────┘ │   │ └─────────────┘ │   │ └─────────────────────┘ │  │
│  │                 │   │                 │   │           │             │  │
│  └─────────────────┘   └─────────────────┘   │           ▼             │  │
│                                              │ ┌─────────────────────┐ │  │
│  ┌─────────────────────────────────────┐     │ │ Stage 3:            │ │  │
│  │         Java Example                │     │ │ python:3.10-slim    │ │  │
│  │                                     │     │ └─────────────────────┘ │  │
│  │ ┌─────────────────────────────────┐ │     └─────────────────────────┘  │
│  │ │ Stage 1:                        │ │                                  │
│  │ │ maven:3.9-eclipse-temurin-17    │ │                                  │
│  │ └─────────────────────────────────┘ │                                  │
│  │                 │                   │                                  │
│  │                 ▼                   │                                  │
│  │ ┌─────────────────────────────────┐ │                                  │
│  │ │ Stage 2:                        │ │                                  │
│  │ │ amazoncorretto:17-alpine        │ │                                  │
│  │ └─────────────────────────────────┘ │                                  │
│  └─────────────────────────────────────┘                                  │
└───────────────────────────────────────────────────────────────────────────┘
```

## Size Comparison

| Example | Base Image Size | Final Image Size | Reduction |
| ------- | --------------- | ---------------- | --------- |
| Go      | ~300MB          | ~5MB             | ~98%      |
| Node.js | ~300MB          | ~200MB           | ~33%      |
| Python  | ~400MB          | ~200MB           | ~50%      |
| Java    | ~500MB          | ~200MB           | ~60%      |

## Running the Examples

### Using Docker CLI

For each example, navigate to the respective directory and run:

```bash
# Build the image
docker build -t example-name .

# Run the container
docker run -p <host-port>:<container-port> example-name
```

Specific commands for each example:

**Example 1: Go Application**

```bash
cd example1-go
docker build -t go-multistage .
docker run -p 8080:8080 go-multistage
```

**Example 2: Node.js Application**

```bash
cd example2-node
docker build -t node-multistage .
docker run -p 3000:3000 node-multistage
```

**Example 3: Python Application**

```bash
cd example3-python
docker build -t python-multistage .
docker run -p 5001:5000 python-multistage
```

**Example 4: Java Application**

```bash
cd example4-java
docker build -t java-multistage .
docker run -p 8081:8080 java-multistage
```

### Using Docker Compose

Each example directory contains a `docker-compose.yml` file. To run with Docker Compose:

```bash
cd example-directory
docker compose up
```

Or to run all examples at once from the Lab4 directory:

```bash
docker compose up
```

## Multi-Stage Build Techniques Illustrated

### 1. Named Stages

```dockerfile
FROM node:18-alpine AS builder
# ... build commands here
FROM node:18-alpine AS production
COPY --from=builder /app/dist /app
```

### 2. Selective Copying

```dockerfile
# Only copy what you need
COPY --from=builder /go/bin/app /app
```

### 3. Using Different Base Images

```dockerfile
# Build stage uses full SDK
FROM golang:1.21-alpine AS builder
# Runtime stage uses minimal image
FROM scratch
```

### 4. Build Optimizations

```dockerfile
# Caching dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B
# Then copy source code
COPY src ./src
```

## Testing and Cleanup

Use the provided scripts to test and clean up:

```bash
# Test all examples individually
./test-all.sh

# Test all examples with docker compose
./test-compose.sh

# Clean up all containers and images
./cleanup.sh
```
