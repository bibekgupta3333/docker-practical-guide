#!/bin/bash
# This script cleans up all Docker resources created in the Lab5 examples

echo "=== Docker Lab5 Cleanup Script ==="
echo

# Stop and remove all running containers from docker-compose
echo "Stopping and removing Docker Compose containers..."
docker compose down

# Remove any standalone containers from manual runs
echo "Removing any standalone containers..."
docker rm -f $(docker ps -a -q --filter "ancestor=docker-example:basic" --filter "ancestor=docker-example:multistage" --filter "ancestor=docker-example:nonroot" 2>/dev/null) 2>/dev/null || true

# Remove the Docker images
echo "Removing Docker images..."
docker rmi -f docker-example:basic docker-example:multistage docker-example:nonroot lab5-app lab5-app-multistage lab5-app-nonroot 2>/dev/null || true

# Remove Docker Hub tagged images if they exist
echo "Removing Docker Hub tagged images (if any)..."
docker rmi -f $(docker images --format "{{.Repository}}:{{.Tag}}" | grep "docker-example") 2>/dev/null || true

# Remove the saved tar file
echo "Removing saved Docker image tar files..."
rm -f docker-example-basic.tar 2>/dev/null || true

# Clean up unused Docker resources
echo "Pruning unused Docker resources..."
docker system prune -f

echo
echo "Cleanup complete!"
echo "If you want to completely remove all Docker resources (including resources from other projects), you can run:"
echo "docker system prune -a --volumes -f"
echo 