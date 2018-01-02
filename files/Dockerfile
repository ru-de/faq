FROM golang:latest
MAINTAINER Evgenii Sokolov <e.sokolov@sevensenders.com>

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git less sudo mc wget curl

COPY check-install.sh /tmp
RUN cd /tmp && sh /tmp/check-install.sh
