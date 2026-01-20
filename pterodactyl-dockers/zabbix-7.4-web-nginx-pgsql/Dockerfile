FROM zabbix/zabbix-web-nginx-pgsql:alpine-7.4-latest

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container \

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]