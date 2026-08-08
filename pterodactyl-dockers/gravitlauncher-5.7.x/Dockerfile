FROM azul/zulu-openjdk-debian:25-latest AS prod

RUN apt-get update && apt-get install -y --no-install-recommends \
  osslsigncode \
  nano \
  vim \
  rsync \
  socat \
  git \
  unzip \
  curl \
  wget \
  && rm -rf /var/lib/apt/lists/* && \
  wget https://download2.gluonhq.com/openjfx/25/openjfx-25_linux-x64_bin-jmods.zip && \
      unzip openjfx-25_linux-x64_bin-jmods.zip && \
      cp javafx-jmods-25/* /usr/lib/jvm/zulu25/jmods && \
      rm -r javafx-jmods-25 && \
      rm -rf openjfx-25_linux-x64_bin-jmods.zip

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
