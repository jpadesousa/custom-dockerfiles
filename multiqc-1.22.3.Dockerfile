FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update and upgrade system packages
RUN apt-get update && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG MULTIQC_VERSION=1.22.3

# Install pip dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir multiqc==${MULTIQC_VERSION}

# Create a non-root user and switch to it
RUN groupadd -r multiqcuser && \
    useradd --no-log-init -r -g multiqcuser multiqcuser
USER multiqcuser

CMD ["multiqc"]