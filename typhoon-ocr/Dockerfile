FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
  apt-get install -y poppler-utils && \
  rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create data directory
RUN mkdir -p /app/data

# Expose port
EXPOSE 8000

# Run the application
CMD ["python", "server.py"] 