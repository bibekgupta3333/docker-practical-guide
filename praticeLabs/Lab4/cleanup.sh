#!/bin/bash

echo "Cleaning up Docker resources from Lab4 examples..."

# Stop and remove any running containers from our examples
echo "Stopping and removing containers..."
docker-compose down 2>/dev/null || true
docker stop go-app node-app python-app java-app 2>/dev/null || true
docker rm go-app node-app python-app java-app 2>/dev/null || true

# Remove the images
echo "Removing Docker images..."
docker rmi go-multistage node-multistage python-multistage java-multistage 2>/dev/null || true
docker rmi lab4_go-app lab4_node-app lab4_python-app lab4_java-app 2>/dev/null || true

# Remove any dangling images
echo "Removing dangling images..."
docker image prune -f

echo "Cleanup complete!" 