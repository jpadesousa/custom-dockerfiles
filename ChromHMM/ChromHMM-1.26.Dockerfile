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
    openjdk-11-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Package versions
ARG CHROMHMM_VERSION=1.26

# Install ChromHMM
RUN wget https://github.com/jernst98/ChromHMM/archive/refs/tags/v${CHROMHMM_VERSION}.tar.gz -O v${CHROMHMM_VERSION}.tar.gz \
&& tar -xzf v${CHROMHMM_VERSION}.tar.gz \
&& mv ChromHMM-${CHROMHMM_VERSION} /opt/ChromHMM \
&& rm v${CHROMHMM_VERSION}.tar.gz

# Add ChromHMM to PATH
ENV PATH="/opt/ChromHMM:${PATH}"

# Create a non-root user to run the application
RUN groupadd -r chromhmmuser && \
    useradd --no-log-init -r -g chromhmmuser chromhmmuser
    
# Switch to non-root user
USER chromhmmuser

# Change the work directory to be where ChromHMM.jar is stored
WORKDIR /opt/ChromHMM

CMD ["java", "-jar", "ChromHMM.jar"]