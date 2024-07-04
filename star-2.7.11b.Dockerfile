FROM debian:bullseye-slim

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    procps \
    wget \
    tar \
    build-essential \
    ca-certificates \
    vim-common \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG STAR_VERSION=2.7.11b

# Install STAR
RUN wget https://github.com/alexdobin/STAR/archive/refs/tags/${STAR_VERSION}.tar.gz -O ${STAR_VERSION}.tar.gz \
&& tar -xzf ${STAR_VERSION}.tar.gz \
&& cd STAR-${STAR_VERSION}/source \
&& make STAR \
&& mv STAR* /usr/local/bin/ \
&& cd ../.. \
&& rm -rf STAR-${STAR_VERSION} ${STAR_VERSION}.tar.gz

# Create a non-root user to run the application
RUN groupadd -r staruser && \
    useradd --no-log-init -r -g staruser staruser
    
# Switch to non-root user
USER staruser

CMD ["STAR"]