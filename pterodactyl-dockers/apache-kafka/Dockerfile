# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java with Apache Kafka 4.0.0
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM ghcr.io/graalvm/graalvm-ce:java21 AS graalvm

# Копируем JRE в Alpine
FROM alpine:3.18

RUN apk add --no-cache --update \
    libstdc++ \
    zlib \
    && mkdir -p /opt/graalvm

# Копируем GraalVM из официального образа
COPY --from=graalvm /opt/graalvm-ce-java21-* /opt/graalvm

ENV JAVA_HOME=/opt/graalvm
ENV PATH=$PATH:$JAVA_HOME/bin

MAINTAINER ZeyDie, <zeydie.dev@gmail.com>

RUN apk add --no-cache --update \
    curl \
    ca-certificates \
    openssl \
    git \
    tar \
    bash \
    sqlite \
    fontconfig \
    wget \
    && adduser --disabled-password --home /home/container container

ENV KAFKA_VERSION=4.0.0
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

RUN mkdir -p /opt/kafka \
    && wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.12-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz \
    && tar xfz /tmp/kafka.tgz -C /opt/kafka --strip-components=1 \
    && rm -f /tmp/kafka.tgz

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]