# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java with Apache Kafka 4.0.0
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM eclipse-temurin:21-jre-alpine

LABEL maintainer="ZeyDie <zeydie.dev@gmail.com>"

# Устанавливаем минимально необходимые пакеты
RUN apk add --no-cache \
    bash \
    curl \
    tar

# Создаем непривилегированного пользователя
RUN adduser -D -h /home/container container && \
    mkdir -p /opt/kafka && \
    chown container:container /opt/kafka

ENV KAFKA_VERSION=4.0.0
ENV SCALA_VERSION=2.12
ENV KAFKA_HOME=/opt/kafka
ENV PATH="${PATH}:${KAFKA_HOME}/bin"

# Скачиваем и распаковываем Kafka (без проверки PGP)
RUN cd /tmp && \
    KAFKA_DIST="kafka_${SCALA_VERSION}-${KAFKA_VERSION}" && \
    curl -sSLO "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz" && \
    tar -xzf "${KAFKA_DIST}.tgz" -C /opt/kafka --strip-components=1 && \
    rm -rf /tmp/*

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]