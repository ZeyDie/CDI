# Copyright (c) 2020, 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

ARG BASE_IMAGE=container-registry.oracle.com/os/oraclelinux:10-slim

FROM ${BASE_IMAGE}

# Note: If you are behind a web proxy, set the build variables for the build:
#       E.g.:  docker build --build-arg "https_proxy=..." --build-arg "http_proxy=..." --build-arg "no_proxy=..." ...
LABEL \
    org.opencontainers.image.url='https://github.com/graalvm/container' \
    org.opencontainers.image.source='https://github.com/graalvm/container/tree/master/graalvm-community' \
    org.opencontainers.image.title='GraalVM Community Edition' \
    org.opencontainers.image.authors='GraalVM Sustaining Team <graalvm-sustaining_ww_grp@oracle.com>' \
    org.opencontainers.image.description='GraalVM is a universal virtual machine for running applications written in JavaScript, Python, Ruby, R, JVM-based languages like Java, Scala, Clojure, Kotlin, and LLVM-based languages such as C and C++.'

ARG TARGETPLATFORM

RUN microdnf update -y oraclelinux-release-el10 \
    && microdnf --enablerepo ol10_codeready_builder install -y bzip2-devel ed gcc gcc-c++ gcc-gfortran gzip file fontconfig less libcurl-devel make openssl openssl-devel readline-devel tar glibc-langpack-en \
    vi which xz-devel zlib-devel findutils glibc-static libstdc++ libstdc++-devel libstdc++-static zlib-static libxcrypt-compat \
    && microdnf clean all

RUN fc-cache -f -v

ARG JDK_MAJOR_VERSION=17
ARG JDK_VERSION=17.0.9
ARG JDK_BUILD=+9.1

ENV LANG=en_US.UTF-8 \
    JAVA_HOME=/opt/graalvm-community-java$JDK_MAJOR_VERSION

RUN set -eux \
    && case "$TARGETPLATFORM" in \
        "linux/amd64") \
            GRAALVM_ARCH="x64" \
            ;; \
        "linux/arm64") \
            GRAALVM_ARCH="aarch64" \
            ;; \
        *) \
            echo "Unsupported platform: $TARGETPLATFORM" \
            exit 1 \
            ;; \
    esac \
    && GRAALVM_FILE="graalvm-community-jdk-${JDK_VERSION}_linux-${GRAALVM_ARCH}_bin.tar.gz" \
    && GRAALVM_URL="https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${JDK_VERSION}/${GRAALVM_FILE}" \
    && echo "Target platform: $TARGETPLATFORM" \
    && echo "GraalVM file: $GRAALVM_FILE" \
    && curl --fail --silent --location --retry 3 "${GRAALVM_URL}" \
	| gunzip | tar x -C /opt/
    && mv "/opt/graalvm-community-openjdk-${JDK_VERSION}${JDK_BUILD}" "$JAVA_HOME" \
    && mkdir -p "/usr/java" \
    && ln -sfT "$JAVA_HOME" /usr/java/default \
    && ln -sfT "$JAVA_HOME" /usr/java/latest

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]