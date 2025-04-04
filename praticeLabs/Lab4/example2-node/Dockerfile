# Stage 1: Development/Build environment
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm install

# Copy application code
COPY . .

# If you needed to build the app (e.g., for TypeScript, Next.js, etc.):
# RUN npm run build

# Stage 2: Production environment
FROM node:18-alpine AS production

# Set NODE_ENV to production
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy application code from builder (if using a build step)
# COPY --from=builder /app/dist /app/dist

# Or simply copy from the local filesystem for this example
COPY --from=builder /app/src ./src

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["node", "src/index.js"] 