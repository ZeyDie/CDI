FROM zabbix/zabbix-server-mysql:alpine-7.4-latest

USER root

RUN mkdir -p /home/container && \
    chown -R zabbix:zabbix /home/container

USER zabbix
WORKDIR /home/container

COPY --chown=zabbix:zabbix entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]