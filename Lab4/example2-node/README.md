# Node.js Multi-Stage Build Example

This example demonstrates a multi-stage build for a Node.js application, separating the development/build environment from the production runtime.

## The Scenario

This example shows how to:

1. Install all dependencies (including dev dependencies) in a build stage
2. Create a production image with only production dependencies
3. Reduce the final image size by excluding development tools and dependencies

## Multi-Stage Build Explanation

The Dockerfile contains two stages:

### Stage 1: Builder

- Uses `node:18-alpine` as the base image
- Installs all dependencies including development dependencies
- May perform build steps for TypeScript/transpiled applications (commented out in this example)
- Prepares the application code

### Stage 2: Production

- Uses `node:18-alpine` as the base image, but with a clean slate
- Sets NODE_ENV to production
- Installs only production dependencies
- Copies only the necessary files from the builder stage
- Creates a lean runtime environment

## Benefits

- **Smaller image size**: No dev dependencies in the final image
- **Improved security**: Build tools and test frameworks not in production
- **Better separation of concerns**: Build and runtime concerns isolated
- **Production-optimized**: NODE_ENV=production improves performance

## How to Build and Run

Using Docker CLI:

```bash
docker build -t node-multistage .
docker run -p 3000:3000 node-multistage
```

Using Docker Compose:

```bash
docker-compose up
```

## Testing the Application

Once running, access the application:

```bash
curl http://localhost:3000
```

Or open http://localhost:3000 in your browser.
