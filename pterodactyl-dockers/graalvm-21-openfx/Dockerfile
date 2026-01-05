FROM ghcr.io/graalvm/graalvm-community:21.0.2-ol9

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container
	
RUN curl -s "https://get.sdkman.io" | bash && \
    source "$HOME/.sdkman/bin/sdkman-init.sh" && \
    sdk install javafx 21.0.2

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]