# Dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install build dependencies for psycopg2, then clean up
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all application code
COPY . .

# Make the entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Define the script that runs on container start
ENTRYPOINT ["/app/entrypoint.sh"]

# Define the default command to be executed by the entrypoint script
# This is the command that keeps the container alive
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
