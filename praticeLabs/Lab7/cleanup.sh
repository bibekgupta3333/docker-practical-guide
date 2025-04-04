#!/bin/bash

# Print banner
echo "====================================="
echo "Docker Bake Example - Cleanup Script"
echo "====================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running!"
  echo "Please start Docker and try again."
  exit 1
fi

echo "This script will clean up all Docker resources created by the Lab7 example."
echo "It will remove:"
echo "  - Running containers for this project"
echo "  - Images built for this project"
echo "  - Local node_modules in the app directory"
echo ""
read -p "Are you sure you want to continue? (y/n): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Cleanup aborted."
  exit 0
fi

echo ""
echo "🔍 Looking for running containers..."

# Stop any running containers from docker-compose
echo "📥 Stopping docker-compose services..."
docker compose down 2>/dev/null
echo "✅ Docker Compose services stopped"

# Remove any containers with the docker-bake-example or lab7 image names
echo "📥 Removing containers using our images..."
docker ps -a | grep -E 'docker-bake-example|docker-bake-test|lab7-app' | awk '{print $1}' | xargs docker rm -f 2>/dev/null || true
echo "✅ Containers removed"

echo ""
echo "🔍 Looking for project images..."

# Remove docker-bake-example images
echo "📥 Removing docker-bake-example images..."
docker images | grep 'docker-bake-example' | awk '{print $1":"$2}' | xargs docker rmi -f 2>/dev/null || true
docker images | grep 'docker-bake-test' | awk '{print $1":"$2}' | xargs docker rmi -f 2>/dev/null || true
docker images | grep 'lab7-app' | awk '{print $1":"$2}' | xargs docker rmi -f 2>/dev/null || true
docker images | grep 'myregistry.io/docker-bake-example' | awk '{print $1":"$2}' | xargs docker rmi -f 2>/dev/null || true
echo "✅ Images removed"

# Clean up node_modules locally
echo ""
echo "🔍 Checking for local node_modules..."
if [ -d "app/node_modules" ]; then
  echo "📥 Removing local node_modules..."
  rm -rf app/node_modules
  echo "✅ Local node_modules removed"
else
  echo "ℹ️ No local node_modules found"
fi

# Clean dangling images and build cache
echo ""
echo "📥 Cleaning up Docker build cache..."
docker builder prune -f --filter "until=24h" 2>/dev/null || true
echo "✅ Build cache cleaned"

echo ""
echo "📥 Cleaning up dangling images..."
docker image prune -f 2>/dev/null || true
echo "✅ Dangling images removed"

echo ""
echo "🎉 Cleanup complete!"
echo ""
echo "To start fresh, you can run:"
echo "  ./quick-start.sh"
echo ""