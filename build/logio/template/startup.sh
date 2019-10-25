#!/bin/bash
if [[ "${LOGIO_SERVER}" == "yes" ]]
    then
        log.io-server &
fi
if [[ "${LOGIO_HARVESTER}" == "yes" ]]
    then
        log.io-harvester &
fi
