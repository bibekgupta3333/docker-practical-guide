# Docker Networking Examples

This lab demonstrates different types of Docker networks and how to use them effectively, both with Docker CLI and Docker Compose.

## Network Types Overview

Docker offers several network types, each designed for specific use cases:

### 1. **Bridge Network**

- The default network type for containers on a single host
- Creates a private internal network on the host
- Containers on the same bridge can communicate with each other
- Provides NAT and port mapping to connect to the outside world
- Limited by a single host - doesn't span across multiple Docker hosts
- The default bridge network lacks automatic DNS resolution between containers

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────┐       ┌─────────────┐       ┌─────────────┐                       │
│  │ Container A │       │ Container B │       │ Container C │                       │
│  └──────┬──────┘       └──────┬──────┘       └──────┬──────┘                       │
│         │                     │                     │                              │
│         └───────┬─────────────┼─────────────┬──────┘                              │
│                 │             │             │                                      │
│          ┌──────┴─────────────┴─────────────┴───────┐                             │
│          │              Docker Bridge               │                             │
│          │           172.17.0.0/16 (default)        │                             │
│          └──────────────────────┬──────────────────┘                              │
│                                 │                                                  │
│                         ┌───────┴─────────┐                                        │
│                         │   Host Network  │                                        │
│                         │   Interface     │                                        │
│                         └───────┬─────────┘                                        │
│                                 │                                                  │
└─────────────────────────────────┼──────────────────────────────────────────────────┘
                                  │
                                  ▼
                             External Network
```

### 2. **Host Network**

- Removes network isolation between the container and the host
- Container shares the host's network namespace and interfaces
- Container ports are directly exposed on the host without port mapping
- Provides the best performance but reduces container isolation
- Useful for networking-intensive applications where performance is critical
- May cause port conflicts if multiple containers try to use the same port

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐       │
│  │    Container A      │   │    Container B      │   │    Container C      │       │
│  │   (host network)    │   │   (host network)    │   │   (host network)    │       │
│  │                     │   │                     │   │                     │       │
│  │ Port 80 ◄───────────┼───┼───────────┐         │   │         ┌───────────┼───┐  │
│  │ Port 443◄───────────┼───┼─────┐     │         │   │         │     ┌─────┼───┼──┼─► Port 443
│  │ Port 8080◄──────────┼───┼─┐   │     │         │   │         │     │     │   │  │
│  └─────────────────────┘   │ │   │     │         │   │         │     │     │   │  │
│                            │ │   │     │         │   │         │     │     │   │  │
│                            │ │   │     │         │   │         │     │     │   │  │
│  ┌───────────────────────────┴───┴─────┴─────────┴───┴─────────┴─────┴─────┘   │  │
│  │                    Shared Host Network Namespace                            │  │
│  └───────────────────────────────────────┬───────────────────────────────────────┘  │
│                                          │                                          │
└──────────────────────────────────────────┼──────────────────────────────────────────┘
                                           │
                                           ▼
                                     External Network
```

### 3. **None Network**

- Complete network isolation for containers
- Container has no external network interfaces except the loopback (localhost)
- Cannot communicate with other containers or the outside world
- Provides maximum network security for sensitive operations
- Useful for batch processing jobs that don't require network access
- Containers can still use volumes for data exchange with the host

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐                   │
│  │               Isolated Processing Container                  │                   │
│  │                    (secure-processor)                        │                   │
│  │                                                              │                   │
│  │   ┌───────────────────────────────────────────────────┐     │                   │
│  │   │  Loopback Interface Only (lo - 127.0.0.1)         │     │                   │
│  │   └───────────────────────────────────────────────────┘     │                   │
│  │                                                              │                   │
│  │   ┌───────────────────────────────────────────────────┐     │                   │
│  │   │               Processing Task                     │     │                   │
│  │   │        ┌───────────────────────────────┐          │     │                   │
│  │   │        │       Data Volume Mount       │          │     │                   │
│  │   │        └─────────────────┬─────────────┘          │     │                   │
│  │   └─────────────────────────┬┼───────────────────────┬┘     │                   │
│  └─────────────────────────────┼┼───────────────────────┼──────┘                   │
│                                ││                       │                          │
│                                ▼▼                       │                          │
│                   ┌────────────────────────┐            │                          │
│                   │  Host Filesystem       │            │                          │
│                   │  (data-cli/)           │            │                          │
│                   └────────────────────────┘            │                          │
│                                                         │                          │
│                                No Network Connection    ✗                          │
│                                                         │                          │
└─────────────────────────────────────────────────────────┼──────────────────────────┘
                                                          │
                                                          ▼
                                                    External Network
                                                   (Not Accessible)
