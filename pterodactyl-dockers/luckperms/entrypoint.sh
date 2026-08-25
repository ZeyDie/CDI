#!/bin/sh
cd /home/container

# Создаём папку extensions, если её нет
mkdir -p data/extensions

# Кладём/обновляем rest-api extension
cp -f /home/container/luckperms-rest-api-v1.jar data/extensions/ 2>/dev/null || true

# Подстановка переменных Pterodactyl ({{VAR}} → $VAR)
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

echo "Starting: ${MODIFIED_STARTUP}"
exec ${MODIFIED_STARTUP}
