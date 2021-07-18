FROM ubuntu:18.04
MAINTAINER Evgenii Sokolov <ewgraf@gmail.com>

RUN apt-get -yqq update && apt-get install -y wget git locales
RUN cd /tmp && wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin:/root/go/bin"
RUN locale-gen --no-purge en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
ENV LC_ALL "en_US.UTF-8"
COPY . /tmp/files/ci
RUN cd /tmp/files/ci && bash check-install.sh
