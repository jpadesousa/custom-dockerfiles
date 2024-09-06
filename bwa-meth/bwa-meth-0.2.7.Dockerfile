FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update pip and setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools toolshed

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    wget \
    tar \
    bzip2 \
    build-essential \
    libncurses5-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    perl \
    cpanminus \
    gzip \
    make \
    gcc \
    && cpanm File::Copy::Recursive \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG SAMTOOLS_VERSION=1.20
ARG BWA_VERSION=0.7.18
ARG BWA_METH_VERSION=0.2.7

# Install Samtools
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar -xjvf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf samtools-${SAMTOOLS_VERSION} samtools-${SAMTOOLS_VERSION}.tar.bz2

# Install BWA
RUN wget https://github.com/lh3/bwa/archive/refs/tags/v${BWA_VERSION}.tar.gz \
    && tar -xzvf v${BWA_VERSION}.tar.gz \
    && cd bwa-${BWA_VERSION} \
    && make \
    && mv bwa /usr/local/bin/ \
    && cd .. \
    && rm -rf bwa-${BWA_VERSION} v${BWA_VERSION}.tar.gz

# Install bwa-meth
RUN wget https://github.com/brentp/bwa-meth/archive/refs/tags/v${BWA_METH_VERSION}.tar.gz -O bwa-meth-${BWA_METH_VERSION}.tar.gz \
    && tar -xzf bwa-meth-${BWA_METH_VERSION}.tar.gz \
    && cd bwa-meth-${BWA_METH_VERSION} \
    && cd .. \
    && rm -rf bwa-meth-${BWA_METH_VERSION}.tar.gz

ENV PATH="/bwa-meth-${BWA_METH_VERSION}:${PATH}"

# Create a non-root user to run the application
RUN groupadd -r bwamethuser && \
    useradd --no-log-init -r -g bwamethuser bwamethuser
    
# Switch to non-root user
USER bwamethuser

CMD ["bwameth.py"]