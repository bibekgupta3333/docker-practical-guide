# Lab8 - Microservices with Docker Compose and AWS ECS

This project demonstrates a microservices architecture using Docker Compose for local development and AWS CDK for deployment to ECS. It showcases a complete end-to-end solution with frontend, backend, message queue, and reverse proxy components.

## Architecture Overview

The application implements a modern microservices architecture with the following components:

- **Node.js Backend**: Express API with RabbitMQ integration for message processing
- **React Frontend**: Single-page application that communicates with the backend API
- **RabbitMQ**: Message queue for asynchronous communication between services
- **Nginx**: Reverse proxy for routing requests to appropriate services

### Local Development Architecture

The local development environment uses Docker Compose to orchestrate all services:

```
┌───────────────────────────────────────────────────────────────────────────┐
│                                Docker Compose                             │
│                                                                           │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌──────────┐ │
│  │    Nginx    │     │   Frontend  │     │   Backend   │     │ RabbitMQ │ │
│  │   Proxy     │     │    React    │     │   Node.js   │     │          │ │
│  │  Container  │     │  Container  │     │  Container  │     │ Container│ │
│  └──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └────┬─────┘ │
│         │                   │                   │                 │       │
│         │                   │                   │                 │       │
│         │  ┌───────────────┐│                   │                 │       │
│         └──┤ /             ├┘                   │                 │       │
│            └───────────────┘                    │                 │       │
│                                                 │                 │       │
│            ┌───────────────┐                    │                 │       │
│         ┌──┤ /api          ├────────────────────┘                 │       │
│         │  └───────────────┘                                      │       │
│         │                                                         │       │
│         │  ┌───────────────┐                                      │       │
│         └──┤ /rabbitmq     ├──────────────────────────────────────┘       │
│            └───────────────┘                                              │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
                                    ▲
                                    │
                                    │
                                    │
                                    ▼
                              ┌──────────┐
                              │  Client  │
                              │ Browser  │
                              └──────────┘
```

In this setup:

1. **Nginx** serves as the entry point, routing traffic to appropriate services
2. **Frontend** container serves the React application
3. **Backend** container runs the Node.js API
4. **RabbitMQ** container provides message queuing capabilities
5. All services communicate over a Docker network

### AWS Deployment Architecture

