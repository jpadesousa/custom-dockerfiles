FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Package versions
ARG NFCORE_VERSION=2.14.1
ARG NEXTFLOW_VERSION=24.04.2

# Install system dependencies
RUN apt-get update && apt-get install -y curl git && \
    rm -rf /var/lib/apt/lists/*

# Install Nextflow
RUN curl -s -L https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow-${NEXTFLOW_VERSION}-all -o /usr/local/bin/nextflow && \
    chmod +x /usr/local/bin/nextflow

# Install pip dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir nf-core==${NFCORE_VERSION}

CMD ["nf-core"]
