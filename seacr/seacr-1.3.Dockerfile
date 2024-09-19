FROM python:3.12.4-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    wget \
    tar \
    build-essential \
    ca-certificates \
    gzip \
    make \
    gcc \
    zlib1g-dev \
    r-base \
    libbz2-dev \
    liblzma-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package version
ARG SEACR_VERSION=1.3
ARG BEDTOOLS_VERSION=2.31.1

# Install Bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz \
    && tar -xzf bedtools-${BEDTOOLS_VERSION}.tar.gz \
    && cd bedtools2 \
    && make \
    && mv bin/* /usr/local/bin/ \
    && cd .. \
    && rm -rf bedtools2 bedtools-${BEDTOOLS_VERSION}.tar.gz

# Install SEACR
RUN wget https://github.com/FredHutch/SEACR/archive/refs/tags/v${SEACR_VERSION}.tar.gz \
    && tar -xzf v${SEACR_VERSION}.tar.gz \
    && chmod +x SEACR-${SEACR_VERSION}/SEACR_1.3.sh \
    && rm -rf v${SEACR_VERSION}.tar.gz

# Create a non-root user to run the application
RUN groupadd -r seacruser && \
    useradd --no-log-init -r -g seacruser seacruser

# Change the ownership of the SEACR folder
RUN chown -R seacruser:seacruser /SEACR-${SEACR_VERSION}

# Add SEACR to path
ENV PATH="/SEACR-${SEACR_VERSION}:${PATH}"

# Switch to non-root user
USER seacruser

CMD ["bash", "SEACR_1.3.sh"]