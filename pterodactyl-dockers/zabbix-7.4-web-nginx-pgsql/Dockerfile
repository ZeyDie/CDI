FROM zabbix/zabbix-web-nginx-pgsql:alpine-7.4-latest

USER zabbix
WORKDIR /home/zabbix

COPY --chown=zabbix:zabbix entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]