```

### 4. **Overlay Network**

- Designed for multi-host networking in Docker Swarm
- Spans across multiple Docker hosts to create a distributed network
- Enables service discovery and load balancing across a cluster
- Uses VXLAN encapsulation to create virtual networks across hosts
- Supports encrypted communications between containers
- Used primarily in container orchestration environments

```
┌─────────────────────────┐      ┌─────────────────────────┐      ┌─────────────────────────┐
│     Docker Host 1       │      │     Docker Host 2       │      │     Docker Host 3       │
│                         │      │                         │      │                         │
│  ┌─────────┐ ┌─────────┐│      │┌─────────┐ ┌─────────┐ │      ││Container│ │Container│  │
│  │Container│ │Container││      ││Container│ │Container│ │      ││    E    │ │    F    │  │
│  │    A    │ │    B    ││      ││    C    │ │    D    │ │      ││   172.20.0.3│ │172.21.0.3│  │
│  └────┬────┘ └────┬────┘│      │└────┬────┘ └────┬────┘ │      │└────┬────┘ └────┬────┘  │
│       │           │     │      │     │           │      │      │     │           │       │
│       └─────┬─────┘     │      │     └─────┬─────┘      │      │     └─────┬─────┘       │
│             │           │      │           │            │      │           │             │
│      ┌──────┴──────┐    │      │    ┌──────┴──────┐     │      │    ┌──────┴──────┐      │
│      │ Local Overlay│    │      │    │ Local Overlay│     │      │    │ Local Overlay│      │
│      │   Network    │    │      │    │   Network    │     │      │    │   Network    │      │
│      └──────┬──────┘    │      │    └──────┬──────┘     │      │    └──────┬──────┘      │
│             │           │      │           │            │      │           │             │
└─────────────┼───────────┘      └───────────┼────────────┘      └───────────┼─────────────┘
              │                              │                               │
              └──────────────────────┬───────┴───────────────────────────────┘
                                     │
                        ┌────────────┴────────────┐
                        │   Overlay Network Key   │
                        │   Value Store (etcd)    │
                        └─────────────────────────┘
```

### 5. **Macvlan Network**

- Assigns a MAC address to each container, making it appear as a physical device
- Connects containers directly to the physical network, bypassing Docker's bridges
- Containers receive IP addresses from the physical network's DHCP
- Provides optimal performance for network-intensive applications
- Useful for applications that need to be directly accessible on the physical network
- Requires network interface cards that support promiscuous mode

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────┐       ┌─────────────┐       ┌─────────────┐                       │
│  │ Container A │       │ Container B │       │ Container C │                       │
│  │ MAC: AA:BB..│       │ MAC: CC:DD..│       │ MAC: EE:FF..│                       │
│  │ IP: 10.0.0.2│       │ IP: 10.0.0.3│       │ IP: 10.0.0.4│                       │
│  └──────┬──────┘       └──────┬──────┘       └──────┬──────┘                       │
│         │                     │                     │                              │
│         │                     │                     │                              │
│  ┌──────┴─────────────────────┴─────────────────────┴───────┐                      │
│  │                   Macvlan Network                        │                      │
│  │               (Sub-interfaces of eth0)                   │                      │
│  └──────────────────────────────┬─────────────────────────────┘                    │
│                                 │                                                  │
│                         ┌───────┴─────────┐                                        │
│                         │   eth0 (NIC)    │                                        │
│                         │   Promiscuous   │                                        │
│                         └───────┬─────────┘                                        │
│                                 │                                                  │
└─────────────────────────────────┼──────────────────────────────────────────────────┘
                                  │
                                  ▼
                          Physical Network (LAN)
                             10.0.0.0/24
```

