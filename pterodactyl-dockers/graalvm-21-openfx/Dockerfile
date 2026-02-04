FROM ghcr.io/graalvm/graalvm-community:21.0.2-ol9

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container
	
RUN microdnf install -y unzip zip curl git
RUN curl -s "https://get.sdkman.io" | bash
RUN bash -c "source /root/.sdkman/bin/sdkman-init.sh && sdk install javafx 21.0.2"

USER container
WORKDIR /home/container

USER container
RUN curl -s "https://get.sdkman.io" | bash
RUN echo "source /home/container/.sdkman/bin/sdkman-init.sh" >> /home/container/.bashrc

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]