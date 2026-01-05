FROM ghcr.io/gravitlauncher/launcher:v5.7.6

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container
	
RUN cp -r /app /home/container/ && \
    chown -R container:container /home/container/app

RUN if [ -d /app/modules ]; then \
        mkdir -p /home/container/modules && \
        cp -r /app/modules/* /home/container/modules/ 2>/dev/null || true && \
        rm -rf /home/container/app/modules && \
        ln -sf /home/container/modules /home/container/app/modules; \
    else \
        ln -sf /home/container/modules /home/container/app/modules; \
    fi

RUN ln -sf /home/container/app /app

ENV APP_HOME=/home/container/app

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]