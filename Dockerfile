FROM ubuntu:22.04

ARG TELEGRAM_API_ID
ARG TELEGRAM_API_HASH
ARG DEBIAN_FRONTEND=noninteractive

ARG DEBIAN_FRONTEND=noninteractive

# Base system setup
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y make git zlib1g-dev libssl-dev gperf cmake && \
    apt-get install -y clang-15 libc++-15-dev libc++abi-15-dev

# Clone and build telegram-bot-api
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git /telegram-bot-api
WORKDIR /telegram-bot-api
RUN rm -rf build && mkdir build
WORKDIR /telegram-bot-api/build

# Compile using clang-15 with libc++
RUN CC=clang-15 CXX=clang++-15 CXXFLAGS="-stdlib=libc++" cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local ..
RUN cmake --build . --target install

WORKDIR /var/lib/telegram-bot-api

# JSON-array ENTRYPOINT handles signals correctly
ENTRYPOINT ["telegram-bot-api","--api-id=${TELEGRAM_API_ID}","--api-hash=${TELEGRAM_API_HASH}","--local"]
