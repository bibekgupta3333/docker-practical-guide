// Variables
variable "APP_NAME" {
  default = "docker-bake-example"
}

variable "REGISTRY" {
  default = "myregistry.io"
}

variable "VERSION" {
  default = "1.0.0"
}

// Groups
group "default" {
  targets = ["app-dev"]
}

group "production" {
  targets = ["app-prod"]
}

group "all" {
  targets = ["app-dev", "app-prod", "app-test"]
}

// Base target
target "base" {
  dockerfile = "Dockerfile"
  context = "."
}

// Development target
target "app-dev" {
  inherits = ["base"]
  target = "development"
  tags = ["${REGISTRY}/${APP_NAME}:dev"]
}

// Production target
target "app-prod" {
  inherits = ["base"]
  target = "production"
  tags = [
    "${REGISTRY}/${APP_NAME}:${VERSION}",
    "${REGISTRY}/${APP_NAME}:latest"
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

// Test target
target "app-test" {
  inherits = ["base"]
  target = "development"
  tags = ["${REGISTRY}/${APP_NAME}:test"]
  args = {
    NODE_ENV = "test"
  }
} 