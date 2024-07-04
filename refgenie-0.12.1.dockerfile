FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update system packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package version
ARG REFGENIE_VERSION=0.12.1

# Install refgenie
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir refgenie==${REFGENIE_VERSION}

# Create a non-root user and switch to it
RUN groupadd -r refgenieuser && \
    useradd --no-log-init -r -g refgenieuser refgenieuser
USER refgenieuser

CMD ["refgenie"]