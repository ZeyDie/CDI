FROM debian:trixie-slim

RUN echo "Upgrade packages" && \
    apt-get upgrade && apt-get update

RUN echo "Install wget curl systemctl" && \
    apt-get install -y wget curl systemctl

RUN echo "Install Kaspersky Security Center" && \
    curl -L --retry 3 --retry-delay 5 --connect-timeout 30 \
         --max-time 300 --progress-bar \
         -O "https://products.s.kaspersky-labs.com/administrationkit/ksc10/16.0.0.254/russian-INT-26376848-ru/979b69a60d4f4abfbe34a28a427f1740/ksc64_16.0.0-254_amd64.deb" && \
    dpkg -i "ksc64_16.0.0-254_amd64.deb" && \
    rm -rf "ksc64_16.0.0-254_amd64.deb"

RUN echo "Install Kaspersky Security Center Web Console" && \
    curl -L --retry 3 --retry-delay 5 --connect-timeout 30 \
         --max-time 300 --progress-bar \
         -O "https://products.s.kaspersky-labs.com/administrationkit/ksc10/16.0.0.254/russian-INT-26376848-ru/ec9f4b7ec68547ec8c2dd0eed20f9a07/ksc-web-console-16.0.378.x86_64.deb" && \
    dpkg -i "ksc-web-console-16.0.378.x86_64.deb" && \
    rm -rf "ksc-web-console-16.0.378.x86_64.deb"

RUN apt-get install -y yes && \
    yes Y | /opt/kaspersky/ksc64/lib/bin/setup/postinstall.pl

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]