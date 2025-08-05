# Dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install build dependencies, psycopg2, AND dos2unix for fixing line endings
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev dos2unix && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all application code
COPY . .

# --- THE CRITICAL FIX ---
# Ensure the entrypoint script has correct Unix line endings and is executable
RUN dos2unix /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Define the script that runs on container start
ENTRYPOINT ["/app/entrypoint.sh"]

# Define the default command to be executed by the entrypoint script
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
