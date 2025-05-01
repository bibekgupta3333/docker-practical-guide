# Stage 1: Build the Go binary
FROM golang:1.21-alpine AS builder

# Set working directory
WORKDIR /app

# Copy go module files first for better caching
COPY go.mod ./
# If you had go.sum, you would copy it here too
# COPY go.sum ./

# Download dependencies (will be cached if go.mod doesn't change)
RUN go mod download

# Copy the source code
COPY . .

# Build the Go binary with optimizations
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/app

# Stage 2: Create the minimal runtime image
FROM scratch

# Copy only the binary from the builder stage
COPY --from=builder /go/bin/app /app

# Copy CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Set the binary as the entrypoint
ENTRYPOINT ["/app"]

# Expose the port the app runs on
EXPOSE 8080 