For production, the application is deployed to AWS ECS using CDK:

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                         AWS Cloud                                                 │
│                                                                                                   │
│  ┌────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                         VPC                                                │   │
│  │                                                                                            │   │
│  │  ┌───────────────────┐                                                                     │   │
│  │  │                   │                                                                     │   │
│  │  │  Application      │                                                                     │   │
│  │  │  Load Balancer    │                                                                     │   │
│  │  │                   │                                                                     │   │
│  │  └─────────┬─────────┘                                                                     │   │
│  │            │                                                                               │   │
│  │            ▼                                                                               │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │                                 ECS Cluster                                         │   │   │
│  │  │                                                                                     │   │   │
│  │  │  ┌─────────────────────────────────────────────────────────────────────────┐        │   │   │
│  │  │  │                             Fargate Service                             │        │   │   │
│  │  │  │                                                                         │        │   │   │
│  │  │  │  ┌─────────────────────────────────────────────────────────────────┐    │        │   │   │
│  │  │  │  │                         Task Definition                         │    │        │   │   │
│  │  │  │  │                                                                 │    │        │   │   │
│  │  │  │  │   ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐   │    │        │   │   │
│  │  │  │  │   │  Nginx  │     │Frontend │     │ Backend │     │RabbitMQ │   │    │        │   │   │
│  │  │  │  │   │Container│     │Container│     │Container│     │Container│   │    │        │   │   │
│  │  │  │  │   └─────────┘     └─────────┘     └─────────┘     └─────────┘   │    │        │   │   │
│  │  │  │  │                                                                 │    │        │   │   │
│  │  │  │  └─────────────────────────────────────────────────────────────────┘    │        │   │   │
│  │  │  │                                                                         │        │   │   │
│  │  │  └─────────────────────────────────────────────────────────────────────────┘        │   │   │
│  │  │                                                                                     │   │   │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                                            │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │                                                                                     │   │   │
│  │  │                                  ECR Repositories                                   │   │   │
│  │  │                                                                                     │   │   │
│  │  │    ┌─────────────┐       ┌─────────────┐       ┌─────────────┐                      │   │   │
│  │  │    │   Backend   │       │  Frontend   │       │    Nginx    │                      │   │   │
│  │  │    │ Repository  │       │ Repository  │       │ Repository  │                      │   │   │
│  │  │    └─────────────┘       └─────────────┘       └─────────────┘                      │   │   │
│  │  │                                                                                     │   │   │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                                            │   │
│  └────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                   │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
```

In this AWS deployment:

1. **Application Load Balancer** distributes traffic to the ECS service
2. **ECS Cluster** with Fargate launch type runs the containerized application
3. **Task Definition** defines all containers (Nginx, Frontend, Backend, RabbitMQ)
4. **ECR Repositories** store the Docker images
5. All components run within a VPC with appropriate security groups

## Local Development

### Prerequisites

- Docker and Docker Compose
- Node.js and npm

### Running Locally

1. Clone the repository
2. Start the application using Docker Compose:

```bash
docker-compose up --build
```

3. Access the application at http://localhost:80

## AWS Deployment

### Prerequisites

- AWS CLI configured with appropriate credentials
- Node.js and npm
- AWS CDK installed globally (`npm install -g aws-cdk`)

### Local Testing with LocalStack

You can test the AWS deployment locally using LocalStack, which emulates AWS services:

1. **Prerequisites for LocalStack**:

   - Docker and Docker Compose installed
   - AWS CLI installed

2. **Start LocalStack and Deploy**:

   ```bash
   chmod +x local-deploy.sh
   ./local-deploy.sh
   ```

3. **Access the Application**:

   - The application will be available at http://localhost:8080
   - LocalStack is available at http://localhost:4566

4. **What's Being Emulated**:

   - CloudWatch: For logs and monitoring
   - IAM: For roles and permissions
   - EC2/VPC: For networking
   - ELB: For load balancing
   - Note: ECR services are not fully supported in LocalStack Community Edition (see Known Issues section)

5. **Benefits of LocalStack Testing**:
   - Test AWS deployments without incurring AWS costs
   - Faster development cycles
   - No need for internet connectivity
   - Consistent testing environment

### Known Issues with LocalStack Deployment

The following issues have been identified when working with LocalStack, and fixes have been implemented in the project:

1. **ECR Not Supported in LocalStack Community Edition**:

   **Issue**: The ECR API is not fully implemented in the free version of LocalStack.

   **Fix**: The deployment script has been modified to skip ECR repository creation and instead use local Docker images. The CDK stack has been updated to handle the absence of ECR by using mock repositories when LocalStack is detected.

2. **AWS Account Resolution Failure in CDK**:

   **Issue**: CDK deployment fails with "Unable to resolve AWS account to use" error.

   **Fix**: The CDK entry point (cdk.ts) now explicitly sets a default account ID ('000000000000') when one isn't provided through environment variables. The local-deploy.sh script also sets the necessary environment variables:

   ```bash
   export CDK_DEFAULT_ACCOUNT=000000000000
   export CDK_DEFAULT_REGION=us-east-1
   ```

3. **Node.js Version Compatibility**:

   **Issue**: CDK may display warnings about compatibility with newer Node.js versions.

   **Fix**: The package.json has been updated to work with the latest Node.js versions, and dependencies have been upgraded to newer, compatible versions.

4. **Docker Compose Command Format**:

   **Issue**: Newer Docker versions use `docker compose` instead of `docker-compose`.

   **Fix**: All scripts have been updated to use the newer `docker compose` format (without the hyphen).

### LocalStack Architecture

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                Docker Compose Environment                                        │
│                                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │                                                                                             │ │
│  │  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────┐                    │ │
│  │  │    Nginx    │     │   Frontend  │     │   Backend   │     │RabbitMQ │                    │ │
│  │  │   Proxy     │     │    React    │     │   Node.js   │     │         │                    │ │
│  │  │  Container  │     │  Container  │     │  Container  │     │Container│                    │ │
│  │  └──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └────┬────┘                    │ │
│  │         │                   │                   │                 │                         │ │
│  │         └───────────────────┴───────────────────┴─────────────────┘                         │ │
│  │                                     │                                                       │ │
│  │                                     │ Application Services                                  │ │
│  │                                     │                                                       │ │
│  └─────────────────────────────────────┼───────────────────────────────────────────────────────┘ │
│                                        │                                                         │
│                                        │                                                         │
│  ┌─────────────────────────────────────┼───────────────────────────────────────────────────────┐ │
│  │                                     │                                                       │ │
│  │                                     ▼                                                       │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │ │
│  │  │                                 LocalStack                                          │    │ │
│  │  │                                                                                     │    │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐│    │ │
│  │  │  │     ECR     │  │     ECS     │  │CloudWatch   │  │     IAM     │  │  EC2 / VPC  ││    │ │
│  │  │  │  Emulation  │  │  Emulation  │  │  Emulation  │  │  Emulation  │  │  Emulation  ││    │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘│    │ │
│  │  │                                                                                     │    │ │
│  │  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐                                 │    │ │
│  │  │  │     ELB     │  │CloudFormation│  │   S3/Other  │                                 │    │ │
│  │  │  │  Emulation  │  │  Emulation   │  │  Services   │                                 │    │ │
│  │  │  └─────────────┘  └──────────────┘  └─────────────┘                                 │    │ │
│  │  │                                                                                     │    │ │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘    │ │
│  │                                                                                             │ │
│  │                                AWS Services Emulation                                       │ │
│  │                                                                                             │ │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
```

