FROM debian:bullseye-slim

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    wget \
    tar \
    build-essential \
    ca-certificates \
    vim-common \
    zlib1g \
    zlib1g-dev \
    git \
    make \
    gcc \
    curl \
    less \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG GENRICH_VERSION=0.6.1

# Install Genrich
RUN wget https://github.com/jsh58/Genrich/archive/refs/tags/v${GENRICH_VERSION}.tar.gz \
    && tar -xzvf v${GENRICH_VERSION}.tar.gz \
    && cd Genrich-${GENRICH_VERSION} \
    && make \
    && cd .. \
    && rm -rf v${GENRICH_VERSION}.tar.gz

ENV PATH="/Genrich-${GENRICH_VERSION}:${PATH}"

# Create a non-root user to run the application
RUN groupadd -r genrichuser && \
    useradd --no-log-init -r -g genrichuser genrichuser
    
# Switch to non-root user
USER genrichuser

CMD ["Genrich"]