#!/bin/bash
##################################
##############ENVIROMENT##########
##################################
SINCE_TIME="15s"
LOGIO_SERVER=logio-server.thunder.svc
DIR="logio_project"
#What project connect to logio (all or one specific)
PROJECT_NAME=all
# PROJECT_NAME=thunder
#It annables periodical session for readout logs
READ_PERIODICALY=yes
READOUT_PERIOD=30s

##################################
###Create Template for Harvester##
##################################
constructor_harvester_conf_start () {
cat <<EOF | tee -a .log.io/harvester.conf
exports.config = {
  nodeName: "${1}",
  logStreams: {
EOF
}
##################################
constructor_harvester_conf_stream_log () {
cat <<EOF | tee -a .log.io/harvester.conf
    "${1}": ["./logio_project/logs/${1}.log"],
EOF
}
##################################
constructor_harvester_conf_end () {
cat <<EOF | tee -a .log.io/harvester.conf
},
  server: {
    host: '${1}',
    port: 28777
  }
}
EOF
}
##################################
#########Check PID Function#######
##################################
check_pid_kill () {
while sleep 60
do
files=$(ps aux  | grep -v grep | grep $1 | grep oc | awk '{print$2}')
    if [[ $? != 0 ]] 
    then
        echo "Command failed."
    elif [[ ! ${files} ]]; then
        printf "\nNo PID founded for ${1}\n!!! Started\n"
        oc logs -f ${1} --since=${2} --tail=-1 -n ${3}| tee ./logio_project/logs/${1}.log >  /dev/null 2>&1 &
    fi
done &
}
##################################
########Check Clear folder########
##################################
if [ -d "${DIR}" ]
    then
        rm -rf "${DIR}" .log.io/harvester.conf
        mkdir -p "${DIR}"/logs "${DIR}"/pods
    else
        mkdir -p "${DIR}"/logs "${DIR}"/pods
        rm -rf .log.io/harvester.conf
fi
##################################
######Check pod output pods#######
#########And Implement############
##################################
check_pod_not_null () {
  for val in $( cat ./logio_project/pods/${1}_pods.list ); do
      output=$(oc logs -f ${val} --follow=false --tail=-1 -n ${1})
      if [[ $? != 0 ]] 
          then
              echo "Pod ${val} not runned"
          elif [[ ! ${output} ]]; then
              echo "Pod ${val} output NULL"
          else
              echo "Pod ${val} connected"
              constructor_harvester_conf_stream_log ${val}
              if [ "${READ_PERIODICALY}" == "yes" ]
                then
                    while true
                    do
                        echo "READ_PERIODICALY=yes=$READ_PERIODICALY"
                        echo "While do fot ${val} in project ${1}"
                        oc logs -f ${val} --since=${3} --follow=false --tail=-1 -n ${1} | tee ./logio_project/logs/${val}.log >  /dev/null 2>&1 &
                        sleep ${2}
                    done &
                else
                    echo "READ_PERIODICALY=no=$READ_PERIODICALY"
                    oc logs -f ${val} --since=${3} --pod-running-timeout=15s --tail=-1 -n ${1} | tee ./logio_project/logs/${val}.log >  /dev/null 2>&1 &
                    check_pid_kill ${val} ${3} ${1}
              fi
      fi
  done
}
##################################
###Check Pod list by namespaces###
##################################
if [ "$PROJECT_NAME" == "all" ]
    then
        PROJECT_LIST=$( oc get project | awk '{ print$1 }' | tail -n +2 )
        for value in ${PROJECT_LIST}; do
            constructor_harvester_conf_start ${value}
            if [[ ! $( oc get pods -n ${value} 2> /dev/null ) ]] 
                then
                    printf "\nThere are no pods in project ${value}"
                else
                    printf "\nPods in project ${value}"
                    PODS_LIST=$( oc get pods -n ${value} | awk '{ print$1 }' | tail -n +2 )
                    echo ${PODS_LIST} | tr ' ' '\n' > ./logio_project/pods/${value}_pods.list
                    check_pod_not_null ${value} ${READOUT_PERIOD} ${SINCE_TIME}
            fi
            constructor_harvester_conf_end ${LOGIO_SERVER}
            echo "PROJECT_NAME=all"
            echo "Project name ${value}"
            log.io-harvester &
            sleep 5
            rm -rf .log.io/harvester.conf
        done
    else
        constructor_harvester_conf_start ${PROJECT_NAME}
        if [[ ! $( oc get pods -n ${PROJECT_NAME} 2> /dev/null ) ]] 
            then
                printf "\nThere are no pods in project ${PROJECT_NAME}"
            else
                printf "\nPods in project ${PROJECT_NAME}"
                PODS_LIST=$( oc get pods -n ${PROJECT_NAME} | awk '{ print$1 }' | tail -n +2 )
                echo ${PODS_LIST} | tr ' ' '\n' > ./logio_project/pods/${PROJECT_NAME}_pods.list
                check_pod_not_null ${PROJECT_NAME} ${READOUT_PERIOD} ${SINCE_TIME}
        fi
        echo "PROJECT_NAME=no=$PROJECT_NAME"
        echo "Project name ${value}"
        constructor_harvester_conf_end ${LOGIO_SERVER}
        log.io-harvester &
        # log.io-harvester -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start my_first_process: $status"
  exit $status
fi
        sleep 5
        rm .log.io/harvester.conf
fi
