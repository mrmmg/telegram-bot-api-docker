FROM ubuntu:22.04

ARG TELEGRAM_API_ID
ARG TELEGRAM_API_HASH

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y make git zlib1g-dev libssl-dev gperf cmake clang-10 libc++-dev libc++abi-dev
RUN echo "Asia/Tehran" > /etc/timezone

RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git
WORKDIR /telegram-bot-api
RUN rm -rf build && mkdir build

WORKDIR /telegram-bot-api/build

RUN CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-10 CXX=/usr/bin/clang++-10 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..
RUN cmake --build . --target install

WORKDIR /var/lib/telegram-bot-api

ENTRYPOINT telegram-bot-api --api-id=${TELEGRAM_API_ID} --api-hash=${TELEGRAM_API_HASH} --local
