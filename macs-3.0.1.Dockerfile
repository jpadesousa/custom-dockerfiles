FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Package versions
ARG MACS3_VERSION=3.0.1
ARG CYKHASH_VERSION=2.0.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    libffi-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install pip dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir MACS3==${MACS3_VERSION} cykhash==${CYKHASH_VERSION}

CMD ["macs3"]
