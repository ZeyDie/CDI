FROM ghcr.io/luckperms/luckperms:v5.4.166

CMD java -version

RUN mkdir -p /home/container && \
    adduser container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
