# LuckPerms standalone for Pterodactyl
# - jar: /opt/luckperms
# - writable data: /home/container/data (volume Ptero)
# - entrypoint runs as root → fixes perms/symlink → drops to container
#
# ВАЖНО: Pterodactyl (wings) фактически запускает контейнер под фиксированным
# UID:GID = 999:987. Раньше мы создавали НОВОГО пользователя "container" через
# `adduser -D` без -u/-g, и он получал произвольный (следующий свободный) UID —
# не совпадающий с 999:987. При первом старте Docker копирует содержимое
# /home/container/data из слоя образа в новый volume, сохраняя владельца из
# образа — то есть НЕПРАВИЛЬНЫЙ uid. Отсюда AccessDenied на записи.
#
# Фикс: не создаём отдельного пользователя — прибиваем владельца сразу
# числовыми 999:987, которые точно совпадают с рантайм-UID/GID Pterodactyl.

FROM ghcr.io/luckperms/luckperms:v5.4.166

USER root

RUN mkdir -p /home/container/data \
    && chown -R 999:987 /home/container

# Попытка symlink на этапе сборки (может сброситься VOLUME базового образа при старте)
RUN if [ -e /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then \
      rm -rf /opt/luckperms/data; \
    fi \
    && ln -sfn /home/container/data /opt/luckperms/data \
    && chown -h 999:987 /opt/luckperms/data || true \
    && chown -R 999:987 /opt/luckperms || true

# context = корень репо; Action подставляет нужный entrypoint.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Важно: НЕ USER container — entrypoint должен стартовать от root (если это
# возможно в конкретном окружении) — иначе не сможет починить
# /opt/luckperms/data и права после mount Ptero. На самом Pterodactyl
# контейнер всё равно принудительно стартует под 999:987 (см. entrypoint.sh),
# поэтому это ветка "на всякий случай" для локального docker run --user root.
WORKDIR /home/container

CMD ["/bin/sh", "/entrypoint.sh"]
