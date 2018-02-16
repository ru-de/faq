# check https://docs.travis-ci.com/user/common-build-problems/#Running-a-Container-Based-Docker-Image-Locally
FROM travisci/ci-garnet:packer-1512502276-986baf0
MAINTAINER Evgenii Sokolov <e.sokolov@sevensenders.com>

ENV GOPATH "/home/travis/gopath"
ENV GOROOT "/home/travis/.gimme/versions/go1.7.4.linux.amd64"
ENV PATH "$GOPATH/bin:$GOROOT/bin:$PATH"
COPY check-install.sh /tmp
RUN bash /tmp/check-install.sh
