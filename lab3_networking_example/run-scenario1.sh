#!/bin/bash

echo "Starting Scenario 1: Web Application with Database"

# Create a directory for the web content
mkdir -p webapp
echo "<h1>Web Application with Database Demo</h1><p>This container can connect to the database container using the hostname: <code>db</code></p>" > webapp/index.html

# Run containers
docker compose -f webapp-compose.yml up -d

echo ""
echo "Containers running in the lab3_webapp-network:"
docker network inspect lab3_webapp-network

echo ""
echo "Access the web application at http://localhost:8080"
echo "To test database connectivity, run:"
echo "docker exec -it \$(docker ps -qf name=webapp) sh -c 'wget -O- db:3306 2>&1 | grep -i mysql'" 