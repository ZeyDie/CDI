# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java with Apache Kafka 4.0.0
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM openjdk:21-slim

LABEL maintainer="ZeyDie <zeydie.dev@gmail.com>"

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    openssl \
    git \
    tar \
    bash \
    sqlite3 \
    fontconfig \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container container

ENV KAFKA_VERSION=4.0.0
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# Устанавливаем Kafka
RUN mkdir -p /opt/kafka \
    && wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.12-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz \
    && tar xfz /tmp/kafka.tgz -C /opt/kafka --strip-components=1 \
    && rm -f /tmp/kafka.tgz

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]