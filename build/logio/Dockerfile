FROM roskamach/nodejs_alpine:v6.9.5

COPY ./script.sh /

RUN \
    adduser -s /bin/false -g "" -D logio && \
    export USER=logio && export HOME=/home/logio && \
    npm install -g log.io --user "logio" && \
    apk add bash && apk del make gcc g++ python linux-headers binutils-gold gnupg && \
    rm -rf /tmp/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc /root/.npm /root/.node-gyp /root/.config \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
    { rm -rf /root/.gnupg || true; } && \
    mv /script.sh /home/logio/ && \
    chown logio:logio /home/logio/script.sh && \
    chmod 777 /home/logio/script.sh && \
    bash /home/logio/script.sh

EXPOSE 28778 28777

USER logio
ENV HOME /home/logio
ENV USER logio
WORKDIR /home/logio

CMD ["bash", "./script.sh"]