### 6. **Custom Bridge Networks**

- User-defined bridge networks with improved features over the default bridge
- Provides automatic DNS resolution between containers
- Better isolation between container groups (different bridges)
- More control over IP address assignment and subnet configuration
- Can connect and disconnect containers from networks on the fly
- Recommended for most container-to-container communication scenarios

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────┐       ┌─────────────┐     │     ┌─────────────┐  ┌─────────────┐  │
│  │ Container A │       │ Container B │     │     │ Container C │  │ Container D │  │
│  └──────┬──────┘       └──────┬──────┘     │     └──────┬──────┘  └──────┬──────┘  │
│         │                     │            │            │                │         │
│         └───────┬─────────────┘            │            └────────┬──────┘         │
│                 │                          │                     │                 │
│          ┌──────┴──────────────┐           │         ┌───────────┴──────────┐     │
│          │  Custom Bridge 1    │           │         │    Custom Bridge 2   │     │
│          │   (webapp-net)      │           │         │     (backend-net)    │     │
│          │   172.18.0.0/16     │           │         │     172.19.0.0/16    │     │
│          └──────────┬──────────┘           │         └────────────┬─────────┘     │
│                     │                      │                      │               │
│                     │                      │                      │               │
│         ┌───────────┴──────────────────────┴──────────────────────┴───────────┐   │
│         │                         Docker Network Control                      │   │
│         └───────────────────────────────────┬───────────────────────────────────┘   │
│                                            │                                       │
└────────────────────────────────────────────┼───────────────────────────────────────┘
                                             │
                                             ▼
                                       External Network
```

## Example Scenarios - Detailed Explanation

### Scenario 1: Web Application with Database (Custom Bridge Network)

**Use Case:** Deploying a web application that needs to connect securely to a database.

**Network Architecture:**

- Both containers are placed on a user-defined bridge network
- The web application can resolve the database by container name
- The database is not exposed directly to the outside world
- Only the web application port is mapped to the host

**Network Diagram:**

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────────────┐                 ┌─────────────────────┐                   │
│  │   Web Application   │◄───internal─────┤       Database      │                   │
│  │   (webapp-cli)      │     comms       │     (mysql-db)      │                   │
│  │    172.18.0.3       │────────────────►│      172.18.0.2     │                   │
│  └──────────┬──────────┘                 └─────────────────────┘                   │
│             │                                                                      │
│        Port 8081:80                                                                │
│             │                                                                      │
│  ┌──────────┴─────────────────────────────────────────┐                            │
│  │               Custom Bridge Network                │                            │
│  │                 (webapp-network)                   │                            │
│  │                  172.18.0.0/16                     │                            │
│  └──────────────────────────────┬─────────────────────┘                            │
│                                 │                                                  │
└─────────────────────────────────┼──────────────────────────────────────────────────┘
                                  │
                                  ▼
                            User's Browser
                               Port 8081
```

**Benefits:**

- Automatic DNS resolution allows the web app to connect to the database by name
- Database is isolated and only accessible to containers on the same network
- External users can only access the web application, not the database
- Both services can scale independently while maintaining connectivity

**Real-world applications:**

- Content management systems (WordPress, Drupal) with MySQL/MariaDB
- Web applications with backend databases
- Microservices that need private communication channels

### Scenario 2: Direct Host Network Access

**Use Case:** Running monitoring or network tools that need direct access to host network interfaces.

