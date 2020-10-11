## Dockerfile for gitit
FROM debian:buster as builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    mime-support \
    git \
    pbuilder \
    build-essential \
    ca-certificates \
    devscripts \
    equivs \
    curl

RUN mkdir /tmp/gitit
WORKDIR /tmp/gitit
RUN curl -s http://deb.debian.org/debian/pool/main/g/gitit/gitit_0.12.3.1+dfsg-1.debian.tar.xz --output gitit_0.12.3.1+dfsg-1.debian.tar.xz
RUN tar xvf gitit_0.12.3.1+dfsg-1.debian.tar.xz
RUN sed -i 's/gitit (0.12.3.1+dfsg-1)/gitit (0.13.0.0+dfsg-1)/g' debian/changelog
RUN /usr/bin/mk-build-deps
RUN yes | apt install ./gitit*.deb
RUN curl -s -L https://github.com/jgm/gitit/archive/0.13.0.0.tar.gz --output gitit_0.13.0.0+dfsg.orig.tar.gz
RUN cp gitit_0.13.0.0+dfsg.orig.tar.gz ../
RUN pdebuild
RUN ls

FROM debian:buster-slim
MAINTAINER Lukasz Jachym "lukasz.jachym <at> gmail <dot> com"

ENV DEBIAN_FRONTEND noninteractive

# make the "en_US.UTF-8" locale
RUN apt-get update \
    && apt-get install -y locales \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

## install gitit
RUN apt-get update \
    && apt-get install -y --no-install-recommends mime-support git pandoc \
    && rm -rf /var/lib/apt/lists/*

RUN cabal update && cabal install gitit

VOLUME ["/data"]

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR /data
EXPOSE 5001
CMD ["gitit", "-f", "/data/gitit.conf"]
