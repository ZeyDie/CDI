#!/bin/sh
set -e

CYAN='\033[0;36m'
RESET_COLOR='\033[0m'

mkdir -p /home/container/data

# Базовый образ / Docker VOLUME часто оставляют /opt/luckperms/data
# каталогом от root → AccessDenied. Чиним от root, если возможно.
fix_data_dir() {
  if [ -L /opt/luckperms/data ]; then
    target=$(readlink /opt/luckperms/data 2>/dev/null || true)
    if [ "$target" = "/home/container/data" ]; then
      echo -e "${CYAN}data: symlink OK -> /home/container/data${RESET_COLOR}"
      return 0
    fi
  fi

  if [ -e /opt/luckperms/data ] || [ -L /opt/luckperms/data ]; then
    rm -rf /opt/luckperms/data 2>/dev/null || true
  fi

  if ln -sfn /home/container/data /opt/luckperms/data 2>/dev/null; then
    echo -e "${CYAN}Linked /opt/luckperms/data -> /home/container/data${RESET_COLOR}"
    return 0
  fi

  mkdir -p /opt/luckperms/data 2>/dev/null || true
  echo -e "${CYAN}WARNING: no symlink (Docker VOLUME?). Will chown /opt/luckperms/data${RESET_COLOR}"
  return 1
}

if [ "$(id -u)" = "0" ]; then
  fix_data_dir || true
  chown -R container:container /home/container 2>/dev/null || true
  if [ -d /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then
    chown -R container:container /opt/luckperms/data 2>/dev/null || true
  fi
  chmod -R a+rwX /home/container/data 2>/dev/null || true
  chmod -R a+rwX /opt/luckperms/data 2>/dev/null || true
  chown -R container:container /opt/luckperms 2>/dev/null || true
else
  echo -e "${CYAN}uid=$(id -u) (not root) — chown skipped. Ptero user must own the volume.${RESET_COLOR}"
  fix_data_dir 2>/dev/null || true
  mkdir -p /home/container/data
fi

if ! touch /opt/luckperms/data/.write-test 2>/dev/null; then
  echo -e "${CYAN}ERROR: cannot write /opt/luckperms/data${RESET_COLOR}"
  ls -la /opt/luckperms /opt/luckperms/data /home/container 2>/dev/null || true
  id || true
else
  rm -f /opt/luckperms/data/.write-test
  echo -e "${CYAN}Write test OK: /opt/luckperms/data${RESET_COLOR}"
fi

cd /home/container || exit 1

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}') || true
export INTERNAL_IP

# shellcheck disable=SC2086
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e "${CYAN}STARTUP /home/container: ${MODIFIED_STARTUP} ${RESET_COLOR}"

if [ "$(id -u)" = "0" ] && command -v su >/dev/null 2>&1; then
  export MODIFIED_STARTUP INTERNAL_IP
  exec su container -s /bin/sh -c 'cd /home/container && eval "$MODIFIED_STARTUP"'
fi

# shellcheck disable=SC2086
eval ${MODIFIED_STARTUP}
