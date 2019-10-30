#!/bin/bash
if [[ "${LOGIO_SERVER}" == "yes" ]]
    then
        supervisord --nodaemon --configuration /etc/supervisor/conf.d/supervisor_server.conf
fi

if [[ "${OPENSHIFT_CLI}" == "yes" ]]
    then
    apk --no-cache add ca-certificates
    curl -L https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub
    curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk -o glibc-2.28-r0.apk
    apk add glibc-2.28-r0.apk
    curl -L https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz --output \
    /openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
    tar -xf /openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz -C /
    mv /openshift-origin-client-tools-v3.9.0-191fece-linux-64bit/oc /usr/local/bin
    rm -rf /openshift-origin-client-tools-*
    apk del ca-certificates
fi

if [[ "${LOGIO_HARVESTER}" == "yes" ]]
    then
        FILE=./harvester_conf.sh
        if test -f "$FILE"
            then
                echo "$FILE exist"
            else
                curl https://raw.githubusercontent.com/ros-kamach/log.io_alpine/master/openshift/harvester_conf.sh \
                --output ./harvester_conf.sh
        fi
    supervisord --nodaemon --configuration /etc/supervisor/conf.d/supervisor_harvester.conf
    
fi
