FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update system packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Package version
ARG CUTADAPT_VERSION=4.9

# Install cutadapt
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir cutadapt==${CUTADAPT_VERSION}

# Create a non-root user and switch to it
RUN groupadd -r cutadaptuser && \
    useradd --no-log-init -r -g cutadaptuser cutadaptuser
USER cutadaptuser

CMD ["cutadapt"]