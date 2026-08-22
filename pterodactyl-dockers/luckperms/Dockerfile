FROM ghcr.io/luckperms/rest-api:latest

USER root

RUN mkdir -p /home/container && \
    chown -R app:app /home/container

USER app
WORKDIR /home/container

COPY --chown=app:app entrypoint.sh /entrypoint.sh

CMD ["/bin/sh", "/entrypoint.sh"]
