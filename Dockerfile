# Stage 1: Build the Go application
FROM golang:1.17-alpine AS go-builder

WORKDIR /app

# Install Go dependencies
COPY go.mod go.sum ./
RUN go mod tidy

# Copy and build the Go application
COPY . ./
RUN go build -o /main

# Stage 2: Build the Python environment and include Go binary
FROM python:3.9-slim AS python-env

# Install system dependencies required for Prophet, Python libraries, and Cloud SQL Auth Proxy
RUN apt-get update && apt-get install -y \
    libpq-dev gcc g++ make curl supervisor && \
    pip install --no-cache-dir pandas sqlalchemy psycopg2 prophet dash plotly pystan==2.19.1.1

# Install the Cloud SQL Auth Proxy
RUN curl -o /cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && \
    chmod +x /cloud_sql_proxy

# Copy the Go binary from the builder stage
COPY --from=go-builder /main /main

# Set the working directory
WORKDIR /app

# Copy Python scripts into the image
COPY covid_forecasting.py .
COPY covid_dashboard.py .

# Create supervisord configuration to run Go and Python apps
COPY supervisord.conf /etc/supervisord/conf.d/supervisord.conf

# Expose ports for both services
EXPOSE 8080 8000

# Run the supervisor process to manage both Go and Python services
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# # Stage 1: Build the Go application
# FROM golang:1.17-alpine AS go-builder

# WORKDIR /app

# # Install Go dependencies
# COPY go.mod go.sum ./
# RUN go mod tidy

# # Copy and build the Go application
# COPY . ./
# RUN go build -o /main

# # Stage 2: Build the Python environment and include Go binary
# FROM python:3.9-slim AS python-env

# # Install system dependencies required for Prophet, Python libraries, and Cloud SQL Auth Proxy
# RUN apt-get update && apt-get install -y \
#     libpq-dev gcc g++ make curl && \
#     pip install --no-cache-dir pandas sqlalchemy psycopg2 prophet dash plotly pystan==2.19.1.1

# # Install the Cloud SQL Auth Proxy
# RUN curl -o /cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && \
#     chmod +x /cloud_sql_proxy

# # Copy the Go binary from the builder stage
# COPY --from=go-builder /main /main

# # Set the working directory
# WORKDIR /app

# # Copy Python scripts into the image
# COPY covid_forecasting.py .
# COPY covid_dashboard.py .

# # Expose ports for both services
# EXPOSE 8080 8000

# # Set the PORT environment variable for the Python service
# ENV PORT 8000

# # Run both the Go service and the Python environment
# CMD ["bash", "-c", "/main & python3 covid_forecasting.py && python3 covid_dashboard.py"]
