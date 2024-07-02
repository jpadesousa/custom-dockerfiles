FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Update pip and setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    axel \
    procps \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG SRADOWNLOADER_VERSION=3.11
ARG SRA_TOOLKIT_VERSION=3.1.1

# Install SRA Toolkit
RUN wget -q "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${SRA_TOOLKIT_VERSION}/sratoolkit.${SRA_TOOLKIT_VERSION}-ubuntu64.tar.gz" -O sratoolkit.tar.gz && \
    tar -xzf sratoolkit.tar.gz && \
    cp -r sratoolkit.${SRA_TOOLKIT_VERSION}-ubuntu64/bin/* /usr/local/bin/ && \
    rm -rf sratoolkit.tar.gz sratoolkit.${SRA_TOOLKIT_VERSION}-ubuntu64

# Install sradownloader
RUN wget https://github.com/jpadesousa/sradownloader-axel/archive/refs/tags/v${SRADOWNLOADER_VERSION}.tar.gz \
    && tar -xzvf v${SRADOWNLOADER_VERSION}.tar.gz \
    && rm v${SRADOWNLOADER_VERSION}.tar.gz

# Add SRAdownloader scripts to PATH by creating symbolic links in /usr/local/bin
RUN find /sradownloader-axel-${SRADOWNLOADER_VERSION} -type f -executable -exec ln -s {} /usr/local/bin \;

# Create a folder to store the downloaded files
RUN mkdir /downloads

# Create a non-root user and switch to it
RUN groupadd -r sradownloaderuser --gid=1000 && \
    useradd --no-log-init -r -g sradownloaderuser --uid=1000 sradownloaderuser && \
    chown -R sradownloaderuser:sradownloaderuser /downloads

USER sradownloaderuser

# Set the working directory
WORKDIR /downloads

CMD ["sradownloader"]