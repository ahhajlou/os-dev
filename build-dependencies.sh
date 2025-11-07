#!/bin/bash

set -e

export BINUTILS_VERSION=2.44
export GCC_VERSION=14.2.0

DEPENDENCIES_INSTALLED_FILE_PATH="${WORKSPACE_DIR}/dependencies/.dependencies-installed"

ensure_clean_directory() {
    dir_name=$1

    if [ -z "$dir_name" ]; then
        echo "ensure_clean_directory: directory path must be provided" >&2
        exit 1
    fi

    case "$dir_name" in
        "/"|"."|".."|"")
            echo "ensure_clean_directory: refusing to operate on '$dir_name'" >&2
            exit 1
            ;;
    esac

    if [ -d "$dir_name" ]; then
        find "$dir_name" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    else
        mkdir -p "$dir_name"
    fi

    mkdir -p "$dir_name"
}

if [ -f "${DEPENDENCIES_INSTALLED_FILE_PATH}" ]; then
    exit 0
fi

echo -e "\033[1;32mStarting to build dependencies\033[0m"

ensure_clean_directory "$PREFIX"
ensure_clean_directory "$SRC_DIR"

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

touch "${DEPENDENCIES_INSTALLED_FILE_PATH}"

exit 0