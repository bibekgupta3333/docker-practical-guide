#!/bin/bash

# Docker Swarm Setup Script
# This script helps to initialize and setup a Docker Swarm environment

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display script usage
show_usage() {
  echo -e "${YELLOW}Docker Swarm Setup Script${NC}"
  echo "Usage: $0 [OPTIONS] COMMAND"
  echo ""
  echo "Commands:"
  echo "  init                Initialize a new Docker Swarm"
  echo "  deploy-basic        Deploy basic service example"
  echo "  deploy-multi        Deploy multi-service application example"
  echo "  deploy-global       Deploy global service example"
  echo "  destroy             Remove all services and leave swarm"
  echo ""
  echo "Options:"
  echo "  -h, --help          Show this help message"
  echo "  -a, --advertise-ip  IP address to advertise (for init)"
  echo ""
}

# Function to initialize Docker Swarm
init_swarm() {
  local advertise_ip="$1"
  
  if [ -z "$advertise_ip" ]; then
    # Try to get default IP automatically
    advertise_ip=$(hostname -I | awk '{print $1}')
    echo -e "${YELLOW}No IP address specified, using: ${advertise_ip}${NC}"
    echo -e "${YELLOW}To specify a different IP, use: $0 -a <IP> init${NC}"
  fi
  
  echo -e "${GREEN}Initializing Docker Swarm with advertise IP: ${advertise_ip}${NC}"
  docker swarm init --advertise-addr "$advertise_ip"
  
  echo -e "${GREEN}Swarm initialized!${NC}"
  echo ""
  echo -e "${YELLOW}To add a worker to this swarm, run the following command:${NC}"
  docker swarm join-token worker | grep "docker swarm join"
  echo ""
}

# Function to deploy basic service
deploy_basic() {
  echo -e "${GREEN}Building and deploying basic service example...${NC}"
  
  # Build the Docker image
  docker-compose -f basic-service-compose.yml build
  
  # Deploy the stack
  docker stack deploy -c basic-service-compose.yml basic-stack
  
  echo -e "${GREEN}Basic service deployed!${NC}"
  echo -e "${YELLOW}Access the service at: http://localhost:3000${NC}"
  echo -e "${YELLOW}To view the services, run: docker service ls${NC}"
}

# Function to deploy multi-service application
deploy_multi() {
  echo -e "${GREEN}Building and deploying multi-service application example...${NC}"
  
  # Build the Docker images
  docker-compose -f multi-service-compose.yml build
  
  # Deploy the stack
  docker stack deploy -c multi-service-compose.yml multi-stack
  
  echo -e "${GREEN}Multi-service application deployed!${NC}"
  echo -e "${YELLOW}Access the frontend at: http://localhost:8080${NC}"
  echo -e "${YELLOW}To view the services, run: docker service ls${NC}"
}

# Function to deploy global service example
deploy_global() {
  echo -e "${GREEN}Building and deploying global service example...${NC}"
  
  # Build the Docker images
  docker-compose -f global-service-compose.yml build
  
  # Deploy the stack
  docker stack deploy -c global-service-compose.yml global-stack
  
  echo -e "${GREEN}Global service example deployed!${NC}"
  echo -e "${YELLOW}Access the service at: http://localhost:3000${NC}"
  echo -e "${YELLOW}To view the services, run: docker service ls${NC}"
}

# Function to destroy all deployed services and leave swarm
destroy() {
  echo -e "${YELLOW}Removing all deployed stacks...${NC}"
  docker stack rm basic-stack multi-stack global-stack || true
  
  echo -e "${YELLOW}Waiting for services to be removed...${NC}"
  sleep 5
  
  echo -e "${RED}Leaving the swarm...${NC}"
  docker swarm leave --force || true
  
  echo -e "${GREEN}Cleanup complete!${NC}"
}

# Parse command line arguments
ADVERTISE_IP=""

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      show_usage
      exit 0
      ;;
    -a|--advertise-ip)
      ADVERTISE_IP="$2"
      shift
      shift
      ;;
    *)
      COMMAND="$1"
      shift
      ;;
  esac
done

# Execute the specified command
case "$COMMAND" in
  init)
    init_swarm "$ADVERTISE_IP"
    ;;
  deploy-basic)
    deploy_basic
    ;;
  deploy-multi)
    deploy_multi
    ;;
  deploy-global)
    deploy_global
    ;;
  destroy)
    destroy
    ;;
  *)
    echo -e "${RED}Unknown command: ${COMMAND}${NC}"
    show_usage
    exit 1
    ;;
esac

exit 0 