In this setup:

1. **Application Services**: The same Docker containers used for local development
2. **LocalStack**: Emulates all required AWS services locally
3. **AWS CDK**: Deploys to LocalStack instead of real AWS
4. **Unified Environment**: Everything runs in a single Docker Compose network

### AWS Infrastructure Components

The CDK deployment creates the following AWS resources:

1. **VPC with Public and Private Subnets**

   - Public subnets for the load balancer
   - Private subnets for the ECS tasks
   - NAT Gateway for outbound internet access from private subnets

2. **ECS Cluster**

   - Fargate launch type (serverless containers)
   - Task definitions for all services
   - Service auto-scaling capabilities

3. **Application Load Balancer**

   - Routes traffic to the ECS service
   - HTTP listener on port 80
   - Target group for the Nginx container

4. **ECR Repositories**

   - Stores Docker images for backend, frontend, and Nginx
   - Versioned image management

5. **IAM Roles and Policies**

   - Task execution role for pulling images and logging
   - Task role for application permissions

6. **CloudWatch Logs**
   - Log groups for each container
   - Centralized logging and monitoring

### Deployment Steps

1. Build and push Docker images to ECR:

```bash
chmod +x build-and-push.sh
./build-and-push.sh
```

2. Deploy the infrastructure using CDK:

```bash
chmod +x deploy.sh
./deploy.sh
```

3. After deployment, the CDK will output the load balancer DNS name. Use this to access your application.

### Scaling and Management

The AWS deployment provides several advantages:

- **Auto Scaling**: The ECS service can scale based on CPU and memory utilization
- **High Availability**: Tasks are distributed across multiple Availability Zones
- **Managed Services**: AWS manages the underlying infrastructure
- **Security**: Resources are protected by security groups and IAM policies
- **Monitoring**: CloudWatch provides metrics and logs for all components

## Project Structure

