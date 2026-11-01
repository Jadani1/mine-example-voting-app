# base defines a base stage that uses the official python runtime base image (already pinned to version 3.11-slim)
FROM python:3.11-slim AS base

# Add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Set the application directory
WORKDIR /usr/local/app

# Install our requirements.txt
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# dev defines a stage for development, where it'll watch for filesystem changes
FROM base AS dev
RUN pip install watchdog
ENV FLASK_ENV=development
CMD ["python", "app.py"]

# final defines the stage that will bundle the application for production
FROM base AS final

# 1. Create a non-root system user and group
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 2. Copy our code from the current folder to the working directory
COPY . .

# 3. Change ownership of the application folder to the non-root user
RUN chown -R appuser:appuser /usr/local/app

# 4. Switch from root to the non-root user
USER appuser

# Make port 80 available for links and/or publish
EXPOSE 80

# Define our command to be run when launching the container
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:80", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]