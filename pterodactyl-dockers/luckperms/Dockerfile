# LuckPerms standalone for Pterodactyl
# - jar: /opt/luckperms
# - writable data: /home/container/data (volume Ptero)
# - entrypoint runs as root → fixes perms/symlink → drops to container

FROM ghcr.io/luckperms/luckperms:v5.4.166

USER root

RUN mkdir -p /home/container/data \
    && (getent passwd container >/dev/null 2>&1 || adduser -D -h /home/container -s /bin/sh container) \
    && chown -R container:container /home/container

# Попытка symlink на этапе сборки (может сброситься VOLUME базового образа при старте)
RUN if [ -e /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then \
      rm -rf /opt/luckperms/data; \
    fi \
    && ln -sfn /home/container/data /opt/luckperms/data \
    && chown -h container:container /opt/luckperms/data || true

# context = корень репо; Action подставляет нужный entrypoint.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Важно: НЕ USER container — entrypoint должен стартовать от root,
# иначе не сможет починить /opt/luckperms/data и права после mount Ptero
WORKDIR /home/container

CMD ["/bin/sh", "/entrypoint.sh"]
