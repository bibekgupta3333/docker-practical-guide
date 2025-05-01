# Go Multi-Stage Build Example

This example demonstrates a multi-stage build for a Go application, resulting in a minimal Docker image based on `scratch`.

## The Scenario

This example shows how to:

1. Build a Go application in a full Go development environment
2. Create a minimal production image using `scratch` (empty base image)
3. Reduce the final image size from ~300MB to less than 10MB

## Multi-Stage Build Explanation

The Dockerfile contains two stages:

### Stage 1: Builder

- Uses `golang:1.21-alpine` as the base image
- Sets up the build environment and dependencies
- Compiles the Go application with optimizations
- Results in a statically-linked binary

### Stage 2: Runtime

- Uses `scratch` (empty) as the base image
- Copies only the compiled binary from the builder stage
- Copies SSL certificates for HTTPS support
- Creates a minimal runtime environment

## Benefits

- **Extremely small image size**: Final image is less than 10MB compared to ~300MB
- **Reduced attack surface**: No shell, package manager, or unnecessary tools
- **Improved security**: Only the application binary is included in the final image
- **Faster deployment**: Smaller images transfer faster in container registries

## How to Build and Run

Using Docker CLI:

```bash
docker build -t go-multistage .
docker run -p 8080:8080 go-multistage
```

Using Docker Compose:

```bash
docker-compose up
```

## Testing the Application

Once running, access the application:

```bash
curl http://localhost:8080
```
