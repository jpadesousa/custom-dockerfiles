FROM debian:bullseye-slim

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    ca-certificates \
    wget \
    tar \
    bzip2 \
    build-essential \
    libncurses5-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl3-gnutls \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG BOWTIE2_VERSION=2.5.4
ARG SAMTOOLS_VERSION=1.20

# Install Bowtie2
RUN wget https://github.com/BenLangmead/bowtie2/archive/v${BOWTIE2_VERSION}.tar.gz \
    && tar -xzvf v${BOWTIE2_VERSION}.tar.gz \
    && cd bowtie2-${BOWTIE2_VERSION} \
    && make \
    && make install \
    && cd .. \
    && rm -rf bowtie2-${BOWTIE2_VERSION} v${BOWTIE2_VERSION}.tar.gz

# Install Samtools
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar -xjvf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf samtools-${SAMTOOLS_VERSION} samtools-${SAMTOOLS_VERSION}.tar.bz2

# Create a non-root user to run the application
RUN groupadd -r bowtie2user && \
    useradd --no-log-init -r -g bowtie2user bowtie2user
    
# Switch to non-root user
USER bowtie2user

CMD ["bowtie2"]