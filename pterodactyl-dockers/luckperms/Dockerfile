FROM ghcr.io/luckperms/luckperms:v5.4.166

USER root

RUN mkdir -p /home/container && \
    adduser -D container && \
    ln -sfn /home/container/data /opt/luckperms/data && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/sh", "/entrypoint.sh"]