**Network Diagram:**

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐       │
│  │                         Monitoring Container                             │       │
│  │                          (monitoring-app)                                │       │
│  │                                                                          │       │
│  │  ┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌──────────┐  │   │
│  │  │ eth0 Interface│   │eth1 Interface │   │docker0 Bridge │   │ lo      │  │   │
│  │  │ 192.168.1.10  │   │10.0.0.1       │   │172.17.0.1     │   │127.0.0.1 │  │   │
│  │  └───────┬───────┘   └───────┬───────┘   └───────┬───────┘   └────┬─────┘  │   │
│  └──────────┼───────────────────┼───────────────────┼────────────────┼─────────┘   │
│             │                   │                   │                │             │
│  ┌──────────┼───────────────────┼───────────────────┼────────────────┼─────────┐   │
│  │          │                   │                   │                │         │   │
│  │  ┌───────┴───────┐   ┌───────┴───────┐   ┌───────┴───────┐   ┌────┴─────┐  │   │
│  │  │eth0 Interface │   │eth1 Interface │   │docker0 Bridge │   │   lo    │  │   │
│  │  │192.168.1.10   │   │10.0.0.1       │   │172.17.0.1     │   │127.0.0.1 │  │   │
│  │  └───────┬───────┘   └───────┬───────┘   └───────┬───────┘   └────┬─────┘  │   │
│  │          │                   │                   │                │         │   │
│  │                        Host Network Namespace                               │   │
│  └──────────┬───────────────────┬───────────────────┬────────────────┬─────────┘   │
│             │                   │                   │                │             │
└─────────────┼───────────────────┼───────────────────┼────────────────┼─────────────┘
              │                   │                   │                │
              ▼                   ▼                   ▼                ▼
         Physical NIC        Physical NIC         Docker            Loopback
        (External LAN)       (Second NIC)       Containers         Interface
```

**Benefits:**

- Maximum network performance without virtual network overhead
- Direct access to all host network traffic for analysis
- Container can monitor or capture packets on host interfaces
- Simplifies network-level debugging and monitoring

**Real-world applications:**

- Network monitoring tools (Wireshark, tcpdump)
- Performance monitoring applications
- Network security tools and intrusion detection systems
- Network load testing or benchmarking tools

### Scenario 3: Isolated Container (None Network)

**Use Case:** Running sensitive data processing tasks that should have no network access.

**Network Diagram:**

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐                   │
│  │               Isolated Processing Container                  │                   │
│  │                    (secure-processor)                        │                   │
│  │                                                              │                   │
│  │   ┌───────────────────────────────────────────────────┐     │                   │
│  │   │  Loopback Interface Only (lo - 127.0.0.1)         │     │                   │
│  │   └───────────────────────────────────────────────────┘     │                   │
│  │                                                              │                   │
│  │   ┌───────────────────────────────────────────────────┐     │                   │
│  │   │               Processing Task                     │     │                   │
│  │   │        ┌───────────────────────────────┐          │     │                   │
│  │   │        │       Data Volume Mount       │          │     │                   │
│  │   │        └─────────────────┬─────────────┘          │     │                   │
│  │   └─────────────────────────┬┼───────────────────────┬┘     │                   │
│  └─────────────────────────────┼┼───────────────────────┼──────┘                   │
│                                ││                       │                          │
│                                ▼▼                       │                          │
│                   ┌────────────────────────┐            │                          │
│                   │  Host Filesystem       │            │                          │
│                   │  (data-cli/)           │            │                          │
│                   └────────────────────────┘            │                          │
│                                                         │                          │
│                                No Network Connection    ✗                          │
│                                                         │                          │
└─────────────────────────────────────────────────────────┼──────────────────────────┘
                                                          │
                                                          ▼
                                                    External Network
                                                   (Not Accessible)
```

**Benefits:**

- Maximum network security and isolation
- Eliminates network-based attack vectors
- Prevents data exfiltration through network connections
- Ensures container focuses solely on processing tasks

**Real-world applications:**

- Encryption/decryption of sensitive data
- Processing of financial or personal information
- Compliance-related tasks requiring network isolation
- Batch data processing jobs that don't need network access

### Scenario 4: Microservices Communication (Multiple Networks)

**Use Case:** Implementing a microservices architecture with different security zones.

**Network Diagram:**

