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

# Создаем пользователя и основные директории
RUN adduser -D -h /home/container container && \
    mkdir -p /home/container/kafka && \
    mkdir -p /home/container/kafka-logs && \
    chown -R container:container /home/container

# Используем стабильную версию Kafka
ENV KAFKA_VERSION=4.0.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/home/container/kafka
ENV KAFKA_LOG_DIRS="${KAFKA_HOME}/logs"

ENV PATH="${PATH}:${KAFKA_HOME}/bin"

# Скачиваем Kafka и распаковываем в домашнюю директорию
RUN set -eux; \
    cd /tmp; \
    KAFKA_DIST="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"; \
    if ! curl -sSfL --retry 3 --retry-delay 10 -O "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz"; then \
        curl -sSfL --retry 3 --retry-delay 10 -O "https://downloads.apache.org/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz"; \
    fi; \
    tar -xzf "${KAFKA_DIST}.tgz" -C /home/container/kafka --strip-components=1; \
    rm -rf /tmp/*

# Настраиваем Kafka для работы из домашней директории
RUN sed -i 's|log.dirs=/tmp/kafka-logs|log.dirs=${KAFKA_LOG_DIRS}|g' ${KAFKA_HOME}/config/server.properties && \
    chown -R container:container /home/container
	
# Настраиваем Kafka для работы из домашней директории
RUN echo "broker.id=1" > /home/container/kafka/config/server.properties && \
    echo "log.dirs=${KAFKA_LOG_DIRS}" >>  ${KAFKA_HOME}/config/server.properties && \
    echo "listeners=PLAINTEXT://:9092" >>  ${KAFKA_HOME}/config/server.properties && \
    mkdir -p ${KAFKA_LOG_DIRS} && \
    echo "version=0" > ${KAFKA_LOG_DIRS}/meta.properties && \
    echo "broker.id=1" >> ${KAFKA_LOG_DIRS}/meta.properties && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]