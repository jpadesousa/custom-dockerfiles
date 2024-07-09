FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update pip and setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    wget \
    build-essential \
    perl \
    gzip \
    unzip \
    libgd-graph-perl \
    libncurses5-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    cpanminus \
    && cpanm File::Copy::Recursive \
    && cpanm GD::Graph \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG BISMARK_VERSION=0.24.2
ARG BOWTIE_VERSION=1.3.1
ARG BOWTIE2_VERSION=2.5.4
ARG SAMTOOLS_VERSION=1.20
ARG FASTQ_SCREEN_VERSION=0.15.3
ARG BWA_VERSION=0.7.18

# Install Bowtie
RUN wget https://github.com/BenLangmead/bowtie/releases/download/v${BOWTIE_VERSION}/bowtie-${BOWTIE_VERSION}-linux-x86_64.zip \
    && unzip bowtie-${BOWTIE_VERSION}-linux-x86_64.zip \
    && mv bowtie-${BOWTIE_VERSION}-linux-x86_64/bowtie* /usr/local/bin/ \
    && rm -rf bowtie-${BOWTIE_VERSION}-linux-x86_64 bowtie-${BOWTIE_VERSION}-linux-x86_64.zip

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

# Install Bismark
RUN wget https://github.com/FelixKrueger/Bismark/archive/refs/tags/v${BISMARK_VERSION}.tar.gz \
    && tar -xzvf v${BISMARK_VERSION}.tar.gz \
    && rm v${BISMARK_VERSION}.tar.gz

# Add Bismark scripts to PATH by creating symbolic links in /usr/local/bin
RUN find /Bismark-${BISMARK_VERSION} -type f -executable -exec ln -s {} /usr/local/bin \;

# Install BWA
RUN wget https://github.com/lh3/bwa/archive/refs/tags/v${BWA_VERSION}.tar.gz \
    && tar -xzvf v${BWA_VERSION}.tar.gz \
    && cd bwa-${BWA_VERSION} \
    && make \
    && mv bwa /usr/local/bin/ \
    && cd .. \
    && rm -rf bwa-${BWA_VERSION} v${BWA_VERSION}.tar.gz

# Install FastQ Screen
RUN wget https://github.com/StevenWingett/FastQ-Screen/archive/refs/tags/v${FASTQ_SCREEN_VERSION}.tar.gz \
    && tar -xzvf v${FASTQ_SCREEN_VERSION}.tar.gz \
    && rm v${FASTQ_SCREEN_VERSION}.tar.gz

# Add FastQ Screen scripts to PATH by creating symbolic links in /usr/local/bin
RUN find /FastQ-Screen-${FASTQ_SCREEN_VERSION} -type f -executable -exec ln -s {} /usr/local/bin \;

# Create a non-root user to run the application and switch to it
RUN groupadd -r fastqscreenuser && \
    useradd --no-log-init -r -g fastqscreenuser fastqscreenuser
USER fastqscreenuser

CMD ["fastq_screen"]