```
lab8/
├── backend/                # Node.js Express API
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── frontend/               # React application
│   ├── Dockerfile
│   ├── package.json
│   ├── public/
│   └── src/
├── nginx/                  # Nginx reverse proxy
│   ├── Dockerfile
│   └── nginx.conf
├── cdk/                    # AWS CDK deployment code
│   ├── bin/
│   ├── lib/
│   ├── package.json
│   └── cdk.json
├── docker-compose.yml      # Local development configuration
├── build-and-push.sh       # Script to build and push Docker images to ECR
├── deploy.sh               # Script to deploy using CDK
└── README.md
```

## Application Flow

### Request Flow

1. **Client Request**: Users access the application through their browser, sending HTTP requests to the Nginx proxy
2. **Nginx Routing**:
   - Requests to `/` are routed to the frontend React application
   - Requests to `/api/*` are routed to the backend Node.js API
   - Requests to `/rabbitmq` are routed to the RabbitMQ management interface
3. **Frontend Processing**:
   - The React application renders the UI
   - Makes API calls to the backend for data
   - Updates the UI based on responses
4. **Backend Processing**:
   - Receives API requests from the frontend
   - Processes business logic
   - Communicates with RabbitMQ for asynchronous operations
   - Returns responses to the frontend
5. **Message Queue Processing**:
   - Backend publishes messages to RabbitMQ queues
   - Messages are consumed asynchronously
   - Provides reliability and decoupling between services

### Data Flow Diagram

```
┌──────────┐     ┌─────────────────────────────────────────────────────────────┐
│          │     │                                                             │
│  Client  │◄────┤                      Frontend (React)                       │
│ Browser  │     │                                                             │
│          │     └───────────────────────────┬─────────────────────────────────┘
└────┬─────┘                                 │
     │                                       │ HTTP/JSON
     │ HTTP                                  │
     │                                       ▼
     │                          ┌─────────────────────────┐
     └─────────────────────────►│                         │
                                │     Backend (Node.js)   │
                                │                         │
                                └────────────┬────────────┘
                                             │
                                             │ AMQP
                                             │
                                             ▼
                                ┌─────────────────────────┐
                                │                         │
                                │        RabbitMQ         │
                                │                         │
                                └─────────────────────────┘
```

### Key Interactions

1. **User Interaction**: Users interact with the frontend application, triggering API calls
2. **API Communication**: The frontend communicates with the backend via RESTful API calls
3. **Message Publishing**: The backend publishes messages to RabbitMQ when asynchronous processing is needed
4. **Message Consumption**: Messages are consumed from RabbitMQ queues for processing

## Cleanup

To remove the AWS resources, run:

```bash
cd cdk
cdk destroy
```

## Clean Up

When you're done with the Lab8 environment, you can clean up all resources with the following commands:

### Using the Cleanup Script

For convenience, a cleanup script is provided that automates the entire cleanup process:

```bash
# Make the script executable (if not already)
chmod +x cleanup.sh

# Run the cleanup script
./cleanup.sh
```

This script will:

- Clean up all LocalStack resources
- Stop and remove all Docker containers, networks, and volumes
- Remove Docker images created for the project
- Verify that all resources have been removed properly

### Manual Cleanup Steps

If you prefer to clean up manually, follow these steps:

#### 1. Stop and Remove Docker Containers

To stop and remove all Docker containers, networks, and volumes created by Docker Compose:

```bash
# Navigate to the lab8 directory
cd lab8

# Stop all containers and remove resources
docker compose down --volumes --remove-orphans
```

This will:

- Stop all running containers
- Remove all stopped containers
- Remove all networks created by Docker Compose
- Remove all volumes defined in docker-compose.yml
- Remove any orphaned containers

#### 2. Remove Docker Images (Optional)

If you want to also remove the Docker images created for this project:

```bash
# Remove the project images
docker rmi lab8-backend lab8-frontend lab8-nginx
docker rmi localhost:4566/lab8-backend:latest localhost:4566/lab8-frontend:latest localhost:4566/lab8-nginx:latest
```

