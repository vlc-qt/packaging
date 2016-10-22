FROM ubuntu:xenial
MAINTAINER Tadej Novak <tadej@tano.si>

RUN apt-get update && apt-get install -y \
    sudo build-essential gdb git ccache \
    devscripts debhelper apt-transport-https

RUN echo '%adm ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV LC_ALL="C.UTF-8" LANG="C.UTF-8"

# Install common dependencies
RUN apt-get update && apt-get install -y \
    cmake doxygen xvfb

# Qt5
RUN apt-get update && apt-get install -y \
    qt5-default qtbase5-dev qtdeclarative5-dev qtdeclarative5-dev-tools qml-module-qttest

# VLC
RUN apt-get update && apt-get install -y \
    libvlc-dev libvlccore-dev vlc-nox

# Builder user
RUN mkdir -p /home/builder
RUN useradd -s /bin/bash -u 1000 -d /home/builder builder
RUN usermod -a -G adm builder || :;\
    usermod -a -G sudo builder || :
USER builder
