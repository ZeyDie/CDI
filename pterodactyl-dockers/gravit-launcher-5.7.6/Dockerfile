FROM ghcr.io/gravitlauncher/launcher:v5.7.6

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container
	
RUN mkdir /home/container/data && \
    cp -r /app/data /home/container/data && \
    chown -R container:container /home/container/data

RUN ln -sf /home/container/data /app/data

ENV APP_HOME=/home/container/data

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]