#### 3. Clean Up LocalStack Resources

LocalStack resources are automatically removed when you run `docker compose down --volumes`. However, if you want to clean up specific LocalStack resources:

```bash
# Set LocalStack environment variables
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Delete ECR repositories
aws --endpoint-url=http://localhost:4566 ecr delete-repository --repository-name lab8-backend --force || true
aws --endpoint-url=http://localhost:4566 ecr delete-repository --repository-name lab8-frontend --force || true
aws --endpoint-url=http://localhost:4566 ecr delete-repository --repository-name lab8-nginx --force || true

# Delete CloudFormation stack (if it was created)
aws --endpoint-url=http://localhost:4566 cloudformation delete-stack --stack-name Lab8Stack || true
```

#### 4. Verify Cleanup

To verify that all resources have been cleaned up:

```bash
# Check for any running containers related to lab8
docker ps -a | grep lab8

# Check if any networks or volumes remain
docker network ls | grep lab8
docker volume ls | grep lab8
```

### Troubleshooting

When running the LocalStack example, you might encounter the following issues:

#### 1. Docker Compose Command Not Found

**Problem**: The `docker-compose` command is deprecated in newer Docker versions.

**Solution**: Use `docker compose` (without the hyphen) instead. Update the `local-deploy.sh` script:

```bash
# Change this line:
docker-compose up -d

# To this:
docker compose up -d
```

#### 2. Port 80 Already in Use

**Problem**: The nginx service is configured to use port 80, which might be already in use on your system.

**Solution**: Modify the port mapping in `docker-compose.yml`:

```yaml
nginx:
  # ...
  ports:
    - "8080:80" # Change from "80:80"
```

Also update the output message in `local-deploy.sh`:

```bash
echo "You can access the application at: http://localhost:8080"
```

#### 3. LocalStack Container Fails to Start

**Problem**: The LocalStack container fails with "Device or resource busy" error when trying to use the mounted volume.

**Solution**: Remove the volume configuration from the LocalStack service in `docker-compose.yml`:

```yaml
localstack:
  # ...
  environment:
    # Remove this line:
    # - DATA_DIR=/tmp/localstack/data
  volumes:
    - "/var/run/docker.sock:/var/run/docker.sock"
    # Remove this line:
    # - "localstack_data:/tmp/localstack/data"
```

Also remove `localstack_data:` from the volumes section at the bottom of the file.

#### 4. ECR Services Not Available in LocalStack Free Version

**Problem**: Creating ECR repositories fails with an error indicating the API is not implemented.

**Note**: The free version of LocalStack doesn't support ECR services. For full AWS service emulation including ECR, consider using LocalStack Pro or deploying to an actual AWS environment.

#### 5. Node.js Version Compatibility Issues with CDK

**Problem**: The CDK deployment requires Node.js version 14.15.0 or newer.

**Solution**: Update your Node.js installation to a compatible version (18.x is recommended) before running the CDK deployment:

```bash
# Check your current Node.js version
node -v

# If needed, update to a newer version using nvm or your system's package manager
```

#### 6. API Endpoints Not Working with NGINX Rewrite Rules

**Problem**: The messaging functionality (WebSocket queue) fails because of a mismatch between the backend API endpoints and NGINX URL rewriting.

**Explanation**: The NGINX configuration rewrites URLs from `/api/messages` to `/messages`, but the backend is expecting `/api/messages`.

**Solution**: Update the endpoint paths in the backend (server.js) to match what NGINX is sending after the rewrite:

```javascript
// Change this:
app.post('/api/messages', async (req, res) => { ... });
app.get('/api/messages', async (req, res) => { ... });

// To this:
app.post('/messages', async (req, res) => { ... });
app.get('/messages', async (req, res) => { ... });
```

After making this change, rebuild and restart the backend container:

```bash
docker compose build backend
docker compose up -d backend
```
