FROM ghcr.io/gravitlauncher/launcher:v5.7.6

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container
	
RUN mkdir /home/container/modules && \
    cp -r /app/modules /home/container/modules && \
    chown -R container:container /home/container/modules

RUN ln -sf /home/container/modules /app/modules

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]