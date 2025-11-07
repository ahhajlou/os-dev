#!/bin/bash

set -ex

export BINUTILS_VERSION=2.44
export GCC_VERSION=14.2.0

create_dir_or_remove_contents() {
    dir_name=$1
    if [ -d "$dir_name" ]; then
        rm -rf "$dir_name"/*
    else
        mkdir -p "$dir_name"
    fi
}

if [ -f "${WORKSPACE_DIR}/.dependencies-installed" ]; then
    exit 0
fi

echo -e "\033[1;32mStarting to build dependencies\033[0m"

create_dir_or_remove_contents "$PREFIX"
create_dir_or_remove_contents "$SRC_DIR"

echo -e "\033[1;32mDownloading files\033[0m"

cd "${SRC_DIR}"
wget -q https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz && \
    wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar -xf binutils-${BINUTILS_VERSION}.tar.gz && \
    tar -xf gcc-${GCC_VERSION}.tar.gz

echo -e "\033[1;32mBuild and install binutils\033[0m"
# Build and install binutils
mkdir "$SRC_DIR/build-binutils"
cd "$SRC_DIR/build-binutils"
${SRC_DIR}/binutils-${BINUTILS_VERSION}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --with-sysroot \
      --disable-nls \
      --disable-werror && \
    make -j"$(nproc)" && \
    make install

echo -e "\033[1;32mBuild and install gcc\033[0m"
# Build and install GCC (minimal cross, without headers)
mkdir "$SRC_DIR/build-gcc"
cd "$SRC_DIR/build-gcc"
${SRC_DIR}/gcc-${GCC_VERSION}/configure \
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

touch "${WORKSPACE_DIR}/.dependencies-installed"

exit 0