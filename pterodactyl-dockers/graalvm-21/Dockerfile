FROM ghcr.io/graalvm/graalvm-community:21.0.2-ol9

RUN microdnf update -y && \
    microdnf install -y procps-ng && \
    microdnf clean all
	
RUN echo "net.core.somaxconn = 65535" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.core.netdev_max_backlog = 65536" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_max_syn_backlog = 65536" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.core.rmem_max = 16777216" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.core.wmem_max = 16777216" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.d/99-custom.conf && \
	echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> /etc/sysctl.d/99-custom.conf && \
	echo "vm.swappiness = 10" >> /etc/sysctl.d/99-custom.conf && \
	echo "vm.dirty_ratio = 15" >> /etc/sysctl.d/99-custom.conf && \
	echo "vm.dirty_background_ratio = 5" >> /etc/sysctl.d/99-custom.conf
	
RUN echo '#!/bin/sh' > /usr/local/bin/apply-sysctl.sh && \
    echo 'if [ -f /etc/sysctl.d/99-custom.conf ]; then' >> /usr/local/bin/apply-sysctl.sh && \
    echo '    sysctl -p /etc/sysctl.d/99-custom.conf 2>/dev/null || true' >> /usr/local/bin/apply-sysctl.sh && \
    echo 'fi' >> /usr/local/bin/apply-sysctl.sh && \
    echo 'exec "$@"' >> /usr/local/bin/apply-sysctl.sh && \
    chmod +x /usr/local/bin/apply-sysctl.sh

ENTRYPOINT ["/usr/local/bin/apply-sysctl.sh"]

CMD java -version

RUN mkdir -p /home/container && \
    useradd container && \
    chown -R container:container /home/container

USER container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]