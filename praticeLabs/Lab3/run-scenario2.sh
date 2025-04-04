#!/bin/bash

echo "Starting Scenario 2: Direct Host Network Access"

# Run the monitoring container
docker compose -f monitoring-compose.yml up -d

echo ""
echo "Container is running with host network access"
echo "To view network interfaces inside the container, run:"
echo "docker exec -it \$(docker ps -qf name=monitoring) ip addr"
echo ""
echo "To see network traffic (requires root privileges):"
echo "docker exec -it \$(docker ps -qf name=monitoring) iftop"
echo ""
echo "Notice that the container shares the same network interfaces as the host machine"
echo "This allows direct access to all host network features and ports" 