FROM python:3.9.19-slim-bullseye

# Install build dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    build-essential \
    python3-dev \
    libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG MACS3_VERSION=3.0.1
ARG CYKHASH_VERSION=2.0.1

# Update pip and install MACS3 and cykhash
RUN python3 -m venv /venv
RUN /venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /venv/bin/pip install --no-cache-dir MACS3==${MACS3_VERSION} cykhash==${CYKHASH_VERSION}

# Set environment variables to ensure the virtual environment is used
ENV PATH="/venv/bin:$PATH"

# Create a non-root user and switch to it
RUN groupadd -r macsuser && \
    useradd --no-log-init -r -g macsuser macsuser
USER macsuser

CMD ["macs3"]