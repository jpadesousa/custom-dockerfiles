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
    bzip2 \
    build-essential \
    libncurses5-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    perl \
    cpanminus \
    && cpanm File::Copy::Recursive \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG BOWTIE2_VERSION=2.5.4
ARG HISAT2_VERSION=2.2.1
ARG MINIMAP2_VERSION=2.28
ARG SAMTOOLS_VERSION=1.20
ARG BISMARK_VERSION=0.24.2

# Install Bowtie2
RUN wget https://github.com/BenLangmead/bowtie2/archive/v${BOWTIE2_VERSION}.tar.gz \
    && tar -xzvf v${BOWTIE2_VERSION}.tar.gz \
    && cd bowtie2-${BOWTIE2_VERSION} \
    && make \
    && make install \
    && cd .. \
    && rm -rf bowtie2-${BOWTIE2_VERSION} v${BOWTIE2_VERSION}.tar.gz

# Install HISAT2
RUN wget https://github.com/DaehwanKimLab/hisat2/archive/refs/tags/v${HISAT2_VERSION}.tar.gz -O hisat2.tar.gz \
    && tar -xzf hisat2.tar.gz \
    && cd hisat2-${HISAT2_VERSION} \
    && make \
    && mv hisat2* /usr/local/bin/ \
    && cd .. \
    && rm -rf hisat2-${HISAT2_VERSION} hisat2.tar.gz

# Install minimap2
RUN wget https://github.com/lh3/minimap2/releases/download/v${MINIMAP2_VERSION}/minimap2-${MINIMAP2_VERSION}_x64-linux.tar.bz2 -O minimap2.tar.bz2 \
    && tar -xjf minimap2.tar.bz2 \
    && mv minimap2-${MINIMAP2_VERSION}_x64-linux/minimap2 /usr/local/bin/ \
    && rm -rf minimap2-${MINIMAP2_VERSION}_x64-linux minimap2.tar.bz2

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

# Create a non-root user to run the application
RUN groupadd -r bismarkuser && \
    useradd --no-log-init -r -g bismarkuser bismarkuser
    
# Switch to non-root user
USER bismarkuser

CMD ["bismark"]