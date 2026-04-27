# Use the official Microsoft Playwright base image (includes Node.js and all browser dependencies)
FROM mcr.microsoft.com/playwright:v1.40.0-jammy

# Update system and install Python3 and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment (required in newer Ubuntu versions)
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Robot Framework and the Playwright wrapper (Browser library)
RUN pip install --no-cache-dir robotframework robotframework-browser

# Initialize the Browser library (downloads the specific Playwright binaries)
RUN rfbrowser init

# Set the working directory inside the container
WORKDIR /tests

# Command to execute the tests and save reports to the /tests/results folder
CMD ["robot", "-d", "/tests/results", "/tests/worker_test.robot"]