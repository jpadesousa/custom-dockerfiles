FROM python:3.9.19-slim-bullseye

LABEL maintainer="João Agostinho de Sousa <joao.agostinhodesousa@hest.ethz.ch>"

# Package versions
ARG CUTADAPT_VERSION=4.9

# Install cutadapt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir cutadapt==${CUTADAPT_VERSION}

CMD ["cutadapt"]
