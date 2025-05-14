# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java with Apache Kafka 4.0.0
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM openjdk:21-slim

LABEL maintainer="ZeyDie <zeydie.dev@gmail.com>"

# Устанавливаем необходимые пакеты (включая wget)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Создаем пользователя container
RUN useradd -m -d /home/container container

ENV KAFKA_VERSION=4.0.0
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# Устанавливаем Kafka (теперь с проверкой скачивания)
RUN mkdir -p /opt/kafka \
    && wget --tries=3 --waitretry=30 --progress=dot:giga --retry-connrefused \
       https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.12-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz \
    && tar xfz /tmp/kafka.tgz -C /opt/kafka --strip-components=1 \
    && rm -f /tmp/kafka.tgz \
    && chown -R container:container /opt/kafka

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]