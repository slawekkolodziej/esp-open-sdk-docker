FROM debian:jessie-slim

MAINTAINER Slawek Kolodziej <hfrntt@gmail.com>

ENV ESP_HOME=/home/esp
ENV SDK_PATH=$ESP_HOME/esp-open-sdk
ENV WORKSPACE_PATH=$ESP_HOME/workspace

RUN apt-get update

RUN apt-get install -y make unrar-free autoconf automake libtool gcc g++ gperf \
    flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python-serial \
    sed git unzip bash help2man wget bzip2 libtool-bin sudo \
 && apt-get clean

RUN useradd -d /home/esp -m esp \
 && usermod -a -G dialout,staff esp \
 && mkdir -p /etc/sudoers.d \
 && echo "esp ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/esp \
 && chmod 0440 /etc/sudoers.d/esp

USER esp

WORKDIR $ESP_HOME
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git \
 && git clone --recursive https://github.com/Superhouse/esp-open-rtos.git

WORKDIR $SDK_PATH
RUN make toolchain esptool libhal STANDALONE=n \
 && rm -fr $SDK_PATH/crosstool-NG

ENV PATH $SDK_PATH/xtensa-lx106-elf/bin:$PATH

WORKDIR $WORKSPACE_PATH
