#!/bin/bash

# Docker Swarm Test Script
# This script helps to test the Docker Swarm setup locally using a single node

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display script usage
show_usage() {
  echo -e "${YELLOW}Docker Swarm Test Script${NC}"
  echo "Usage: $0 [COMMAND]"
  echo ""
  echo "Commands:"
  echo "  basic          Test basic service deployment"
  echo "  multi          Test multi-service application"
  echo "  global         Test global service deployment"
  echo "  all            Test all deployments sequentially"
  echo "  help           Show this help message"
  echo ""
}

check_swarm_status() {
  # Check if Docker is running
  if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
  fi

  # Check if already in swarm mode
  if docker info | grep -q "Swarm: active"; then
    echo -e "${YELLOW}Already in swarm mode${NC}"
    return 0
  else
    echo -e "${YELLOW}Initializing swarm mode...${NC}"
    docker swarm init --advertise-addr 127.0.0.1 || true
    return 1
  fi
}

check_service_health() {
  local service_name=$1
  local max_attempts=30
  local attempt=1
  
  echo -e "${YELLOW}Checking health of service: ${service_name}${NC}"
  
  while [ $attempt -le $max_attempts ]; do
    echo -n "."
    
    # Check if the service has tasks running
    if [ $(docker service ps $service_name --filter "desired-state=running" -q | wc -l) -gt 0 ]; then
      echo -e "\n${GREEN}Service ${service_name} is healthy!${NC}"
      return 0
    fi
    
    attempt=$((attempt+1))
    sleep 1
  done
  
  echo -e "\n${RED}Service ${service_name} health check timed out${NC}"
  return 1
}

print_service_info() {
  echo -e "${BLUE}========== Services ===========${NC}"
  docker service ls
  
  echo -e "\n${BLUE}========== Tasks ===========${NC}"
  docker service ps $(docker service ls -q) --no-trunc
}

test_basic_service() {
  echo -e "${GREEN}Testing basic service deployment...${NC}"
  
  # Build and deploy
  echo -e "${YELLOW}Building and deploying basic service...${NC}"
  docker-compose -f basic-service-compose.yml build
  docker stack deploy -c basic-service-compose.yml basic-stack
  
  # Wait for service to be healthy
  sleep 5
  check_service_health basic-stack_nodejs-app
  
  # Print service information
  print_service_info
  
  # Test the service
  echo -e "\n${BLUE}========== Testing Service Endpoint ===========${NC}"
  echo "Waiting for service to be available..."
  sleep 5
  curl -s http://localhost:3000 | jq || echo "Failed to connect to service"
  
  echo -e "\n${GREEN}Basic service test completed${NC}"
}

test_multi_service() {
  echo -e "${GREEN}Testing multi-service application deployment...${NC}"
  
  # Build and deploy
  echo -e "${YELLOW}Building and deploying multi-service application...${NC}"
  docker-compose -f multi-service-compose.yml build
  docker stack deploy -c multi-service-compose.yml multi-stack
  
  # Wait for services to be healthy
  sleep 10
  check_service_health multi-stack_frontend
  check_service_health multi-stack_backend
  check_service_health multi-stack_mongo
  
  # Print service information
  print_service_info
  
  # Test the service
  echo -e "\n${BLUE}========== Testing Frontend Endpoint ===========${NC}"
  echo "Waiting for service to be available..."
  sleep 5
  curl -s http://localhost:8080 | jq || echo "Failed to connect to service"
  
  echo -e "\n${GREEN}Multi-service application test completed${NC}"
}

test_global_service() {
  echo -e "${GREEN}Testing global service deployment...${NC}"
  
  # Build and deploy
  echo -e "${YELLOW}Building and deploying global service...${NC}"
  docker-compose -f global-service-compose.yml build
  docker stack deploy -c global-service-compose.yml global-stack
  
  # Wait for services to be healthy
  sleep 5
  check_service_health global-stack_app-service
  check_service_health global-stack_monitoring-service
  
  # Print service information
  print_service_info
  
  # Test the service
  echo -e "\n${BLUE}========== Testing App Service Endpoint ===========${NC}"
  echo "Waiting for service to be available..."
  sleep 5
  curl -s http://localhost:3000 | jq || echo "Failed to connect to service"
  
  echo -e "\n${GREEN}Global service test completed${NC}"
}

cleanup() {
  echo -e "${YELLOW}Cleaning up...${NC}"
  
  docker stack rm basic-stack multi-stack global-stack 2>/dev/null || true
  
  echo -e "${YELLOW}Waiting for services to be removed...${NC}"
  sleep 10
  
  echo -e "${GREEN}Cleanup completed${NC}"
}

# Main script execution

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo -e "${YELLOW}Warning: jq is not installed. JSON output will not be formatted.${NC}"
  JQ_INSTALLED=false
else
  JQ_INSTALLED=true
fi

# Process command
COMMAND=${1:-help}

case $COMMAND in
  help)
    show_usage
    ;;
  basic)
    check_swarm_status
    cleanup
    test_basic_service
    ;;
  multi)
    check_swarm_status
    cleanup
    test_multi_service
    ;;
  global)
    check_swarm_status
    cleanup
    test_global_service
    ;;
  all)
    check_swarm_status
    cleanup
    test_basic_service
    cleanup
    test_multi_service
    cleanup
    test_global_service
    cleanup
    ;;
  *)
    echo -e "${RED}Unknown command: ${COMMAND}${NC}"
    show_usage
    exit 1
    ;;
esac

exit 0 