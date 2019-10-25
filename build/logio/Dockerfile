FROM roskamach/alpine_nodejs:v6.9.5

RUN \
    npm install coffeescript && \
    npm install contextify && \
    npm install build.js && \
    adduser -s /bin/false -g "" -D logio && \
    export USER=logio && export HOME=/home/logio && \
    npm install -g log.io --user "logio" && \
    apk del make gcc g++ python linux-headers binutils-gold gnupg curl && \
    rm -rf /tmp/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc /root/.npm /root/.node-gyp /root/.config \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
    { rm -rf /root/.gnupg || true; }

EXPOSE 28778
USER logio
# ENV HOME /home/logio
# ENV USER logio
WORKDIR /home/logio

COPY ./script.sh /
COPY ./startup.sh /

ENTRYPOINT ["/script.sh"]
