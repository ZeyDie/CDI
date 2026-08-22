#!/bin/bash
set -e

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${CYAN}[lp-ptero]${NC} $*"; }
warn() { echo -e "${YELLOW}[lp-ptero]${NC} $*"; }
err()  { echo -e "${RED}[lp-ptero]${NC} $*"; }

# Pterodactyl: рабочий volume = /home/container
# LuckPerms standalone: data = /opt/luckperms/data
mkdir -p /home/container

# --- связать data LP с volume сервера ---
link_data() {
  # если data уже symlink на /home/container — ок
  if [ -L /opt/luckperms/data ]; then
    local t
    t=$(readlink /opt/luckperms/data 2>/dev/null || true)
    if [ "$t" = "/home/container" ] || [ "$t" = "/home/container/" ]; then
      log "data: symlink OK → /home/container"
      return 0
    fi
    rm -f /opt/luckperms/data 2>/dev/null || true
  fi

  # каталог из VOLUME образа — убрать и заменить symlink
  if [ -d /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then
    # сохранить libs из preload если есть (редко нужны после первого старта)
    rm -rf /opt/luckperms/data 2>/dev/null || true
  fi

  if ln -sfn /home/container /opt/luckperms/data 2>/dev/null; then
    log "Linked /opt/luckperms/data → /home/container"
    return 0
  fi

  warn "Не удалось сделать symlink (часто Docker VOLUME). Пишем прямо в /opt/luckperms/data"
  mkdir -p /opt/luckperms/data
  return 1
}

# --- права ---
fix_perms() {
  if [ "$(id -u)" = "0" ]; then
    link_data || true
    chown -R container:container /home/container 2>/dev/null || true
    if [ -d /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then
      chown -R container:container /opt/luckperms/data 2>/dev/null || true
    fi
    # jar и sock
    chown -R container:container /opt/luckperms 2>/dev/null || true
    chmod -R a+rwX /home/container 2>/dev/null || true
  else
    warn "uid=$(id -u) — chown пропущен (Wings без root). Владелец volume должен совпадать."
    link_data 2>/dev/null || true
    mkdir -p /home/container
  fi
}

fix_perms

# --- REST extension (из bundled, т.к. volume пустой) ---
mkdir -p /home/container/extensions
if [ -d /opt/luckperms/bundled-extensions ] && [ "$(ls -A /opt/luckperms/bundled-extensions 2>/dev/null)" ]; then
  # не перезаписывать пользовательские jar
  for f in /opt/luckperms/bundled-extensions/*; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    if [ ! -e "/home/container/extensions/$base" ]; then
      cp -a "$f" "/home/container/extensions/$base" 2>/dev/null || true
      log "Installed extension: $base"
    fi
  done
fi

# также если symlink не сработал — extensions в data
if [ -d /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then
  mkdir -p /opt/luckperms/data/extensions
  if [ -d /opt/luckperms/bundled-extensions ]; then
    cp -an /opt/luckperms/bundled-extensions/. /opt/luckperms/data/extensions/ 2>/dev/null || true
  fi
fi

# --- порт REST = primary allocation Ptero ---
if [ -n "${SERVER_PORT}" ]; then
  export LUCKPERMS_REST_HTTP_PORT="${SERVER_PORT}"
  log "LUCKPERMS_REST_HTTP_PORT=${LUCKPERMS_REST_HTTP_PORT} (SERVER_PORT)"
fi

# --- проверка записи ---
if ! touch /opt/luckperms/data/.write-test 2>/dev/null; then
  err "Нет записи в /opt/luckperms/data"
  ls -la /opt/luckperms /opt/luckperms/data /home/container 2>/dev/null || true
  id || true
  # не exit — пусть LP покажет свою ошибку
else
  rm -f /opt/luckperms/data/.write-test
  log "Write test OK"
fi

cd /home/container || exit 1

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2); exit}') || true
export INTERNAL_IP

# Подстановка {{VAR}} из egg → ${VAR}
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
# shellcheck disable=SC2086
MODIFIED_STARTUP=$(eval echo ${MODIFIED_STARTUP})
log "STARTUP: ${MODIFIED_STARTUP}"

run_as_container() {
  if [ "$(id -u)" = "0" ]; then
    if command -v su-exec >/dev/null 2>&1; then
      exec su-exec container /bin/bash -c "cd /home/container && exec ${MODIFIED_STARTUP}"
    fi
    if command -v su >/dev/null 2>&1; then
      exec su container -s /bin/bash -c "cd /home/container && exec ${MODIFIED_STARTUP}"
    fi
  fi
  # уже не root или нет su
  # shellcheck disable=SC2086
  exec ${MODIFIED_STARTUP}
}

run_as_container
