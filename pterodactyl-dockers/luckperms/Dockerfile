# ============================================
# Stage 1: Build
# ============================================
FROM eclipse-temurin:21-jdk-jammy AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# LuckPerms Standalone
RUN git clone https://github.com/LuckPerms/LuckPerms.git

WORKDIR /build/LuckPerms

RUN ./gradlew :standalone:loader:shadowJar --no-daemon

RUN JAR="$(find standalone/loader/build/libs -name 'LuckPerms-Standalone-*.jar' | head -1)" \
 && test -n "$JAR" \
 && mkdir -p /build/output \
 && cp "$JAR" /build/output/luckperms-standalone.jar

# LuckPerms REST API
WORKDIR /build

RUN git clone https://github.com/LuckPerms/rest-api.git

WORKDIR /build/rest-api

RUN ./gradlew shadowJar --no-daemon

RUN test -f build/libs/luckperms-rest-api-v1.jar \
 && cp build/libs/luckperms-rest-api-v1.jar \
       /build/output/luckperms-rest-api-v1.jar


# ============================================
# Stage 2: Runtime
# ============================================
FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache \
    curl \
    ca-certificates \
    tini

RUN adduser -D -h /home/container container

ENV USER=container
ENV HOME=/home/container

WORKDIR /home/container

# ВАЖНО:
# Не /home/container — Pterodactyl смонтирует
# эту директорию при запуске.
COPY --from=builder /build/output /build-output

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
 && chown -R container:container /build-output /entrypoint.sh

USER container

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/sh", "/entrypoint.sh"]
