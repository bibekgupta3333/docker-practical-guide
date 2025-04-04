#!/bin/bash
set -e

# This script builds and pushes Docker images to ECR

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install it first."
    exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}

# ECR repository names
BACKEND_REPO="lab8-backend"
FRONTEND_REPO="lab8-frontend"
NGINX_REPO="lab8-nginx"

# Create ECR repositories if they don't exist
create_repo_if_not_exists() {
    local repo_name=$1
    if ! aws ecr describe-repositories --repository-names $repo_name --region $AWS_REGION &> /dev/null; then
        echo "Creating ECR repository: $repo_name"
        aws ecr create-repository --repository-name $repo_name --region $AWS_REGION
    else
        echo "ECR repository $repo_name already exists"
    fi
}

create_repo_if_not_exists $BACKEND_REPO
create_repo_if_not_exists $FRONTEND_REPO
create_repo_if_not_exists $NGINX_REPO

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push backend
echo "Building and pushing backend image..."
cd backend
docker build -t $BACKEND_REPO:latest .
docker tag $BACKEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:latest
cd ..

# Build and push frontend
echo "Building and pushing frontend image..."
cd frontend
docker build -t $FRONTEND_REPO:latest .
docker tag $FRONTEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:latest
cd ..

# Build and push nginx
echo "Building and pushing nginx image..."
cd nginx
docker build -t $NGINX_REPO:latest .
docker tag $NGINX_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$NGINX_REPO:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$NGINX_REPO:latest
cd ..

echo "All images have been built and pushed to ECR!"
