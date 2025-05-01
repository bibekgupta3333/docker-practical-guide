# Base stage for both production and development
FROM node:18-alpine AS base
WORKDIR /app

# Add a healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:3000 || exit 1

# Install dependencies
COPY app/package*.json ./
RUN npm install && \
    mkdir -p /app/node_modules && \
    chown -R node:node /app

# Development stage
FROM base AS development
ENV NODE_ENV=development
# Use node user for better security
USER node
# Copy source files
COPY --chown=node:node app/ ./
# Expose port
EXPOSE 3000
# Run in development mode with hot reloading
CMD ["npm", "run", "dev"]

# Production build stage
FROM base AS production-build
ENV NODE_ENV=production
USER node
# Copy source files
COPY --chown=node:node app/ ./
# Prune dev dependencies
RUN npm prune --production

# Final production stage
FROM node:18-alpine AS production
ENV NODE_ENV=production
WORKDIR /app

# Add a healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:3000 || exit 1

# Create app directory and set permissions
RUN mkdir -p /app && \
    chown -R node:node /app

# Switch to non-root user
USER node

# Copy from build stage
COPY --from=production-build --chown=node:node /app/node_modules ./node_modules
COPY --from=production-build --chown=node:node /app/index.js ./

# Expose port
EXPOSE 3000

# Command to run the application
CMD ["node", "index.js"] 