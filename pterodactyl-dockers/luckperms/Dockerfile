# LuckPerms REST API — образ для Pterodactyl
# Volume Wings: /home/container  →  data LP: /opt/luckperms/data
# REST слушает SERVER_PORT (allocation)

FROM ghcr.io/luckperms/rest-api:latest

USER root

RUN apk add --no-cache bash curl ca-certificates iproute2 su-exec 2>/dev/null \
    || apk add --no-cache bash curl ca-certificates iproute2 \
    || true

# Пользователь Pterodactyl
RUN (getent passwd container >/dev/null 2>&1 || adduser -D -h /home/container -s /bin/sh container) \
    && mkdir -p /home/container \
    && chown -R container:container /home/container

# REST-extension в образе лежит в /opt/luckperms/data/extensions — volume Ptero
# перезапишет data. Сохраняем jar вне volume.
RUN mkdir -p /opt/luckperms/bundled-extensions \
    && if [ -d /opt/luckperms/data/extensions ]; then \
         cp -a /opt/luckperms/data/extensions/. /opt/luckperms/bundled-extensions/ 2>/dev/null || true; \
       fi \
    && ls -la /opt/luckperms/bundled-extensions/ || true
    
# data должна быть writable для uid Ptero (часто 999)
RUN mkdir -p /opt/luckperms/data/extensions /opt/luckperms/data/libs \
 && chmod -R 777 /opt/luckperms/data \
 && cp -a /opt/luckperms/bundled-extensions/. /opt/luckperms/data/extensions/ 2>/dev/null || true
 
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV USER=container \
    HOME=/home/container

WORKDIR /home/container

USER app

# Wings ожидает entrypoint; STARTUP приходит из egg
CMD ["/bin/bash", "/entrypoint.sh"]
