#!/bin/sh

if [ ! -f /home/container/luckperms-standalone.jar ]; then
    cp /opt/build/luckperms-standalone.jar /home/container/
fi

if [ ! -f /home/container/luckperms-rest-api-v1.jar ]; then
    cp /opt/build/luckperms-rest-api-v1.jar /home/container/
fi

exec java -jar /home/container/luckperms-standalone.jar --docker

# Подстановка переменных Pterodactyl ({{VAR}} → $VAR)
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

echo "Starting: ${MODIFIED_STARTUP}"
exec ${MODIFIED_STARTUP}
