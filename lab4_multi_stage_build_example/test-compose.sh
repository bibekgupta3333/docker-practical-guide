#!/bin/bash
set -e

echo "===== Testing All Examples with Docker Compose ====="
docker-compose up -d

echo -e "\nWaiting for all services to start up..."
sleep 10

echo -e "\n===== Testing Go Example ====="
echo "Go app running on http://localhost:8080"
curl -s http://localhost:8080
echo -e "\n"

echo -e "\n===== Testing Node.js Example ====="
echo "Node.js app running on http://localhost:3000"
curl -s http://localhost:3000
echo -e "\n"

echo -e "\n===== Testing Python Example ====="
echo "Python app running on http://localhost:5000"
curl -s http://localhost:5000
echo -e "\n"

echo -e "\n===== Testing Java Example ====="
echo "Java app running on http://localhost:8081"
curl -s http://localhost:8081
echo -e "\n"

echo -e "\nStopping all containers..."
docker-compose down

echo "All tests completed successfully!" 