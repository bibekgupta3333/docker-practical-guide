# Docker FastAPI Tutorial

This tutorial demonstrates how to containerize a FastAPI application using Docker and Docker Compose.

## Project Structure

```
Lab1/
├── app/
│   └── main.py           # FastAPI application
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Docker Compose configuration
├── requirements.txt      # Python dependencies
└── README.md             # This file
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop for Windows/Mac)

## Step-by-Step Guide

### 1. Understanding the Application

The application is a simple FastAPI REST API with the following endpoints:

- GET `/`: Returns a welcome message
- GET `/items/{item_id}`: Returns item details for a given ID
- POST `/items/`: Creates a new item

### 2. Building and Running with Docker CLI

#### Build the Docker Image

```bash
cd Lab1
docker build -t fastapi-tutorial .
```

#### Run the Container

```bash
docker run -p 8000:8000 --name fastapi-app fastapi-tutorial
```

#### Additional Docker CLI Commands

Stop the container:

```bash
docker stop fastapi-app
```

Remove the container:

```bash
docker rm fastapi-app
```

List all containers:

```bash
docker ps -a
```

List all images:

```bash
docker images
```

### 3. Using Docker Compose

#### Start the Services

```bash
cd Lab1
docker compose up
```

To run in detached mode (background):

```bash
docker compose up -d
```

#### Stop the Services

```bash
docker compose down
```

### 4. Testing the API

Once the application is running, you can access:

- API documentation: http://localhost:8000/docs
- API root endpoint: http://localhost:8000/

Example to create an item using curl:

```bash
curl -X POST http://localhost:8000/items/ \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Item", "price": 10.5, "description": "This is a test item"}'
```

Example to get an item:

```bash
curl http://localhost:8000/items/1
```

### 5. Development with Volume Mounting

When using Docker Compose, changes to the files in the `app` directory will automatically be reflected in the container due to the volume mounting configuration.

## Explanation of Docker Concepts

### Dockerfile

- `FROM python:3.9-slim`: Uses Python 3.9 slim as the base image
- `WORKDIR /app`: Sets the working directory
- `COPY requirements.txt .`: Copies the requirements file
- `RUN pip install...`: Installs the dependencies
- `COPY ./app /app`: Copies the application code
- `EXPOSE 8000`: Documents that the container listens on port 8000
- `CMD ["uvicorn"...]`: Specifies the command to run the application

### Docker Compose

The `docker-compose.yml` file defines the service configuration:

- `build`: Builds the image from the Dockerfile
- `ports`: Maps host port 8000 to container port 8000
- `volumes`: Mounts local `app` directory to container `/app`
- `restart`: Automatically restarts the container unless stopped
