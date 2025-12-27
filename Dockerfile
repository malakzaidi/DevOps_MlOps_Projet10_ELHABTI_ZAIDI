# Base image with Python 3.9 (slim for smaller size)
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install required system dependencies (for OpenCV, etc.)
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first (better layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project context into the image
# This includes benchmark.py, app/, scripts/, etc.
COPY . .

# === CRITICAL SAFETY CHECKS ===
# Fail the build early if benchmark.py is missing (e.g. due to .dockerignore)
RUN if [ ! -f "/app/benchmark.py" ]; then \
        echo "ERROR: benchmark.py is MISSING in the Docker image!" && \
        echo "Current files in /app:" && \
        ls -la /app/ && \
        exit 1; \
    fi

RUN echo "benchmark.py successfully copied into image:" && \
    ls -la /app/benchmark.py

# Create necessary directories (in case they are empty or git-ignored)
RUN mkdir -p models data results

# Optional: Make benchmark.py executable (useful if running directly)
# RUN chmod +x benchmark.py

# Default command: run the benchmark script
# (You can override this in docker run if needed)
CMD ["python", "benchmark.py", "--help"]