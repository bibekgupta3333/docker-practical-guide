#!/bin/bash
set -e

echo "===== Testing Go Example ====="
cd example1-go
docker build -t go-multistage .
docker run -d -p 8080:8080 --name go-app go-multistage
echo "Go app running on http://localhost:8080"
sleep 2
curl -s http://localhost:8080
echo -e "\n"
docker stop go-app && docker rm go-app

echo "===== Testing Node.js Example ====="
cd ../example2-node
docker build -t node-multistage .
docker run -d -p 3000:3000 --name node-app node-multistage
echo "Node.js app running on http://localhost:3000"
sleep 2
curl -s http://localhost:3000
echo -e "\n"
docker stop node-app && docker rm node-app

echo "===== Testing Python Example ====="
cd ../example3-python
docker build -t python-multistage .
docker run -d -p 5000:5000 --name python-app python-multistage
echo "Python app running on http://localhost:5000"
sleep 2
curl -s http://localhost:5000
echo -e "\n"
docker stop python-app && docker rm python-app

echo "===== Testing Java Example ====="
cd ../example4-java
docker build -t java-multistage .
docker run -d -p 8081:8080 --name java-app java-multistage
echo "Java app running on http://localhost:8081"
sleep 5 # Give Spring Boot more time to start up
curl -s http://localhost:8081
echo -e "\n"
docker stop java-app && docker rm java-app

cd ..
echo "All tests completed successfully!" 