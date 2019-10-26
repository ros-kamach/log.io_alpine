#!/bin/bash
if [[ "${LOGIO_SERVER}" == "yes" ]]
    then
        log.io-server
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
     bash ./harvester_conf.sh
     log.io-harvester
fi
