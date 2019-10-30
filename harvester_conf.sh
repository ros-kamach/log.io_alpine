#!/bin/bash
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
        echo "oc logs -f ${1} ${2} --tail=-1 -n ${3}| tee ./logio_project/logs/${1}.log >  /dev/null 2>&1 &"
        oc logs -f ${1} ${2} --tail=-1 -n ${3}| tee ./logio_project/logs/${1}.log >  /dev/null 2>&1 &
    fi
done &
}
##################################
########Check Clear folder########
##################################
DIR="logio_project"
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
                        echo "oc logs -f ${val} ${3} --follow=false --tail=-1 -n ${1} | tee ./logio_project/logs/${val}.log >  /dev/null 2>&1 &"
                        oc logs -f ${val} ${3} --follow=false --tail=-1 -n ${1} | tee ./logio_project/logs/${val}.log >  /dev/null 2>&1 &
                        sleep ${2}
                    done &
                else
                    echo "READ_PERIODICALY=no=$READ_PERIODICALY"
                    echo "oc logs -f ${val} ${3} --pod-running-timeout=15s --tail=-1 -n ${1} | tee ./logio_project/logs/${val}.log >  /dev/null 2>&1 &"
                    oc logs -f ${val} ${3} --pod-running-timeout=15s --tail=-1 -n ${1} | tee ./logio_project/logs/${val}.log >  /dev/null 2>&1 &
                    check_pid_kill ${val} ${3} ${1}
              fi
      fi
  done
}
##################################
########Show input param##########
echo "LOGIO_SERVER_URL=$LOGIO_SERVER_URL"
echo "HARVESTER_OPENSHIFT=$HARVESTER_OPENSHIFT"
echo "INSTALL_OPENSHIFT_CLI=$INSTALL_OPENSHIFT_CLI"
echo "SINCE_TIME=$SINCE_TIME"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "GREP_POD_NAME=$GREP_POD_NAME"
echo "READOUT_PERIOD=$READOUT_PERIOD"
echo "READ_PERIODICALY=$READ_PERIODICALY"
##################################
###Check Pod list by namespaces###
##################################
if [ -z "$PROJECT_NAME" ]
    then
        PROJECT_LIST=$( oc get project | awk '{ print$1 }' | tail -n +2 )
        printf "Script will apply for namespace \n$PROJECT_LIST"
        sleep 2
    else
        PROJECT_LIST=$(echo ${PROJECT_NAME} | tr ' ' '\n' )
        printf "Script will apply for namespace \n$PROJECT_LIST"
        sleep 2
fi
if [ ! -z "$SINCE_TIME" ]
    then
        echo "SINCE_TIME=$SINCE_TIME"
        SINCE_TIME_COMMAND="--since=$SINCE_TIME"
        echo "SINCE_TIME_COMMAND=$SINCE_TIME_COMMAND"
fi
        for value in ${PROJECT_LIST}; do
            constructor_harvester_conf_start ${value}
            if [ -z "$GREP_POD_NAME" ]
                then
                    POD_NAMES="oc get pods -n ${value} | grep $GREP_POD_NAME 2> /dev/null"
                    echo "POD_NAMES=$POD_NAMES"
                else
                    POD_NAMES="oc get pods -n ${value} 2> /dev/null"
                    echo "POD_NAMES=$POD_NAMES"
            fi
            if [[ ! $( ${POD_NAMES} ) ]] 
                then
                    printf "\nThere are no pods in project ${value}"
                else
                    printf "\nPods in project ${value}"
                    PODS_LIST=$( oc get pods -n ${value} | awk '{ print$1 }' | tail -n +2 )
                    echo ${PODS_LIST} | tr ' ' '\n' > ./logio_project/pods/${value}_pods.list
                    check_pod_not_null ${value} ${READOUT_PERIOD} ${SINCE_TIME_COMMAND}
            fi
            constructor_harvester_conf_end ${LOGIO_SERVER_URL}
            sleep 5
            if [ "$( cat .log.io/harvester.conf | wc -l )" -gt "9" ]
                then
                    echo "Project name ${value}"
                    log.io-harvester &
                    sleep 5
                    rm -rf .log.io/harvester.conf
                else
                    rm -rf .log.io/harvester.conf
            fi
        done