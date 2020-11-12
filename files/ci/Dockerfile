# check https://docs.travis-ci.com/user/common-build-problems/#troubleshooting-locally-in-a-docker-image
FROM ubuntu:18.04
MAINTAINER Evgenii Sokolov <e.sokolov@sevensenders.com>

RUN apt-get -yqq update && apt-get install -y wget
RUN cd /tmp && wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz
RUN cd /tmp && tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin"
COPY . /tmp/files/ci
RUN apt-get -yqq update && apt-get install -y git
RUN cd /tmp/files/ci && bash check-install.sh
