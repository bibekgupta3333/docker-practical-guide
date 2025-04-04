#!/bin/bash

# Docker Swarm Cleanup Script
# This script helps to clean up Docker Swarm resources

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display script usage
show_usage() {
  echo -e "${YELLOW}Docker Swarm Cleanup Script${NC}"
  echo "Usage: $0 [OPTIONS] COMMAND"
  echo ""
  echo "Commands:"
  echo "  services           Remove all services"
  echo "  stacks             Remove all stacks"
  echo "  networks           Remove all overlay networks"
  echo "  volumes            Remove all volumes"
  echo "  images             Remove all images built for this example"
  echo "  containers         Stop and remove all containers"
  echo "  swarm              Leave the swarm"
  echo "  all                Run all cleanup operations"
  echo ""
  echo "Options:"
  echo "  -h, --help          Show this help message"
  echo "  -f, --force         Force removal without confirmation"
  echo ""
}

# Function to confirm action
confirm() {
  if [ "$FORCE" = true ]; then
    return 0
  fi
  
  read -p "Are you sure you want to proceed? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  else
    echo -e "${YELLOW}Operation cancelled${NC}"
    return 1
  fi
}

# Function to remove services
remove_services() {
  echo -e "${YELLOW}Removing all services...${NC}"
  
  if confirm; then
    services=$(docker service ls -q 2>/dev/null || echo "")
    if [ -n "$services" ]; then
      docker service rm $services
      echo -e "${GREEN}All services removed${NC}"
    else
      echo -e "${YELLOW}No services found${NC}"
    fi
  fi
}

# Function to remove stacks
remove_stacks() {
  echo -e "${YELLOW}Removing all stacks...${NC}"
  
  if confirm; then
    stacks=$(docker stack ls --format "{{.Name}}" 2>/dev/null || echo "")
    if [ -n "$stacks" ]; then
      for stack in $stacks; do
        docker stack rm $stack
      done
      echo -e "${GREEN}All stacks removed${NC}"
      
      # Wait for services to be removed
      echo -e "${YELLOW}Waiting for services to be removed...${NC}"
      sleep 5
    else
      echo -e "${YELLOW}No stacks found${NC}"
    fi
  fi
}

# Function to remove networks
remove_networks() {
  echo -e "${YELLOW}Removing all overlay networks...${NC}"
  
  if confirm; then
    networks=$(docker network ls --filter driver=overlay --format "{{.Name}}" | grep -v "ingress" 2>/dev/null || echo "")
    if [ -n "$networks" ]; then
      for network in $networks; do
        docker network rm $network || echo -e "${RED}Could not remove network $network${NC}"
      done
      echo -e "${GREEN}All custom overlay networks removed${NC}"
    else
      echo -e "${YELLOW}No custom overlay networks found${NC}"
    fi
  fi
}

# Function to remove volumes
remove_volumes() {
  echo -e "${YELLOW}Removing all volumes...${NC}"
  
  if confirm; then
    volumes=$(docker volume ls -q 2>/dev/null || echo "")
    if [ -n "$volumes" ]; then
      docker volume rm $volumes || echo -e "${RED}Could not remove some volumes${NC}"
      echo -e "${GREEN}All volumes removed${NC}"
    else
      echo -e "${YELLOW}No volumes found${NC}"
    fi
  fi
}

# Function to remove images
remove_images() {
  echo -e "${YELLOW}Removing example images...${NC}"
  
  if confirm; then
    images=$(docker images | grep "nodejs-swarm" | awk '{print $3}' 2>/dev/null || echo "")
    if [ -n "$images" ]; then
      docker rmi $images || echo -e "${RED}Could not remove some images${NC}"
      echo -e "${GREEN}All example images removed${NC}"
    else
      echo -e "${YELLOW}No example images found${NC}"
    fi
  fi
}

# Function to remove containers
remove_containers() {
  echo -e "${YELLOW}Stopping and removing all containers...${NC}"
  
  if confirm; then
    containers=$(docker ps -aq 2>/dev/null || echo "")
    if [ -n "$containers" ]; then
      docker stop $containers || echo -e "${RED}Could not stop some containers${NC}"
      docker rm $containers || echo -e "${RED}Could not remove some containers${NC}"
      echo -e "${GREEN}All containers stopped and removed${NC}"
    else
      echo -e "${YELLOW}No containers found${NC}"
    fi
  fi
}

# Function to leave swarm
leave_swarm() {
  echo -e "${RED}Leaving the swarm...${NC}"
  
  if confirm; then
    docker swarm leave --force || echo -e "${RED}Not part of a swarm or could not leave${NC}"
    echo -e "${GREEN}Left the swarm${NC}"
  fi
}

# Function to run all cleanup operations
cleanup_all() {
  echo -e "${RED}Running ALL cleanup operations...${NC}"
  
  if confirm; then
    remove_stacks
    remove_services
    remove_networks
    remove_containers
    remove_images
    remove_volumes
    leave_swarm
    
    echo -e "${GREEN}Cleanup complete!${NC}"
  fi
}

# Parse command line arguments
FORCE=false
COMMAND=""

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      show_usage
      exit 0
      ;;
    -f|--force)
      FORCE=true
      shift
      ;;
    *)
      COMMAND="$1"
      shift
      ;;
  esac
done

# Check if a command was specified
if [ -z "$COMMAND" ]; then
  echo -e "${RED}Error: No command specified${NC}"
  show_usage
  exit 1
fi

# Execute the specified command
case "$COMMAND" in
  services)
    remove_services
    ;;
  stacks)
    remove_stacks
    ;;
  networks)
    remove_networks
    ;;
  volumes)
    remove_volumes
    ;;
  images)
    remove_images
    ;;
  containers)
    remove_containers
    ;;
  swarm)
    leave_swarm
    ;;
  all)
    cleanup_all
    ;;
  *)
    echo -e "${RED}Unknown command: ${COMMAND}${NC}"
    show_usage
    exit 1
    ;;
esac

exit 0 