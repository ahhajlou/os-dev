FROM ubuntu:22.04

# Non-interactive configuration
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ARG BINUTILS_VERSION=2.44
ARG GCC_VERSION=14.2.0
ARG TARGET=i686-elf
ARG ROOT_DIR=/workspace
ARG PREFIX="$ROOT_DIR/cross"
ARG SRC_DIR="$ROOT_DIR/src"
ARG OS_DIR="$ROOT_DIR/os"
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

# Copy cross toolchain from builder
RUN mkdir -p "$PREFIX"

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

RUN mkdir -p "$PREFIX" "$SRC_DIR" "$OS_DIR"

WORKDIR "$SRC_DIR"
# Fetch sources
RUN wget -q https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz && \
    wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar -xf binutils-${BINUTILS_VERSION}.tar.gz && \
    tar -xf gcc-${GCC_VERSION}.tar.gz

# Build and install binutils
RUN ${SRC_DIR}/binutils-${BINUTILS_VERSION}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --with-sysroot \
      --disable-nls \
      --disable-werror && \
    make -j"$(nproc)" && \
    make install

# Build and install GCC (minimal cross, without headers)
RUN ${SRC_DIR}/gcc-${GCC_VERSION}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --disable-nls \
      --enable-languages=c,c++ \
      --without-headers \
      --disable-hosted-libstdcxx && \
      make -j"$(nproc)" all-gcc && \
      make -j"$(nproc)" all-target-libgcc && \
      make -j"$(nproc)" all-target-libstdc++-v3 && \
      make install-gcc && \
      make install-target-libgcc && \
      make install-target-libstdc++-v3


RUN apt-get install -y --no-install-recommends \
    git vim file binwalk grub2-common xorriso && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


WORKDIR "$OS_DIR"
ENTRYPOINT [ "/bin/bash" ]
