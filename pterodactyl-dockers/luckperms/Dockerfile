FROM ghcr.io/luckperms/luckperms AS ext
COPY luckperms-rest-api-v1.jar /opt/luckperms/data/extensions/

FROM eclipse-temurin:21-alpine
RUN apk add --no-cache netcat-openbsd
RUN printf '#!/bin/sh\necho "$@" | nc -NU /home/container/luckperms.sock\n' > /usr/bin/send \
    && chmod 777 /usr/bin/send

WORKDIR /home/container
COPY luckperms-standalone.jar .
COPY --from=ext /opt/luckperms/data/extensions ./data/extensions

RUN mkdir -p data \
    && java -jar luckperms-standalone.jar preloadDependencies \
    && chmod -R 777 /home/container

CMD ["java", "-jar", "luckperms-standalone.jar", "--docker"]
HEALTHCHECK --interval=30s --timeout=15s --start-period=20s \
    CMD wget http://localhost:3001/health -q -O - | grep -c '"up":true' || exit 1
