FROM zabbix/zabbix-web-nginx-mysql:alpine-7.4-latest

USER root

RUN mkdir -p /home/container && \
    adduser -D container && \
    chown -R container:container /home/container

RUN chown -R container:container /etc/nginx && \
    chown -R container:container /etc/zabbix

USER container
WORKDIR /home/container

VOLUME /etc/zabbix /home/container/zabbix
VOLUME /etc/nginx /home/container/nginx

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]