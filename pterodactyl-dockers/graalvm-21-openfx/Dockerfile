# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM ubuntu:24.04

ARG TARGETPLATFORM
ARG GRAAL_VERSION=21.0.12
ARG JAVA_VERSION=21
ARG JAVAFX_VERSION=21.0.12

MAINTAINER RikoDEV, <kontakt@riko.dev>

ENV DEBIAN_FRONTEND=noninteractive

# Default to UTF-8 file.encoding
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends curl ca-certificates openssl git tar sqlite3 fontconfig tzdata locales iproute2 openjfx unzip \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.UTF-8 \
  && case ${TARGETPLATFORM} in \
         "linux/amd64")  ARCH=x64  ;; \
         "linux/arm64")  ARCH=aarch64  ;; \
    esac \
  && curl --retry 3 -Lfso /tmp/graalvm.tar.gz https://download.oracle.com/graalvm/${JAVA_VERSION}/archive/graalvm-jdk-${GRAAL_VERSION}_linux-${ARCH}_bin.tar.gz \
  && mkdir -p /opt/java/graalvm \
  && cd /opt/java/graalvm \
  && tar -xf /tmp/graalvm.tar.gz --strip-components=1 \
  && export PATH="/opt/java/graalvm/bin:$PATH" \
  # --- JavaFX jmods ---
  && curl --retry 3 -Lfso /tmp/javafx-jmods.zip \
       https://download2.gluonhq.com/openjfx/${JAVAFX_VERSION}/openjfx-${JAVAFX_VERSION}_linux-${ARCH}_bin-jmods.zip \
  && mkdir -p /tmp/javafx-jmods \
  && unzip -q /tmp/javafx-jmods.zip -d /tmp/javafx-jmods \
  && cp -r /tmp/javafx-jmods/javafx-jmods-${JAVAFX_VERSION}/*.jmod /opt/java/graalvm/jmods/ \
  # --- cleanup ---
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/graalvm.tar.gz /tmp/javafx-jmods /tmp/javafx-jmods.zip

ENV JAVA_HOME=/opt/java/graalvm \
    PATH="/opt/java/graalvm/bin:$PATH"

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