```
┌─────────────────────────────────── Docker Host ────────────────────────────────────┐
│                                                                                    │
│  ┌─────────────────────┐                                                           │
│  │   Web Frontend      │                                                           │
│  │   (web-frontend)    │                                                           │
│  │   172.20.0.2        │                                                           │
│  └──────────┬──────────┘                                                           │
│             │                             Frontend Network (frontend-net)          │
│             ├─────────────────────────────172.20.0.0/16─────────────────────┐      │
│             │                                                               │      │
│  Port 8000:80│                                                               │      │
│             │                                                               │      │
│             │         ┌─────────────────────┐                               │      │
│             └────────►│   API Service       │◄──────────────────────────────┘      │
│                       │   (api-service)     │                                      │
│                       │   172.20.0.3        │                                      │
│                       │   172.21.0.3        │                                      │
│                       └──────────┬──────────┘                                      │
│                                  │                                                 │
│                                  │                                                 │
│                                  │         Backend Network (backend-net)           │
│                                  ├─────────172.21.0.0/16────────────────┐          │
│                                  │                                      │          │
│                                  │                                      │          │
│                                  ▼                                      │          │
│                        ┌─────────────────────┐                          │          │
│                        │   Database          │◄─────────────────────────┘          │
│                        │   (database)        │                                     │
│                        │   172.21.0.2        │                                     │
│                        └─────────────────────┘                                     │
│                                                                                    │
└────────────────────────────────────┬───────────────────────────────────────────────┘
                                     │
                                     ▼
                               User's Browser
                                 Port 8000
```

**Benefits:**

- Clear separation of concerns and network traffic
- Enhanced security through network segregation
- Services only have access to the networks they need
- API service acts as a secure bridge between networks
- Databases and internal services are not directly accessible from public-facing components

**Real-world applications:**

- E-commerce platforms (frontend, API, payment processing, inventory)
- Multi-tier applications with different security requirements
- Applications that need to comply with data security regulations
- Microservices architectures with clear boundaries between services

## Docker CLI Instructions

### Create and Inspect Networks

```bash
# List all networks
docker network ls

# Create a custom bridge network
docker network create --driver bridge webapp-network

# Inspect network details
docker network inspect webapp-network
```

### Scenario 1: Web Application with Database (Custom Bridge Network)

```bash
# Create the network
docker network create webapp-network

# Create a directory for the web content
mkdir -p webapp-cli
echo "<h1>Web Application with Database Demo</h1><p>This container can connect to the database container using hostname: <code>mysql-db</code></p>" > webapp-cli/index.html

# Run a MySQL container in the network
docker run -d --name mysql-db \
  --network webapp-network \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=webappdb \
  mysql:8.0

# Run a web app container in the same network
docker run -d --name webapp-cli \
  --network webapp-network \
  -p 8081:80 \
  -e DB_HOST=mysql-db \
  -e DB_NAME=webappdb \
  -v "$(pwd)/webapp-cli:/usr/share/nginx/html" \
  nginx:latest

# Test the connection between containers (install ping first)
docker exec webapp-cli sh -c 'apt-get update && apt-get install -y iputils-ping && ping -c 2 mysql-db'

# View logs
docker logs webapp-cli
docker logs mysql-db

# Clean up
docker stop webapp-cli mysql-db
docker rm webapp-cli mysql-db
docker network rm webapp-network
```

### Scenario 2: Direct Host Network Access

```bash
# Run a container with host network
docker run -d --name monitoring-app \
  --network host \
  alpine:latest \
  sh -c "apk add --no-cache iftop htop && echo 'Monitoring container with host network access' && sleep infinity"

# Verify container has host network access by checking network interfaces
docker exec monitoring-app ip addr

# The container can now access localhost and all host ports directly
# To see network traffic (requires root privileges)
docker exec -it monitoring-app iftop

# Clean up
docker stop monitoring-app
docker rm monitoring-app
```

### Scenario 3: Isolated Container (None Network)

```bash
# Create a directory for data processing
mkdir -p data-cli
echo "This is input data for processing" > data-cli/input.txt

# Run a container with no network
docker run -d --name secure-processor \
  --network none \
  -v "$(pwd)/data-cli:/data" \
  alpine:latest \
  sh -c "echo 'Processing files in an isolated container' && mkdir -p /data/processed && echo 'Data processed at $(date)' > /data/processed/result.txt && sleep infinity"

# Verify the container has no network interfaces (only loopback)
docker exec secure-processor ip addr

# Check the processed data
cat data-cli/processed/result.txt

# Clean up
docker stop secure-processor
docker rm secure-processor
```

