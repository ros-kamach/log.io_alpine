FROM alpine:3.7

ENV VERSION=v6.9.5
ENV YARN_VERSION=v1.19.1

RUN \
    #Install needed packages
    apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
    #Install nodejs
    curl https://raw.githubusercontent.com/ros-kamach/log.io_openshift/master/build/nodejs/node-${VERSION}.tar.xz \
    --output node-${VERSION}.tar.xz && \
    tar -xf node-${VERSION}.tar.xz && \
    cd /node-${VERSION} && \
    ./configure --prefix=/usr && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    #Install yarn 
    cd / && \
    curl https://raw.githubusercontent.com/ros-kamach/log.io_openshift/master/build/nodejs/yarn-${YARN_VERSION}.tar.gz \
    --output yarn-${YARN_VERSION}.tar.gz && \
    mkdir /usr/local/share/yarn && \
    tar -xf yarn-${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
    ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
    ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
    #Clean up image from unkneeded packages and files
    rm yarn-${YARN_VERSION}.tar.gz && \
    rm node-${VERSION}.tar.xz && \
    rm -rf /node-${VERSION}* /tmp/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc /root/.npm /root/.node-gyp /root/.config \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
    { rm -rf /root/.gnupg || true; }
