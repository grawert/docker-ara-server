# This file is subject to the terms and conditions defined in file 'LICENSE',
# which is part of this repository.

FROM ubuntu:16.04
MAINTAINER Betacloud Solutions GmbH (https://www.betacloud-solutions.de)

ENV DEBIAN_FRONTEND noninteractive
ARG VERSION
ENV VERSION ${VERSION:-0.11.0}

COPY files/extend_start.sh /extend_start.sh
ADD patches /patches

RUN apt-get update \ 
    && apt-get install -y \ 
        libffi-dev \
        libssl-dev \
        python-dev \
        python-pip \ 
        git \
    && pip install --upgrade pip \
    && git clone -b $VERSION https://github.com/openstack/ara /ara-repository \
    && for patchfile in $(find patches -name "*.patch"); do patch -p1 < $patchfile; done \
    && pip install /ara-repository \
    && groupadd kolla \
    && useradd -m -d /var/lib/ara-server ara-server \
    && usermod -a -G kolla ara-server \
    && mkdir /ara \
    && chown ara-server: /ara \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /ara-repository /patches

USER ara-server

ENTRYPOINT ["/extend_start.sh"]