#!/bin/sh
set -e

CYAN='\033[0;36m'
RESET_COLOR='\033[0m'

mkdir -p /home/container/data

# Базовый образ / Docker VOLUME часто оставляют /opt/luckperms/data
# каталогом от root → AccessDenied. Чиним от root, если возможно.
# Аналогично обрабатываем остальные runtime-пути в /opt/luckperms
# (luckperms.sock от --docker и всё, что может появиться рядом).
fix_opt_luckperms_paths() {
  # --- data ---
  if [ -L /opt/luckperms/data ]; then
    target=$(readlink /opt/luckperms/data 2>/dev/null || true)
    if [ "$target" = "/home/container/data" ]; then
      echo -e "${CYAN}data: symlink OK -> /home/container/data${RESET_COLOR}"
    else
      rm -rf /opt/luckperms/data 2>/dev/null || true
      if ln -sfn /home/container/data /opt/luckperms/data 2>/dev/null; then
        echo -e "${CYAN}Linked /opt/luckperms/data -> /home/container/data${RESET_COLOR}"
      else
        mkdir -p /opt/luckperms/data 2>/dev/null || true
        echo -e "${CYAN}WARNING: no symlink for data (Docker VOLUME / RO?). Will chown if possible${RESET_COLOR}"
      fi
    fi
  else
    if [ -e /opt/luckperms/data ]; then
      rm -rf /opt/luckperms/data 2>/dev/null || true
    fi
    if ln -sfn /home/container/data /opt/luckperms/data 2>/dev/null; then
      echo -e "${CYAN}Linked /opt/luckperms/data -> /home/container/data${RESET_COLOR}"
    else
      mkdir -p /opt/luckperms/data 2>/dev/null || true
      echo -e "${CYAN}WARNING: no symlink for data (Docker VOLUME / RO?). Will chown if possible${RESET_COLOR}"
    fi
  fi

  # --- config.yml (лежит в data, но явно страхуем + удобный симлинк в корень volume) ---
  mkdir -p /home/container/data
  # Если config.yml уже есть как обычный файл не через data-symlink — переносим
  if [ -f /opt/luckperms/data/config.yml ] && [ ! -L /opt/luckperms/data/config.yml ]; then
    if [ ! -e /home/container/data/config.yml ]; then
      cp -a /opt/luckperms/data/config.yml /home/container/data/config.yml 2>/dev/null || true
    fi
    # data уже должен быть симлинком; если нет — файл всё равно окажется в volume после фикса data
  fi
  # Удобный доступ из корня /home/container (файловый менеджер Ptero)
  if [ -e /home/container/data/config.yml ] || [ -L /home/container/data/config.yml ]; then
    ln -sfn /home/container/data/config.yml /home/container/config.yml 2>/dev/null \
      && echo -e "${CYAN}Linked /home/container/config.yml -> /home/container/data/config.yml${RESET_COLOR}" \
      || true
  else
    # файла ещё нет — подготовим симлинк заранее (создастся при первом запуске LP)
    ln -sfn /home/container/data/config.yml /home/container/config.yml 2>/dev/null \
      && echo -e "${CYAN}Prepared /home/container/config.yml -> /home/container/data/config.yml${RESET_COLOR}" \
      || true
  fi
  # Явный путь /opt/luckperms/data/config.yml уже резолвится через symlink data -> /home/container/data
  if [ -L /opt/luckperms/data ] && [ "$(readlink /opt/luckperms/data 2>/dev/null)" = "/home/container/data" ]; then
    echo -e "${CYAN}config.yml: /opt/luckperms/data/config.yml -> /home/container/data/config.yml (via data symlink)${RESET_COLOR}"
  fi

  # --- luckperms.sock (DockerCommandSocket, путь захардкожен в --docker) ---
  # Сокет создаётся Java-процессом. Чтобы bind() не падал на RO rootfs,
  # уводим путь в writable volume через симлинк.
  # Java делает Files.deleteIfExists() перед bind — поэтому симлинк
  # должен быть в директории, куда процесс может писать.
  # Если /opt/luckperms RO — симлинк создать не получится, тогда
  # ошибка останется (в Ptero она некритична: консоль идёт через панель).
  if [ -e /opt/luckperms/luckperms.sock ] || [ -L /opt/luckperms/luckperms.sock ]; then
    rm -f /opt/luckperms/luckperms.sock 2>/dev/null || true
  fi
  # Реальный файл сокета будет лежать в volume
  touch /home/container/luckperms.sock 2>/dev/null || true
  rm -f /home/container/luckperms.sock 2>/dev/null || true
  if ln -sfn /home/container/luckperms.sock /opt/luckperms/luckperms.sock 2>/dev/null; then
    echo -e "${CYAN}Linked /opt/luckperms/luckperms.sock -> /home/container/luckperms.sock${RESET_COLOR}"
  else
    echo -e "${CYAN}WARNING: cannot symlink luckperms.sock (RO /opt/luckperms?). Docker send will fail.${RESET_COLOR}"
  fi

  # --- любые другие файлы/каталоги, которые могут появиться в /opt/luckperms ---
  # (preload leftovers, временные файлы, будущие артефакты).
  # Делаем best-effort: если в /opt/luckperms уже есть обычные файлы
  # кроме jar и data — дублируем их в volume и заменяем симлинками.
  if [ -d /opt/luckperms ]; then
    for item in /opt/luckperms/*; do
      [ -e "$item" ] || continue
      name=$(basename "$item")
      case "$name" in
        data|luckperms-standalone.jar|luckperms.sock)
          continue
          ;;
      esac
      # уже симлинк на volume — ок
      if [ -L "$item" ]; then
        target=$(readlink "$item" 2>/dev/null || true)
        case "$target" in
          /home/container/*) continue ;;
        esac
      fi
      # обычный файл/каталог — переносим в volume и ставим симлинк
      if [ -e "/home/container/$name" ]; then
        rm -rf "$item" 2>/dev/null || true
        ln -sfn "/home/container/$name" "$item" 2>/dev/null \
          && echo -e "${CYAN}Linked /opt/luckperms/$name -> /home/container/$name${RESET_COLOR}" \
          || true
      else
        if [ -d "$item" ] && [ ! -L "$item" ]; then
          mkdir -p "/home/container/$name" 2>/dev/null || true
          # копируем содержимое если есть
          cp -a "$item"/. "/home/container/$name/" 2>/dev/null || true
          rm -rf "$item" 2>/dev/null || true
          ln -sfn "/home/container/$name" "$item" 2>/dev/null \
            && echo -e "${CYAN}Linked /opt/luckperms/$name -> /home/container/$name${RESET_COLOR}" \
            || true
        elif [ -f "$item" ] && [ ! -L "$item" ]; then
          cp -a "$item" "/home/container/$name" 2>/dev/null || true
          rm -f "$item" 2>/dev/null || true
          ln -sfn "/home/container/$name" "$item" 2>/dev/null \
            && echo -e "${CYAN}Linked /opt/luckperms/$name -> /home/container/$name${RESET_COLOR}" \
            || true
        fi
      fi
    done
  fi
}

if [ "$(id -u)" = "0" ]; then
  fix_opt_luckperms_paths || true
  chown -R "$(id -u)":"$(id -g)" /home/container 2>/dev/null || chown -R 999:987 /home/container 2>/dev/null || true
  if [ -d /opt/luckperms/data ] && [ ! -L /opt/luckperms/data ]; then
    chown -R 999:987 /opt/luckperms/data 2>/dev/null || true
  fi
  chmod -R a+rwX /home/container/data 2>/dev/null || true
  chmod -R a+rwX /opt/luckperms/data 2>/dev/null || true
  # Пробуем сделать /opt/luckperms writable для создания сокета
  chown -R 999:987 /opt/luckperms 2>/dev/null || true
  chmod u+rwX /opt/luckperms 2>/dev/null || true
else
  echo -e "${CYAN}uid=$(id -u) (not root) — chown skipped. Ptero user must own the volume.${RESET_COLOR}"
  fix_opt_luckperms_paths 2>/dev/null || true
  mkdir -p /home/container/data
  # Best-effort self-heal: если каталог принадлежит нам — подчистим права.
  chmod -R u+rwX,g+rwX /home/container/data 2>/dev/null || true
  chmod -R u+rwX,g+rwX /opt/luckperms/data 2>/dev/null || true
  chmod u+rwX /opt/luckperms 2>/dev/null || true
fi

if ! touch /opt/luckperms/data/.write-test 2>/dev/null; then
  echo -e "${CYAN}ERROR: cannot write /opt/luckperms/data${RESET_COLOR}"
  ls -la /opt/luckperms /opt/luckperms/data /home/container 2>/dev/null || true
  id || true
  echo -e "${CYAN}HINT: /home/container/data must be owned by uid:gid $(id -u):$(id -g) (or be group/other-writable).${RESET_COLOR}"
  echo -e "${CYAN}If you rebuilt the image after this fix and it's still broken, the Pterodactyl volume${RESET_COLOR}"
  echo -e "${CYAN}already has stale ownership from before — delete/recreate the server's data volume once.${RESET_COLOR}"
else
  rm -f /opt/luckperms/data/.write-test
  echo -e "${CYAN}Write test OK: /opt/luckperms/data${RESET_COLOR}"
fi

cd /home/container || exit 1

# STARTUP обычно содержит относительный путь к jar-файлу
# (java -jar luckperms-standalone.jar ...), а сам jar лежит в /opt/luckperms.
# Кладём симлинк в /home/container, чтобы относительный путь резолвился,
# не трогая при этом cwd (он должен остаться /home/container, чтобы логи/
# конфиги, которые LuckPerms может писать рядом с jar, попадали в volume).
if [ -f /opt/luckperms/luckperms-standalone.jar ]; then
  ln -sfn /opt/luckperms/luckperms-standalone.jar /home/container/luckperms-standalone.jar 2>/dev/null \
    && echo -e "${CYAN}Linked luckperms-standalone.jar -> /opt/luckperms/luckperms-standalone.jar${RESET_COLOR}" \
    || echo -e "${CYAN}WARNING: could not symlink jar into /home/container${RESET_COLOR}"
fi

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}') || true
export INTERNAL_IP

# shellcheck disable=SC2086
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e "${CYAN}STARTUP /home/container: ${MODIFIED_STARTUP} ${RESET_COLOR}"

if [ "$(id -u)" = "0" ] && command -v su >/dev/null 2>&1; then
  export MODIFIED_STARTUP INTERNAL_IP
  # Пользователя "container" может не существовать (мы больше не создаём его
  # жёстко в Dockerfile) — определяем имя для целевого uid динамически,
  # с фолбэком на 999, а если и его нет в /etc/passwd — просто не дропаем
  # привилегии (лучше запуститься от root, чем не запуститься совсем).
  TARGET_USER=$(getent passwd 999 2>/dev/null | cut -d: -f1 || true)
  if [ -n "$TARGET_USER" ]; then
    exec su "$TARGET_USER" -s /bin/sh -c 'cd /home/container && eval "$MODIFIED_STARTUP"'
  else
    echo -e "${CYAN}WARNING: no passwd entry for uid 999 — running as root.${RESET_COLOR}"
  fi
fi

# shellcheck disable=SC2086
eval ${MODIFIED_STARTUP}
