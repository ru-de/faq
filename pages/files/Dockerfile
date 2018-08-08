# check https://docs.travis-ci.com/user/common-build-problems/#troubleshooting-locally-in-a-docker-image
FROM travisci/ci-garnet:packer-1512502276-986baf0
MAINTAINER Evgenii Sokolov <e.sokolov@sevensenders.com>

USER travis
ENV GOPATH "/home/travis/gopath"
ENV GOROOT "/home/travis/.gimme/versions/go1.7.4.linux.amd64"
ENV PATH "$GOPATH/bin:$GOROOT/bin:$PATH"
COPY . $GOPATH/src/github.com/ru-de/faq/files
RUN cd $GOPATH/src/github.com/ru-de/faq && sudo env PATH=$PATH GOPATH=$GOPATH bash files/check-install.sh
