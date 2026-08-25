FROM eclipse-temurin:21-jre-alpine

LABEL author="yourname" maintainer="you@example.com"

# Нужные утилиты (по желанию)
RUN apk add --no-cache curl ca-certificates

# Пользователь как в Pterodactyl
RUN adduser --disabled-password --home /home/container container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Копируем jar (при сборке положите его рядом с Dockerfile)
COPY --chown=container:container luckperms-standalone.jar /home/container/luckperms-standalone.jar

# Preload зависимостей (опционально, можно и в entrypoint)
RUN java -jar /home/container/luckperms-standalone.jar preloadDependencies || true

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/ash", "/entrypoint.sh"]
