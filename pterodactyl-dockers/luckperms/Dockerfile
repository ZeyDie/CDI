# LuckPerms standalone under Pterodactyl:
# - jar остаётся в /opt/luckperms
# - config/data пишутся в /home/container/data (volume Ptero)
# - /opt/luckperms/data → symlink на /home/container/data

FROM ghcr.io/luckperms/luckperms:v5.4.166

USER root

# Alpine: adduser -D без пароля; пользователь может уже существовать
RUN mkdir -p /home/container/data \
    && (getent passwd container >/dev/null 2>&1 || adduser -D -h /home/container -s /bin/sh container) \
    && chown -R container:container /home/container

# data LP должен жить в volume Ptero
RUN if [ -e /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then \
      rm -rf /opt/luckperms/data; \
    fi \
    && ln -sfn /home/container/data /opt/luckperms/data \
    && chown -h container:container /opt/luckperms/data \
    && chown -R container:container /opt/luckperms 2>/dev/null || true

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
WORKDIR /home/container

CMD ["/bin/sh", "/entrypoint.sh"]
