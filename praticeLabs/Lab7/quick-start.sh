#!/bin/bash

# Print banner
echo "====================================="
echo "Docker Bake Example - Quick Start"
echo "====================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running!"
  echo "Please start Docker and try again."
  exit 1
fi

# Check if buildx is available
if ! docker buildx version > /dev/null 2>&1; then
  echo "Warning: Docker Buildx not available."
  echo "Docker Bake commands may not work."
else
  echo "✅ Docker Buildx is available"
fi

# Set BuildKit environment variables
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

echo "✅ BuildKit enabled"
echo ""

# Ask user what to start
echo "What would you like to do?"
echo "1) Run development environment with Docker Compose"
echo "2) Run production environment with Docker Compose"
echo "3) Build with Docker Bake (HCL)"
echo "4) Run locally without Docker"
echo "q) Quit"
read -p "Enter your choice (1-4 or q): " choice

case $choice in
  1)
    echo "Starting development environment..."
    docker compose up app
    ;;
  2)
    echo "Starting production environment..."
    docker compose up app-prod
    ;;
  3)
    echo "Building with Docker Bake..."
    echo "Which target would you like to build?"
    echo "1) Development (app-dev)"
    echo "2) Production (app-prod)"
    echo "3) All targets"
    read -p "Enter your choice (1-3): " bake_choice
    
    case $bake_choice in
      1)
        docker buildx bake -f docker-bake.hcl app-dev
        ;;
      2)
        docker buildx bake -f docker-bake.hcl app-prod
        ;;
      3)
        docker buildx bake -f docker-bake.hcl all
        ;;
      *)
        echo "Invalid choice"
        exit 1
        ;;
    esac
    ;;
  4)
    echo "Running locally without Docker..."
    cd app
    if [ ! -d "node_modules" ]; then
      echo "Installing dependencies..."
      npm install
    fi
    npm run dev
    ;;
  q)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo "Done!" 