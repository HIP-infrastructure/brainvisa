ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
#FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG} as ghostfs
#FROM brainvisa:5.0.4
FROM brainvisa:5.1.0

LABEL maintainer="florian.sipp@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
#    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    # ghostfs
    fuse libfuse2 binutils libssl-dev && \
    curl -sSOL https://github.com/pouya-eghbali/ghostfs-builds/releases/download/linux-ubuntu-22.04-6201193-dev/GhostFS && \
    chmod +x GhostFS && \
    mv GhostFS /usr/bin
    #apt-get remove -y --purge curl && \
    #apt-get autoremove -y --purge && \
    #apt-get clean && \
    #rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="/casa/install/bin/brainvisa"
ENV PROCESS_NAME="/casa/install/bin/brainvisa"
ENV APP_DATA_DIR_ARRAY=".brainvisa .anatomist brainvisa_db"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
