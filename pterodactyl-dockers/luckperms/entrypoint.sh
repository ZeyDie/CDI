#!/bin/sh
set -e

# Volume Pterodactyl: config.yml, storage и т.д.
mkdir -p /home/container/data

# Ожидается symlink из Dockerfile: /opt/luckperms/data -> /home/container/data
if [ -L /opt/luckperms/data ]; then
  :
elif [ ! -e /opt/luckperms/data ]; then
  ln -sfn /home/container/data /opt/luckperms/data 2>/dev/null || true
else
  echo "[entrypoint] WARNING: /opt/luckperms/data is not a symlink — LP may fail with AccessDenied"
  echo "[entrypoint] Rebuild image so Dockerfile creates: ln -sfn /home/container/data /opt/luckperms/data"
fi

cd /opt/luckperms

# Панель Ptero часто передаёт команду через docker CMD / STARTUP.
# Если STARTUP задан — выполняем его, иначе дефолт standalone.
if [ -n "${STARTUP}" ]; then
  exec /bin/sh -c "cd /opt/luckperms && ${STARTUP}"
fi

exec java -jar luckperms-standalone.jar --docker
