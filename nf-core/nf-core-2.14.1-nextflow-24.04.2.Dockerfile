# Build stage for Git
FROM debian:bullseye-slim as git-builder

ARG GIT_VERSION=2.45.2

RUN apt-get update && apt-get install -y \
    procps \
    curl \
    build-essential \
    libssl-dev \
    libghc-zlib-dev \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz -o git.tar.gz && \
    tar -zxf git.tar.gz && \
    cd git-${GIT_VERSION} && \
    make prefix=/usr all && \
    make prefix=/usr install


# Final image
FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

ARG NFCORE_VERSION=2.14.1
ARG NEXTFLOW_VERSION=24.04.2
ARG APPTAINER_VERSION=1.3.3

# Copy Git from the build stage
COPY --from=git-builder /usr/bin/git /usr/bin/git
COPY --from=git-builder /usr/libexec/git-core /usr/libexec/git-core

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Nextflow
RUN curl -fsSL https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow-${NEXTFLOW_VERSION}-all -o /usr/local/bin/nextflow && \
    chmod +x /usr/local/bin/nextflow

# Install Apptainer (Singularity)
RUN apt-get update && apt-get install -y \
    wget \
    libfuse3-3 \
    uidmap \
    squashfs-tools \
    fakeroot \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_VERSION}/apptainer_${APPTAINER_VERSION}_amd64.deb \
    && dpkg -i apptainer_${APPTAINER_VERSION}_amd64.deb \
    && rm apptainer_${APPTAINER_VERSION}_amd64.deb \
    && ln -s /usr/bin/apptainer /usr/local/bin/singularity

# Install pip dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir nf-core==${NFCORE_VERSION}

# Create a non-root user and switch to it
RUN groupadd -r nfcoreuser && \
    useradd --no-log-init -r -g nfcoreuser nfcoreuser -m -d /home/nfcoreuser

# Set ownership for the home directory
RUN chown -R nfcoreuser:nfcoreuser /home/nfcoreuser

USER nfcoreuser

CMD ["nf-core"]