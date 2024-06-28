FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Package versions
ARG GEOFETCH_VERSION=0.12.6
ARG PIPER_VERSION=0.14.2
ARG SRA_TOOLKIT_VERSION=3.1.1

# Install dependencies
RUN apt-get update && apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pip dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir geofetch==${GEOFETCH_VERSION} piper==${PIPER_VERSION}

# Install SRA Toolkit
RUN wget -q "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${SRA_TOOLKIT_VERSION}/sratoolkit.${SRA_TOOLKIT_VERSION}-ubuntu64.tar.gz" -O sratoolkit.tar.gz && \
    tar -xzf sratoolkit.tar.gz && \
    cp -r sratoolkit.${SRA_TOOLKIT_VERSION}-ubuntu64/bin/* /usr/local/bin/ && \
    rm -rf sratoolkit.tar.gz sratoolkit.${SRA_TOOLKIT_VERSION}-ubuntu64

ENTRYPOINT ["/bin/bash", "-c"]
