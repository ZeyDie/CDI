FROM ghcr.io/luckperms/luckperms:v5.4.166

USER root
RUN ln -s /home/container/data /opt/luckperms/data

CMD java -version

RUN mkdir -p /home/container && \
    adduser -D container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/sh", "/entrypoint.sh"]
