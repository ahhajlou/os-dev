FROM ubuntu:22.04

# Non-interactive configuration
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV TARGET=i686-elf
ENV WORKSPACE_DIR=/workspace
ENV PREFIX="$WORKSPACE_DIR/dependencies/cross"
ENV SRC_DIR="$WORKSPACE_DIR/dependencies/src"
ENV OS_DIR="$WORKSPACE_DIR/os-dev"
ENV PATH="$PREFIX/bin:$PATH"

# Create non-root user with passwordless sudo
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates && \
    useradd -G sudo -m --shell /bin/bash dev && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "dev:dev" | chpasswd && \
    update-ca-certificates

RUN apt-get install -y --no-install-recommends \
        build-essential \
        bison \
        flex \
        libgmp3-dev \
        libmpc-dev \
        libmpfr-dev \
        texinfo \
        libisl-dev \
        wget

RUN apt-get install -y --no-install-recommends \
    git vim file binwalk grub2-common xorriso && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./build-dependencies.sh /opt/build-dependencies.sh
COPY ./entrypoint.sh /opt/entrypoint.sh

RUN chmod +x /opt/build-dependencies.sh && \
    chmod +x /opt/entrypoint.sh

WORKDIR "$OS_DIR"
ENTRYPOINT [ "/opt/entrypoint.sh" ]
