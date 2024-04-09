ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG APP_VERSION
FROM ${CI_REGISTRY_IMAGE}/brainvisa-vbox:${APP_VERSION}
ARG VIRTUALGL_VERSION
ARG GHOSTFS_VERSION

LABEL maintainer="florian.sipp@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    #apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    # ghostfs
    fuse libfuse2 binutils libssl-dev \
    # virtualgl
    ca-certificates libglu1-mesa libegl1-mesa libxv1 libxtst6 && \
    # cleanup the brainvisa-vbox image
    apt-get remove -y --purge iproute2 iptables iputils-ping iputils-tracepath bind9-dnsutils bind9-host bind9-libs 
    #apt-get autoremove -y --purge && \
    #apt-get clean && \
    #rm -rf /var/lib/apt/lists/*

# ghostfs
RUN curl -sSOL https://github.com/pouya-eghbali/ghostfs-builds/releases/download/linux-ubuntu-22.04-${GHOSTFS_VERSION}/GhostFS && \
    chmod +x GhostFS && \
    mv GhostFS /usr/bin

# virtualgl
RUN curl -sSO https://s3.amazonaws.com/virtualgl-pr/main/linux/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    rm virtualgl_${VIRTUALGL_VERSION}_amd64.deb

ENV APP_SPECIAL="no"
ENV APP_CMD="/casa/install/bin/brainvisa"
ENV PROCESS_NAME="/casa/install/bin/brainvisa"
ENV APP_DATA_DIR_ARRAY=".brainvisa .anatomist brainvisa_db"
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/
COPY ./apps/${APP_NAME}/config config/
COPY ./apps/${APP_NAME}/config/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
