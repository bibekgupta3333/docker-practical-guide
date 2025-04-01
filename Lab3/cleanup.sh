#!/bin/bash

echo "Cleaning up all Docker network examples..."

# Stop and remove containers from all scenarios
echo "Stopping and removing Docker Compose services..."
docker compose -f webapp-compose.yml down -v
docker compose -f monitoring-compose.yml down
docker compose -f processing-compose.yml down
docker compose -f microservices-compose.yml down -v

# Remove any manually created containers (if Docker Compose didn't clean them)
echo "Removing any remaining containers..."
docker rm -f $(docker ps -aq --filter name=webapp --filter name=mysql-db --filter name=monitoring-app --filter name=secure-processor --filter name=api-service --filter name=web-frontend --filter name=database) 2>/dev/null || true

# Remove networks
echo "Removing Docker networks..."
docker network rm webapp-network frontend-net backend-net lab3_webapp-network lab3_frontend-net lab3_backend-net 2>/dev/null || true

echo ""
echo "Cleanup completed! To also remove created directories, run:"
echo "rm -rf webapp data api web"
echo ""
echo "All Docker network examples have been cleaned up!" 