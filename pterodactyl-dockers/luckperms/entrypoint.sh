#!/bin/sh

set -eu

cd /home/container

echo "============================================"
echo " LuckPerms Pterodactyl"
echo "============================================"

# Pterodactyl уже смонтировал /home/container.
# Теперь переносим JAR'ы из image layer в серверные файлы.

cp -f \
    /build-output/luckperms-standalone.jar \
    /home/container/luckperms-standalone.jar

cp -f \
    /build-output/luckperms-rest-api-v1.jar \
    /home/container/luckperms-rest-api-v1.jar

# REST API extension
mkdir -p /home/container/data/extensions

cp -f \
    /build-output/luckperms-rest-api-v1.jar \
    /home/container/data/extensions/luckperms-rest-api-v1.jar

echo "LuckPerms JARs installed."

# {{VARIABLE}} -> ${VARIABLE}
MODIFIED_STARTUP="$(printf '%s' "${STARTUP}" \
    | sed 's/{{/${/g; s/}}/}/g')"

echo "Starting: ${MODIFIED_STARTUP}"

exec sh -c "${MODIFIED_STARTUP}"
