#!/bin/bash
##################################
CONFIG_DIR="logio_scan_files"
# LOGIO_SERVER_URL="logio-server.${DEPLOY_PROJECT}.svc"
# INSTALL_OPENSHIFT_CLI="no"
# SINCE_TIME='1h'
# # PROJECT_NAME="thunder jenkins-ci"
# GREP_POD_NAMES=mysql
# SKIP_POD_NAMES=mysql
# READOUT_LOG_PERIOD="30s"
# READ_PERIODICALY="yes"
##################################
###Create Template for Harvester##
##################################
constructor_harvester_conf_start () {
# cat <<EOF | tee -a .log.io/harvester.conf
cat <<EOF | tee -a ./${2}/conf/${1}_harvester.conf
exports.config = {
  nodeName: "${1}",
  logStreams: {
EOF
}
##################################
constructor_harvester_conf_stream_log () {
# cat <<EOF | tee -a .log.io/harvester.conf
cat <<EOF | tee -a ./${2}/conf/${1}_harvester.conf
    "${3}": ["./${2}/logs/${3}.log"],
EOF
}
##################################
constructor_harvester_conf_end () {
# cat <<EOF | tee -a .log.io/harvester.conf
cat <<EOF | tee -a ./${2}/conf/${1}_harvester.conf
},
  server: {
    host: '${3}',
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
        echo "oc logs -f ${1} ${2} --tail=-1 -n ${3}| tee ./${4}/logs/${1}.log >  /dev/null 2>&1 &"
        oc logs -f ${1} ${2} --tail=-1 -n ${3}| tee ./${4}/logs/${1}.log >  /dev/null 2>&1 &
    fi
done &
}
##################################
######Check pod output pods#######
#########And Implement############
##################################
check_pod_not_null () {
  for val in $( cat ./${2}/pods/${1}_pods.list ); do
      output=$(oc logs -f ${val} --follow=false --tail=-1 -n ${1})
    #   echo "123 ${output}"
      if [[ $? != 0 ]] 
          then
              echo "Pod ${val} not runned"
          elif [[ ! ${output} ]]; then
              echo "Pod ${val} output NULL"
          else
              echo "Pod ${val} connected"
              constructor_harvester_conf_stream_log ${1} ${2} ${val} 
              if [ "${4}" == "yes" ]
                then
                    if [ -z "$5" ]
                        then
                            echo "[ERROR] Missing Readout log period environment variable. Will connect as streem."
                            echo "oc logs -f ${val} ${3} --pod-running-timeout=15s --tail=-1 -n ${1} | tee ./${2}/logs/${val}.log >  /dev/null 2>&1 &"
                            oc logs -f ${val} ${3} --pod-running-timeout=15s --tail=-1 -n ${1} | tee ./${2}/logs/${val}.log >  /dev/null 2>&1 &
                            check_pid_kill ${val} ${3} ${1} ${2}
                        else
                            while sleep ${5}
                            do
                                echo "While do fot ${val} in project ${1}"
                                echo "oc logs -f ${val} ${3} --follow=false --tail=-1 -n ${1} | tee ./${2}/logs/${val}.log >  /dev/null 2>&1 &"
                                oc logs -f ${val} ${3} --follow=false --tail=-1 -n ${1} | tee ./${2}/logs/${val}.log >  /dev/null 2>&1 &
                            done &
                    fi
                else
                    echo "oc logs -f ${val} ${3} --pod-running-timeout=15s --tail=-1 -n ${1} | tee ./${2}/logs/${val}.log >  /dev/null 2>&1 &"
                    oc logs -f ${val} ${3} --pod-running-timeout=15s --tail=-1 -n ${1} | tee ./${2}/logs/${val}.log >  /dev/null 2>&1 &
                    check_pid_kill ${val} ${3} ${1} ${2}
              fi
      fi
  done
}
##################################
########Show input param##########
echo "LOGIO_SERVER_URL=$LOGIO_SERVER_URL"
echo "SINCE_TIME=$SINCE_TIME"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "GREP_POD_NAMES=$GREP_POD_NAMES"
echo "SKIP_POD_NAMES=$SKIP_POD_NAMES"
echo "READOUT_LOG_PERIOD=$READOUT_LOG_PERIOD"
echo "READ_PERIODICALY=$READ_PERIODICALY"
if [ -z "$CONFIG_DIR" ]
    then
        echo "[ERROR] Missing config dir environment variable. Aborting."
        exit 1
fi
if [ -z "$LOGIO_SERVER_URL" ]
    then
        echo "[ERROR] Missing Log.io server URL environment variable. Aborting."
        exit 1
fi
if [ -z "$LOGIO_SERVER_URL" ]
    then
        echo "[ERROR] Missing Log.io server URL environment variable. Aborting."
        exit 1
fi
##################################
########Check Clear folder########
##################################
if [ -d "${CONFIG_DIR}" ]
    then
        rm -rf ${CONFIG_DIR} .log.io/harvester.conf
        mkdir -p ${CONFIG_DIR}/logs ${CONFIG_DIR}/pods ${CONFIG_DIR}/conf
    else
        mkdir -p ${CONFIG_DIR}/logs ${CONFIG_DIR}/pods ${CONFIG_DIR}/conf
        rm -rf .log.io/harvester.conf
fi
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
            constructor_harvester_conf_start ${value} ${CONFIG_DIR}
            if [ -z "$GREP_POD_NAMES" ]
                then
                    if [ -z "$SKIP_POD_NAMES" ]
                        then
                            POD_NAMES="$( oc get pods -n ${value} 2> /dev/null )"
                        else
                            echo "Filter Pods by Skipping pattern $SKIP_POD_NAMES in namespace ${value}"
                            POD_NAMES="$( oc get pods -n ${value} | grep -v $SKIP_POD_NAMES 2> /dev/null )"
                    fi
                else
                    if [ -z "$SKIP_POD_NAMES" ]
                        then
                            echo "Filter Pods by Grep command grep $GREP_POD_NAMES in namespace ${value}"
                            POD_NAMES="$( oc get pods -n ${value} | grep $GREP_POD_NAMES 2> /dev/null )"
                        else
                            echo "Filter Pods by Grep command grep $GREP_POD_NAMES and Skipping pattern $SKIP_POD_NAMES in namespace ${value}"
                            POD_NAMES="$( oc get pods -n ${value} | grep $GREP_POD_NAMES | grep -v $SKIP_POD_NAMES 2> /dev/null )"
                    fi  
            fi
            if [[ ! "${POD_NAMES}" ]] 
                then
                    printf "\nThere are no pods in project ${value}"
                else
                    printf "\nPods in project ${value}"
                    if [ -z "$GREP_POD_NAMES" ]
                        then
                            if [ -z "$SKIP_POD_NAMES" ]
                                then
                                    PODS_LIST=$( oc get pods -n ${value} | awk '{ print$1 }' | tail -n +2 )
                                else
                                    echo "Filter Pods by Skipping pattern $SKIP_POD_NAMES in namespace ${value}"
                                    PODS_LIST="$( oc get pods -n ${value} | grep $SKIP_POD_NAMES | awk '{ print$1 }' | tail -n +2 )"
                            fi
                        else
                            if [ -z "$SKIP_POD_NAMES" ]
                                then
                                    echo "Filter Pods by Grep command grep $GREP_POD_NAMES in namespace ${value}"
                                    PODS_LIST="$( oc get pods -n ${value} | grep $GREP_POD_NAMES | awk '{ print$1 }' | tail -n +2 )"
                                else
                                    echo "Filter Pods by Grep command grep $GREP_POD_NAMES and Skipping pattern $SKIP_POD_NAMES in namespace ${value}"
                                    POD_NAMES="$( oc get pods -n ${value} | grep $GREP_POD_NAMES | grep $SKIP_POD_NAMES 2> /dev/null )"
                                    PODS_LIST=$( oc get pods -n ${value} | grep $GREP_POD_NAMES | grep  $SKIP_POD_NAMES | awk '{ print$1 }' | tail -n +2 )
                            fi
                    fi
                    echo ${PODS_LIST} | tr ' ' '\n' > ./"${CONFIG_DIR}"/pods/${value}_pods.list
                    check_pod_not_null ${value} ${CONFIG_DIR} ${SINCE_TIME_COMMAND} ${READ_PERIODICALY} ${READOUT_LOG_PERIOD}

            fi
            constructor_harvester_conf_end ${value} ${CONFIG_DIR} ${LOGIO_SERVER_URL}
            if [ "$( cat ./${CONFIG_DIR}/conf/${value}_harvester.conf | wc -l )" -le "9" ]
                then
                    echo "There are no resource for that paramethers in ${value}"
                    rm -rf ./${CONFIG_DIR}/conf/${value}_harvester.conf
                else
                    echo "Connecting recources to log.io server ${value}"
                    cp ./${CONFIG_DIR}/conf/${value}_harvester.conf .log.io/harvester.conf
                    log.io-harvester &
                    sleep 2
                    rm -rf .log.io/harvester.conf
            fi
        done