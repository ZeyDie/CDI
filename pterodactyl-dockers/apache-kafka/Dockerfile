# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java with Apache Kafka
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM eclipse-temurin:21-jre-alpine

LABEL maintainer="ZeyDie <zeydie.dev@gmail.com>"

# Устанавливаем минимально необходимые пакеты
RUN apk add --no-cache \
    bash \
    curl \
    tar \
    libstdc++

# Создаем пользователя и директории
RUN adduser -D -h /home/container container && \
    mkdir -p /opt/kafka && \
    chown container:container /opt/kafka

# Используем стабильную версию Kafka
ENV KAFKA_VERSION=4.0.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/opt/kafka
ENV PATH="${PATH}:${KAFKA_HOME}/bin"

# Скачиваем Kafka с возможностью выбора зеркала
RUN set -eux; \
    cd /tmp; \
    KAFKA_DIST="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"; \
    if ! curl -sSfL --retry 3 --retry-delay 10 -O "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz"; then \
        curl -sSfL --retry 3 --retry-delay 10 -O "https://downloads.apache.org/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz"; \
    fi; \
    tar -xzf "${KAFKA_DIST}.tgz" -C /opt/kafka --strip-components=1; \
    rm -rf /tmp/*

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]