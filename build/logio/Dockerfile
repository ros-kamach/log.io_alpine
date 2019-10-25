FROM roskamach/nodejs_alpine:v6.9.5

RUN \
    npm install coffeescript && \
    npm install contextify && \
    npm install build.js && \
    adduser -s /bin/false -g "" -D logio && \
    export USER=logio && export HOME=/home/logio && \
    npm install -g log.io --user "logio" && \
    apk del make gcc g++ python linux-headers binutils-gold gnupg curl

EXPOSE 28778
USER logio
ENV HOME /home/logio
ENV USER logio
WORKDIR /home/logio

COPY ./script.sh /

ENTRYPOINT ["./script.sh"]
