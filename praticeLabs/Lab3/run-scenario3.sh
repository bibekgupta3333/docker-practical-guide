#!/bin/bash

echo "Starting Scenario 3: Isolated Container with No Network"

# Create data directory and sample input
mkdir -p data
echo "This is input data for processing" > data/input.txt

# Run the isolated container 
docker compose -f processing-compose.yml up -d

echo ""
echo "Container is running with no network access"
echo "To verify the container has no network interfaces, run:"
echo "docker exec -it \$(docker ps -qf name=processor) ip addr"
echo ""
echo "You should only see the loopback interface (lo)"
echo "To see the processed data, check the file:"
echo "cat data/processed/result.txt" 