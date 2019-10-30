#!/bin/bash
##################################
##############ENVIROMENT##########
##################################
# SINCE_TIME="1h"
# LOGIO_SERVER=logio-server.thunder.svc
DIR="logio_project"
#What project connect to logio (all or one specific)
# PROJECT_NAME=all
# PROJECT_NAME="thunder jenkins-ci"
#It annables periodical session for readout logs
# READ_PERIODICALY=yes
# READOUT_PERIOD=30s

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
if [ -z "$PROJECT_NAME" ]
# if [ "$PROJECT_NAME" == "all" ]
    then
        PROJECT_LIST=$( oc get project | awk '{ print$1 }' | tail -n +2 )
        printf "Script will apply for namespace \n$PROJECT_LIST"
        sleep 2
    else
        PROJECT_LIST=$(echo ${PROJECT_NAME} | tr ' ' '\n' )
        printf "Script will apply for namespace \n$PROJECT_LIST"
        sleep 2
    
fi
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


check_args () {
case $4 in
  (apply|delete) ;; # OK
  (*) printf >&2 "Wrong arg.${2}${4}${3}. Allowed are ${1}apply${3} or ${1}delete${3} \n";
      printf >&2 "!!! \n";
      printf >&2 "syntax: bash <*.sh> <jenkins_project> <thunder_proje> <apply or delete> \n";
      printf >&2 "## \n";
      printf >&2 "example: bash project.sh jenkins-ci thunder apply \n";exit 1;;
esac
}