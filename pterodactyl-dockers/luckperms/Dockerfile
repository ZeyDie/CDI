FROM ghcr.io/luckperms/luckperms:latest
RUN mkdir -p /opt/luckperms/data && chmod -R 777 /opt/luckperms/data
RUN printf '#!/bin/sh\necho "$@" | nc -NU /home/container/luckperms.sock\n' > /usr/bin/send \
    && chmod 777 /usr/bin/send
