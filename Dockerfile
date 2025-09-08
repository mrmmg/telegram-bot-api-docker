# Build stage
FROM ubuntu:22.04 AS builder
ARG DEBIAN_FRONTEND=noninteractive

# Base system setup with ccache for faster rebuilds
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y make git zlib1g-dev libssl-dev gperf cmake ccache ninja-build && \
    apt-get install -y clang-15 libc++-15-dev libc++abi-15-dev && \
    rm -rf /var/lib/apt/lists/*

# Setup ccache for maximum performance
ENV CCACHE_DIR=/tmp/ccache
ENV PATH="/usr/lib/ccache:$PATH"
ENV CCACHE_MAXSIZE=2G
ENV CCACHE_COMPRESS=1
RUN ccache --max-size=2G --set-config=compression=true

# Clone telegram-bot-api with shallow clone for speed
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git /telegram-bot-api
WORKDIR /telegram-bot-api
RUN rm -rf build && mkdir build
WORKDIR /telegram-bot-api/build

# Compile using clang-15 with libc++ and Ninja generator for faster builds
RUN CC=clang-15 CXX=clang++-15 CXXFLAGS="-stdlib=libc++" cmake \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local ..

# Build with ninja using all CPU cores (much faster than make)
RUN ninja -j$(nproc) install

# Runtime stage - minimal image
FROM ubuntu:22.04
ARG TELEGRAM_API_ID
ARG TELEGRAM_API_HASH
ARG DEBIAN_FRONTEND=noninteractive

# Install only runtime dependencies
RUN apt-get update && \
    apt-get install -y libssl3 libc++1-15 && \
    rm -rf /var/lib/apt/lists/*

# Copy only the built binary from builder stage
COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

# Set working directory
WORKDIR /var/lib/telegram-bot-api

# JSON-array ENTRYPOINT handles signals correctly
ENTRYPOINT ["telegram-bot-api","--api-id=${TELEGRAM_API_ID}","--api-hash=${TELEGRAM_API_HASH}","--local"]