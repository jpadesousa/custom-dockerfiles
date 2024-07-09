FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update pip and setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    wget \
    tar \
    build-essential \
    libncurses5-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG SAMTOOLS_VERSION=1.20
ARG HISAT2_VERSION=2.2.1

# Install Samtools
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar -xjvf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf samtools-${SAMTOOLS_VERSION} samtools-${SAMTOOLS_VERSION}.tar.bz2

# Install HISAT2
RUN wget https://github.com/DaehwanKimLab/hisat2/archive/refs/tags/v${HISAT2_VERSION}.tar.gz -O hisat2.tar.gz \
    && tar -xzf hisat2.tar.gz \
    && cd hisat2-${HISAT2_VERSION} \
    && make \
    && mv hisat2* /usr/local/bin/ \
    && cd .. \
    && rm -rf hisat2-${HISAT2_VERSION} hisat2.tar.gz

# Create a non-root user to run the application
RUN groupadd -r hisat2user && \
    useradd --no-log-init -r -g hisat2user hisat2user
    
# Switch to non-root user
USER hisat2user

CMD ["hisat2"]