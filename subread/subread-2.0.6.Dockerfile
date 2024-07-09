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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG SUBREAD_VERSION=2.0.6

# Install subread
RUN wget https://sourceforge.net/projects/subread/files/subread-${SUBREAD_VERSION}/subread-${SUBREAD_VERSION}-Linux-x86_64.tar.gz/download -O subread-${SUBREAD_VERSION}-Linux-x86_64.tar.gz \
    && tar -xzf subread-${SUBREAD_VERSION}-Linux-x86_64.tar.gz \
    && mv subread-${SUBREAD_VERSION}-Linux-x86_64/bin/* /usr/local/bin/ \
    && rm -rf subread-${SUBREAD_VERSION}-Linux-x86_64 subread-${SUBREAD_VERSION}-Linux-x86_64.tar.gz

# Create a non-root user to run the application
RUN groupadd -r subreaduser && \
    useradd --no-log-init -r -g subreaduser subreaduser
    
# Switch to non-root user
USER subreaduser

CMD ["subread-align"]