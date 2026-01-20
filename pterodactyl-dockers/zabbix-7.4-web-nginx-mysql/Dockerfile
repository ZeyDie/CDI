FROM zabbix/zabbix-web-nginx-mysql:alpine-7.4-latest

USER root

RUN chmod a+wx /etc/nginx
RUN chmod a+wx /etc/zabbix

RUN mkdir -p /home/container && \
    adduser -D container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]