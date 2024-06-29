# Build stage for compiling and installing dependencies
FROM python:3.9.19-slim-bullseye as builder

# Install build dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG MACS3_VERSION=3.0.1
ARG CYKHASH_VERSION=2.0.1

# Install pip dependencies in a virtual environment
RUN python3 -m venv /venv
# Update pip and install MACS3 and cykhash
RUN /venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /venv/bin/pip install --no-cache-dir MACS3==${MACS3_VERSION} cykhash==${CYKHASH_VERSION}


# Final image
FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Copy virtual environment from builder stage
COPY --from=builder /venv /venv

# Set environment variables to ensure the virtual environment is used
ENV PATH="/venv/bin:$PATH"

# Create a non-root user and switch to it
RUN groupadd -r macsuser && \
    useradd --no-log-init -r -g macsuser macsuser
USER macsuser

CMD ["macs3"]