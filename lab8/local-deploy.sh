#!/bin/bash
set -e

# This script deploys the application to LocalStack for local testing

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Start LocalStack and the application if not already running
if ! docker ps | grep -q lab8-localstack; then
  echo "Starting Docker Compose services..."
  docker compose up -d
  
  # Wait for LocalStack to be ready
  echo "Waiting for LocalStack to be ready..."
  count=0
  max_attempts=30
  until docker logs lab8-localstack 2>&1 | grep -q "Ready." || [ $count -eq $max_attempts ]; do
    echo "Waiting for LocalStack to be ready... (attempt $((count+1))/$max_attempts)"
    sleep 5
    count=$((count+1))
  done

  if [ $count -eq $max_attempts ]; then
    echo "LocalStack failed to start after $max_attempts attempts. Please check the logs."
    docker logs lab8-localstack
    exit 1
  fi
fi

# Set environment variables for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export LOCALSTACK_HOSTNAME=localhost
export CDK_DEFAULT_ACCOUNT=000000000000
export CDK_DEFAULT_REGION=us-east-1

# Configure AWS CLI to use LocalStack
echo "Configuring AWS CLI to use LocalStack..."
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set region us-east-1
aws configure set output json

# Note about ECR and LocalStack
echo "Note: ECR API is not fully implemented in LocalStack community edition."
echo "We'll skip ECR repository creation and proceed with local Docker images."

# Build and tag Docker images (using regular Docker tags for local testing)
echo "Building Docker images..."
docker build -t lab8-backend:latest ./backend
docker build -t lab8-frontend:latest ./frontend
docker build -t lab8-nginx:latest ./nginx

# Create mock repository data for CDK to work with
echo "Creating mock ECR data for LocalStack..."
mkdir -p .localstack/mock
cat > .localstack/mock/ecr-repositories.json << EOL
{
  "lab8-backend": {
    "repositoryUri": "localhost:4566/lab8-backend",
    "repositoryName": "lab8-backend"
  },
  "lab8-frontend": {
    "repositoryUri": "localhost:4566/lab8-frontend",
    "repositoryName": "lab8-frontend"
  },
  "lab8-nginx": {
    "repositoryUri": "localhost:4566/lab8-nginx",
    "repositoryName": "lab8-nginx"
  }
}
EOL

# Deploy using CDK with LocalStack
echo "Deploying to LocalStack using CDK..."
cd cdk

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing CDK dependencies..."
  npm install
fi

# Build the CDK project
echo "Building CDK project..."
npm run build

# Set CDK to use LocalStack
export CDK_LOCAL=true
export CDK_ENDPOINT=http://localhost:4566

# Deploy the stack to LocalStack (with modified context)
echo "Running CDK deployment..."
npx cdk deploy --require-approval never --context use_localstack=true

echo "Deployment to LocalStack completed!"
echo "You can access the application at: http://localhost:8080"
echo "LocalStack is available at: http://localhost:4566"
