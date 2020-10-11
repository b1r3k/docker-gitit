## Dockerfile for gitit
FROM debian:buster as builder

RUN echo 'deb-src http://deb.debian.org/debian/ unstable main' >> /etc/apt/sources.list
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    mime-support \
    git \
    pbuilder \
    build-essential \
    ca-certificates \
    devscripts \
    equivs \
    packaging-dev \
    debian-keyring \
    curl

WORKDIR /tmp
RUN echo 'deb-src http://deb.debian.org/debian/ buster main' >> /etc/apt/sources.list && apt update
RUN apt source gitit/unstable
RUN apt source gitit/buster
RUN cp gitit-0.12*/debian/control gitit-0.13*/debian/
RUN cd gitit-0.13* && mk-build-deps --tool 'apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y' --install --remove
RUN cd gitit* && dch --bpo
RUN cd gitit* && dpkg-buildpackage -us -uc
RUN ls -lau /tmp

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

COPY --from=builder /tmp/gitit_*_*.deb /tmp
RUN yes | apt install /tmp/gitit_*_*.deb

VOLUME ["/data"]

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR /data
EXPOSE 5001
CMD ["gitit", "-f", "/data/gitit.conf"]