### Scenario 4: Microservices with Multiple Networks

```bash
# Create frontend and backend networks
docker network create frontend-net
docker network create backend-net

# Create directories for services
mkdir -p api-cli web-cli

# Create a simple API service
cat > api-cli/server.js << 'EOF'
const http = require("http");

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader("Content-Type", "application/json");
  res.end(JSON.stringify({ message: "Hello from API service!" }));
});

server.listen(3000, () => {
  console.log("API server running on port 3000");
});
EOF

# Create HTML for web frontend
cat > web-cli/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Microservices Demo (CLI)</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
    h1 { color: #333; }
    .container { max-width: 800px; margin: 0 auto; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Microservices Demo (CLI)</h1>
    <p>This page is served from the web container.</p>
    <p>The web container is connected to the frontend network.</p>
    <p>The API container is connected to both frontend and backend networks.</p>
    <p>The database container is only connected to the backend network.</p>
    <p>API endpoint: <code>http://api-service:3000</code></p>
  </div>
</body>
</html>
EOF

# Start a database in the backend network
docker run -d --name database \
  --network backend-net \
  -e MYSQL_ROOT_PASSWORD=secret \
  mysql:8.0

# Start an API service connected to the backend network
docker run -d --name api-service \
  --network backend-net \
  -v "$(pwd)/api-cli:/app" \
  -w /app \
  node:18-alpine \
  node server.js

# Connect the API service to the frontend network as well
docker network connect frontend-net api-service

# Start a web frontend in the frontend network
docker run -d --name web-frontend \
  --network frontend-net \
  -p 8000:80 \
  -v "$(pwd)/web-cli:/usr/share/nginx/html" \
  nginx:alpine

# Install wget in containers for testing
docker exec web-frontend apk add --no-cache wget
docker exec api-service apk add --no-cache wget

# Test API communication from web container (should work)
docker exec web-frontend wget -O- api-service:3000

# Test database connection from API container (should work)
docker exec api-service wget -O- database:3306

# Test database connection from web container (should fail)
docker exec web-frontend wget -O- database:3306

# Clean up
docker stop web-frontend api-service database
docker rm web-frontend api-service database
docker network rm frontend-net backend-net
```

## Docker Compose Instructions

The same scenarios can be implemented using Docker Compose for easier management:

### Scenario 1: Web Application with Database (Docker Compose)

```yaml
# webapp-compose.yml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: webappdb
    networks:
      - webapp-network
    volumes:
      - db-data:/var/lib/mysql

  webapp:
    image: nginx:latest
    ports:
      - "8080:80"
    environment:
      DB_HOST: db
      DB_NAME: webappdb
    depends_on:
      - db
    networks:
      - webapp-network
    volumes:
      - ./webapp:/usr/share/nginx/html

networks:
  webapp-network:
    driver: bridge

volumes:
  db-data:
```

Run with: `docker compose -f webapp-compose.yml up -d`

### Scenario 2: Host Network Access (Docker Compose)

```yaml
# monitoring-compose.yml
services:
  monitoring:
    image: alpine:latest
    network_mode: "host"
    command: >
      sh -c "apk add --no-cache iftop htop &&
             echo 'Monitoring container with host network access' &&
             sleep infinity"
    privileged: true
```

Run with: `docker compose -f monitoring-compose.yml up -d`

### Scenario 3: Isolated Container (Docker Compose)

```yaml
# processing-compose.yml
services:
  processor:
    image: alpine:latest
    network_mode: "none"
    command: |
      sh -c 'echo "Processing files in an isolated container" &&
             mkdir -p /data/processed &&
             touch /data/processed/result.txt &&
             echo "Data processed at $(date)" > /data/processed/result.txt &&
             cat /data/processed/result.txt &&
             echo "Container has no network access for security" &&
             sleep infinity'
    volumes:
      - ./data:/data
```

