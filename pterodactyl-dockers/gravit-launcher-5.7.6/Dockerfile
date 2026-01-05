FROM ghcr.io/gravitlauncher/launcher:v5.7.6

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container
	
RUN cp -r /app /home/container/ && \
    chown -R container:container /home/container/app

RUN ln -sf /home/container/app /app

ENV APP_HOME=/home/container/app

USER container
WORKDIR /home/container/app

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]