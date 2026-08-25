FROM ghcr.io/luckperms/luckperms AS ext

FROM eclipse-temurin:21-alpine
RUN apk add --no-cache netcat-openbsd
RUN printf '#!/bin/sh\necho "$@" | nc -NU /opt/luckperms/luckperms.sock\n' > /usr/bin/send \
    && chmod 777 /usr/bin/send

WORKDIR /opt/luckperms
COPY luckperms-standalone.jar .
COPY --from=ext /opt/luckperms/data/extensions ./data/extensions
COPY luckperms-rest-api-v1.jar ./data/extensions/

RUN mkdir -p data \
    && java -jar luckperms-standalone.jar preloadDependencies \
    && chmod -R 777 /opt/luckperms

CMD ["java", "-jar", "luckperms-standalone.jar", "--docker"]
HEALTHCHECK --interval=30s --timeout=15s --start-period=20s \
    CMD wget http://localhost:3001/health -q -O - | grep -c '"up":true' || exit 1
