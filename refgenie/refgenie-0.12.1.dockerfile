FROM python:3.12.4-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update system packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget \
    tar \
    unzip \
    bzip2 \
    procps \
    build-essential \
    libncurses5-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    vim-common \
    git \
    cmake \
    make \
    g++ \
    libgsl-dev \
    genometools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV MINICONDA_VERSION=py312_24.5.0-0
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Set PATH to include conda
ENV PATH /opt/conda/bin:$PATH

# Package version
ARG REFGENIE_VERSION=0.12.1
ARG BOWTIE_VERSION=1.3.1
ARG BOWTIE2_VERSION=2.5.4
ARG HISAT2_VERSION=2.2.1
ARG STAR_VERSION=2.7.11b
ARG BISMARK_VERSION=0.24.2
ARG SAMTOOLS_VERSION=1.20
ARG BWA_VERSION=0.7.18
ARG KALLISTO_VERSION=0.50.1
ARG SALMON_VERSION=1.10.3
ARG CELLRANGER_VERSION=8.0.1
ARG BEDTOOLS_VERSION=2.31.1
ARG MASHMAP_VERSION=3.1.3

# Install Salmon
RUN conda update -n base -c defaults conda
RUN conda install -c conda-forge boost
RUN conda install -c conda-forge -c bioconda salmon=${SALMON_VERSION}

# Install MashMap
RUN wget https://github.com/marbl/MashMap/archive/refs/tags/v${MASHMAP_VERSION}.tar.gz \
    && tar -xzf v${MASHMAP_VERSION}.tar.gz \
    && cd MashMap-${MASHMAP_VERSION} \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && mv /MashMap-${MASHMAP_VERSION}/build/bin/mashmap /usr/local/bin/ \
    && cd ../.. \
    && rm -rf MashMap-${MASHMAP_VERSION} v${MASHMAP_VERSION}.tar.gz

# Install Samtools
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar -xjvf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf samtools-${SAMTOOLS_VERSION} samtools-${SAMTOOLS_VERSION}.tar.bz2

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

# Install HISAT2
RUN wget https://github.com/DaehwanKimLab/hisat2/archive/refs/tags/v${HISAT2_VERSION}.tar.gz -O hisat2.tar.gz \
    && tar -xzf hisat2.tar.gz \
    && cd hisat2-${HISAT2_VERSION} \
    && make \
    && mv hisat2* /usr/local/bin/ \
    && cd .. \
    && rm -rf hisat2-${HISAT2_VERSION} hisat2.tar.gz

# Install STAR
RUN wget https://github.com/alexdobin/STAR/archive/refs/tags/${STAR_VERSION}.tar.gz -O ${STAR_VERSION}.tar.gz \
    && tar -xzf ${STAR_VERSION}.tar.gz \
    && cd STAR-${STAR_VERSION}/source \
    && make STAR \
    && mv STAR* /usr/local/bin/ \
    && cd ../.. \
    && rm -rf STAR-${STAR_VERSION} ${STAR_VERSION}.tar.gz

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

# Install Kallisto
RUN wget https://github.com/pachterlab/kallisto/releases/download/v${KALLISTO_VERSION}/kallisto_linux-v${KALLISTO_VERSION}.tar.gz \
    && tar -xzf kallisto_linux-v${KALLISTO_VERSION}.tar.gz \
    && mv kallisto/kallisto /usr/local/bin/ \
    && cd .. \
    && rm -rf kallisto_linux-v${KALLISTO_VERSION}.tar.gz kallisto

# Install Bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz \
    && tar -xzf bedtools-${BEDTOOLS_VERSION}.tar.gz \
    && cd bedtools2 \
    && make \
    && mv bin/* /usr/local/bin/ \
    && cd .. \
    && rm -rf bedtools2 bedtools-${BEDTOOLS_VERSION}.tar.gz

# Install Cell Ranger
COPY cellranger-${CELLRANGER_VERSION}.tar /opt/
RUN tar -xzf /opt/cellranger-${CELLRANGER_VERSION}.tar -C /opt/ \
    && rm /opt/cellranger-${CELLRANGER_VERSION}.tar
ENV PATH="/opt/cellranger-${CELLRANGER_VERSION}:${PATH}"

# Install refgenie
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir refgenie==${REFGENIE_VERSION}

# Create a non-root user and switch to it
RUN groupadd -r refgenieuser && \
    useradd --no-log-init -r -g refgenieuser refgenieuser
USER refgenieuser

CMD ["refgenie"]