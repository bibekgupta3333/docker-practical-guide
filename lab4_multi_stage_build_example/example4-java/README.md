# Java Spring Boot Multi-Stage Build Example

This example demonstrates a multi-stage build for a Java Spring Boot application, separating the build environment from the runtime environment.

## The Scenario

This example shows how to:

1. Build a Java Spring Boot application with Maven in a dedicated build stage
2. Create a minimal runtime image using only the JRE
3. Reduce the final image size from ~500MB to ~200MB
4. Improve build performance with Maven dependency caching

## Multi-Stage Build Explanation

The Dockerfile contains two stages:

### Stage 1: Builder

- Uses `maven:3.9-eclipse-temurin-17` as the base image (includes JDK and Maven)
- Copies and resolves Maven dependencies separately for better layer caching
- Builds the application into a single executable JAR
- Contains the full development environment and build tools

### Stage 2: Runtime

- Uses `eclipse-temurin:17-jre-alpine` as a minimal base image with only the JRE
- Copies only the built JAR file from the builder stage
- Results in a much smaller final image
- Contains only what's needed to run the application

## Benefits

- **Smaller image size**: Final image only contains the JRE and the application JAR
- **Improved security**: Build tools and source code not in the final image
- **Better build performance**: Maven dependencies cached in Docker layers
- **Faster deployment**: Smaller images transfer and start faster

## How to Build and Run

Using Docker CLI:

```bash
docker build -t java-multistage .
docker run -p 8080:8080 java-multistage
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

Or open http://localhost:8080 in your browser.
