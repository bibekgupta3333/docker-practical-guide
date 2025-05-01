#!/bin/bash
set -e

echo "Starting Lab8 cleanup process..."

# 1. Clean up LocalStack resources
echo "Cleaning up LocalStack resources..."
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Try to delete CloudFormation stack first
echo "Attempting to delete CloudFormation stack..."
aws --endpoint-url=http://localhost:4566 cloudformation delete-stack --stack-name Lab8Stack 2>/dev/null || true
echo "Waiting 5 seconds for stack deletion to begin..."
sleep 5

# Delete ECR repositories
echo "Deleting ECR repositories..."
aws --endpoint-url=http://localhost:4566 ecr delete-repository --repository-name lab8-backend --force 2>/dev/null || true
aws --endpoint-url=http://localhost:4566 ecr delete-repository --repository-name lab8-frontend --force 2>/dev/null || true
aws --endpoint-url=http://localhost:4566 ecr delete-repository --repository-name lab8-nginx --force 2>/dev/null || true

# 2. Stop and remove all containers, networks, and volumes
echo "Stopping and removing Docker containers, networks, and volumes..."
docker compose down --volumes --remove-orphans

# 3. Remove Docker images
echo "Removing Docker images..."
docker rmi lab8-backend lab8-frontend lab8-nginx 2>/dev/null || true
docker rmi localhost:4566/lab8-backend:latest localhost:4566/lab8-frontend:latest localhost:4566/lab8-nginx:latest 2>/dev/null || true

# 4. Verify cleanup
echo "Verifying cleanup..."
echo "Remaining containers with 'lab8' in name:"
docker ps -a | grep lab8 || echo "None"

echo "Remaining networks with 'lab8' in name:"
docker network ls | grep lab8 || echo "None"

echo "Remaining volumes with 'lab8' in name:"
docker volume ls | grep lab8 || echo "None"

echo "Lab8 cleanup completed successfully!" 