Run with: `docker compose -f processing-compose.yml up -d`

### Scenario 4: Microservices (Docker Compose)

```yaml
# microservices-compose.yml
services:
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: appdb
    networks:
      - backend-net
    volumes:
      - db-data:/var/lib/mysql

  api:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - ./api:/app
    command: >
      sh -c "echo 'API service starting...' &&
             echo 'const http = require(\"http\");
             const server = http.createServer((req, res) => {
               res.statusCode = 200;
               res.setHeader(\"Content-Type\", \"application/json\");
               res.end(JSON.stringify({ message: \"Hello from API service!\" }));
             });
             server.listen(3000);
             console.log(\"API server running on port 3000\");' > server.js &&
             node server.js"
    depends_on:
      - database
    networks:
      - backend-net
      - frontend-net

  web:
    image: nginx:alpine
    ports:
      - "8888:80"
    volumes:
      - ./web:/usr/share/nginx/html
    depends_on:
      - api
    networks:
      - frontend-net
    command: >
      sh -c "echo '<!DOCTYPE html>
      <html>
      <head>
        <title>Microservices Demo</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
          h1 { color: #333; }
          .container { max-width: 800px; margin: 0 auto; }
        </style>
      </head>
      <body>
        <div class=\"container\">
          <h1>Microservices Demo</h1>
          <p>This page is served from the web container.</p>
          <p>The web container is connected to the frontend network.</p>
          <p>The API container is connected to both frontend and backend networks.</p>
          <p>The database container is only connected to the backend network.</p>
          <p>API endpoint: <code>http://api:3000</code></p>
        </div>
      </body>
      </html>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"

networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge

volumes:
  db-data:
```

Run with: `docker compose -f microservices-compose.yml up -d`

## Testing Network Connectivity

### For Scenario 1

```bash
# Test database connectivity in the webapp container
docker exec -it $(docker ps -qf name=webapp) sh -c 'apt-get update && apt-get install -y iputils-ping && ping -c 2 db'
```

### For Scenario 2

```bash
# Check all network interfaces in the host-networked container
docker exec -it $(docker ps -qf name=monitoring) ip addr
```

### For Scenario 3

```bash
# Verify there are only loopback interfaces
docker exec -it $(docker ps -qf name=processor) ip addr
```

### For Scenario 4

```bash
# Install wget for testing
docker exec $(docker ps -qf name=web) apk add --no-cache wget
docker exec $(docker ps -qf name=api) apk add --no-cache wget

# Test API connectivity from web container (should work)
docker exec $(docker ps -qf name=web) wget -O- api:3000

# Test that web cannot access database directly (should fail)
docker exec $(docker ps -qf name=web) wget -O- database:3306

# Test that API can access database (should work)
docker exec $(docker ps -qf name=api) wget -O- database:3306
```

## Clean Up Instructions

For Docker CLI scenarios, clean-up commands are included at the end of each scenario block.

For Docker Compose scenarios:

```bash
# Stop and remove containers, networks, and volumes
docker compose -f webapp-compose.yml down -v
docker compose -f monitoring-compose.yml down
docker compose -f processing-compose.yml down
docker compose -f microservices-compose.yml down -v

# Remove any remaining networks manually if needed
docker network rm webapp-network frontend-net backend-net lab3_webapp-network lab3_frontend-net lab3_backend-net 2>/dev/null || true

# Remove any manually created containers
docker rm -f $(docker ps -aq --filter name=webapp --filter name=mysql-db --filter name=monitoring-app --filter name=secure-processor --filter name=api-service --filter name=web-frontend --filter name=database) 2>/dev/null || true

# Optionally remove created directories
# rm -rf webapp webapp-cli data data-cli api api-cli web web-cli
```

## Best Practices

1. Use custom bridge networks instead of the default bridge for better isolation and automatic DNS resolution
2. Name your containers in the same network for easy service discovery
3. Only expose ports that are necessary
4. Use host network only when the container needs direct access to host interfaces
5. Use the "none" network for containers that process sensitive data and don't need network connectivity
6. Prefer Docker Compose for complex multi-container setups
