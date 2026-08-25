# ============================================
# Stage 1: Build LuckPerms standalone + rest-api
# ============================================
FROM eclipse-temurin:21-jdk-jammy AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# --- LuckPerms (standalone) ---
RUN git clone --depth 1 https://github.com/LuckPerms/LuckPerms.git
WORKDIR /build/LuckPerms
RUN ./gradlew :standalone:shadowJar --no-daemon

# Находим готовый standalone jar
RUN find . -name "luckperms-standalone*.jar" -not -name "*-sources.jar" -not -name "*-javadoc.jar" | head -1 | xargs -I{} cp {} /build/luckperms-standalone.jar

# --- rest-api ---
WORKDIR /build
RUN git clone --depth 1 https://github.com/LuckPerms/rest-api.git
WORKDIR /build/rest-api
RUN ./gradlew shadowJar --no-daemon
RUN cp build/libs/luckperms-rest-api-v1.jar /build/luckperms-rest-api-v1.jar

# ============================================
# Stage 2: Runtime (Pterodactyl-friendly)
# ============================================
FROM eclipse-temurin:21-jre-alpine

LABEL author="custom" \
      description="LuckPerms Standalone + REST API (built from source, Pterodactyl ready)"

RUN apk add --no-cache curl ca-certificates tini

# Пользователь как в Pterodactyl
RUN adduser -D -h /home/container container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Копируем собранные артефакты
COPY --from=builder --chown=container:container /build/luckperms-standalone.jar /home/container/luckperms-standalone.jar
COPY --from=builder --chown=container:container /build/luckperms-rest-api-v1.jar /home/container/luckperms-rest-api-v1.jar

# Структура данных (extensions будут здесь)
RUN mkdir -p /home/container/data/extensions \
    && ln -sf /home/container/luckperms-rest-api-v1.jar /home/container/data/extensions/luckperms-rest-api-v1.jar

# Preload зависимостей (чтобы первый запуск был быстрее)
RUN java -jar /home/container/luckperms-standalone.jar preloadDependencies || true

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/sh", "/entrypoint.sh"]
