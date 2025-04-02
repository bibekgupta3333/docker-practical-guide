# Stage 1: Build dependencies
FROM python:3.10-slim AS builder

# Set working directory
WORKDIR /app

# Install Poetry
RUN pip install poetry==1.5.1

# Copy Poetry configuration
COPY pyproject.toml ./

# Configure Poetry to not create a virtual environment
RUN poetry config virtualenvs.create false

# Install dependencies
RUN poetry install --no-dev --no-interaction --no-ansi

# Stage 2: Development with all dependencies
FROM builder AS development

# Copy application code
COPY . .

# Install development dependencies
RUN poetry install --no-interaction --no-ansi

# Default command for development
CMD ["python", "app.py"]

# Stage 3: Production with minimal dependencies
FROM python:3.10-slim AS production

# Set working directory
WORKDIR /app

# Set Python to not write bytecode and not buffer output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copy installed packages from builder stage
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY app.py .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"] 