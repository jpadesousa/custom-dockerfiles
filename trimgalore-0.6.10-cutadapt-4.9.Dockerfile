FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    curl \
    perl \
    default-jre \
    isal \
    pigz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG CUTADAPT_VERSION=4.9
ARG FASTQC_VERSION=0.12.1
ARG TRIM_GALORE_VERSION=0.6.10

# Install cutadapt
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir cutadapt==${CUTADAPT_VERSION}

# Install FastQC
RUN curl -fsSL https://github.com/s-andrews/FastQC/archive/refs/tags/v${FASTQC_VERSION}.tar.gz -o fastqc.tar.gz && \
    tar xvzf fastqc.tar.gz && \
    chmod +x FastQC-${FASTQC_VERSION}/fastqc && \
    mv FastQC-${FASTQC_VERSION}/fastqc /usr/local/bin/fastqc && \
    rm fastqc.tar.gz && \
    rm -r FastQC-${FASTQC_VERSION}

# Install TrimGalore
RUN curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/${TRIM_GALORE_VERSION}.tar.gz -o trim_galore.tar.gz && \
    tar xvzf trim_galore.tar.gz && \
    chmod +x TrimGalore-${TRIM_GALORE_VERSION}/trim_galore && \
    mv TrimGalore-${TRIM_GALORE_VERSION}/trim_galore /usr/local/bin/trim_galore && \
    rm trim_galore.tar.gz && \
    rm -r TrimGalore-${TRIM_GALORE_VERSION}

# Create a non-root user and switch to it
RUN groupadd -r trimgaloreuser && \
    useradd --no-log-init -r -g trimgaloreuser trimgaloreuser
USER trimgaloreuser

CMD ["trim_galore"]