FROM ghcr.io/graalvm/graalvm-community:21.0.2-ol9

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]