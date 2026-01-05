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

ARG JDK_MAJOR_VERSION=17
ARG JDK_VERSION=17.0.9
ARG JDK_BUILD=+9.1

ENV LANG=en_US.UTF-8 \
    JAVA_HOME=/opt/graalvm-community-java$JDK_MAJOR_VERSION

RUN set -eux \
    && if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        GRAALVM_ARCH="x64"; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        GRAALVM_ARCH="aarch64"; \
    else \
        echo "Unsupported platform: $TARGETPLATFORM"; exit 1; \
    fi \
    && GRAALVM_URL="https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${JDK_VERSION}/graalvm-community-jdk-${JDK_VERSION}_linux-${GRAALVM_ARCH}_bin.tar.gz" \
    && echo "Downloading GraalVM for $TARGETPLATFORM..." \
    && curl --fail --silent --location --retry 3 "${GRAALVM_URL}" | tar -xz -C /opt/ \
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