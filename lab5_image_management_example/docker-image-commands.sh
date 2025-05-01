#!/bin/bash
# This script demonstrates Docker image management commands
# Note: Run commands individually, not the entire script at once

# Build images from different Dockerfiles
echo "Building images..."
docker build -t docker-example:basic -f Dockerfile.basic .
docker build -t docker-example:multistage -f Dockerfile.multistage .
docker build -t docker-example:nonroot -f Dockerfile.nonroot .

# List images
echo "Listing images..."
docker images

# Save an image to a tar file
echo "Saving image to file..."
docker save -o docker-example-basic.tar docker-example:basic

# Remove the image to demonstrate loading
echo "Removing image to demonstrate loading..."
docker rmi docker-example:basic

# Load the image back from the tar file
echo "Loading image from file..."
docker load -i docker-example-basic.tar

# Tag image for Docker Hub
echo "Tagging image for Docker Hub..."
# Replace 'username' with your Docker Hub username
docker tag docker-example:basic username/docker-example:latest

# Pushing to Docker Hub (commented out - replace username and uncomment to use)
echo "Push to Docker Hub (commented out)..."
# docker login
# docker push username/docker-example:latest
# docker logout

# Clean up
echo "Cleanup commands (commented out)..."
# Remove containers
# docker rm -f $(docker ps -aq)

# Remove images
# docker rmi docker-example:basic docker-example:multistage docker-example:nonroot

# Remove all unused images
# docker image prune -a -f 