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

# Используем более новую версию Kafka (3.7.0 - последняя стабильная на момент написания)
ENV KAFKA_VERSION=3.7.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/opt/kafka
ENV PATH="${PATH}:${KAFKA_HOME}/bin"

# Скачиваем Kafka с зеркала (с проверкой успешности загрузки)
RUN set -eux; \
    cd /tmp; \
    KAFKA_DIST="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"; \
    MIRRORS=(
        "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz"
        "https://downloads.apache.org/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz"
        "https://apache.mirrors.nublue.co.uk/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz"
    ); \
    for url in "${MIRRORS[@]}"; do \
        if curl -sSfL --retry 3 --retry-delay 10 -O "$url"; then \
            break; \
        fi; \
    done; \
    [ -f "${KAFKA_DIST}.tgz" ] || { echo "Не удалось скачать Kafka"; exit 1; }; \
    tar -xzf "${KAFKA_DIST}.tgz" -C /opt/kafka --strip-components=1; \
    rm -rf /tmp/*

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]