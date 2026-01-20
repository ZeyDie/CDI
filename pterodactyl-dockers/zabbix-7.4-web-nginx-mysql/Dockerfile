FROM zabbix/zabbix-web-nginx-mysql:alpine-7.4-latest

USER root

RUN mkdir -p /home/container && \
    adduser -D container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]