#!/bin/bash

echo "Starting Scenario 4: Microservices with Multiple Networks"

# Create directories for services
mkdir -p api web
echo "API service directory created" > api/README.txt
echo "Web service directory created" > web/README.txt

# Run the microservices
docker compose -f microservices-compose.yml up -d

echo ""
echo "Microservices architecture is running with multiple networks"
echo ""
echo "Frontend network contains:"
docker network inspect lab3_frontend-net
echo ""
echo "Backend network contains:"
docker network inspect lab3_backend-net
echo ""
echo "Access the web frontend at http://localhost:80"
echo ""
echo "To test API communication, run:"
echo "docker exec -it \$(docker ps -qf name=web) wget -O- api:3000"
echo ""
echo "To test that web cannot directly access database, run:"
echo "docker exec -it \$(docker ps -qf name=web) wget -O- database:3306"
echo "This should fail because web is not on the same network as database" 