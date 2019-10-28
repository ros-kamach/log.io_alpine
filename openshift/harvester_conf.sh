#!/bin/bash
mkdir /home/logio/logs
# touch /home/logio/logs/error.log
# touch /home/logio/logs/access.log
rm /home/logio/.log.io/harvester.conf 2>/dev/null
oc logs -f jenkins-1-rgfbt --tail=-1 -n jenkins-ci | tee /home/logio/logs/jenkins-1-rgfbt.log >  /dev/null 2>&1 &
oc logs -f mysql-1-llmjp --tail=-1 -n thunder | tee /home/logio/logs/mysql-1-llmjp.log >  /dev/null 2>&1 &
cat <<EOF | tee -a /home/logio/.log.io/harvester.conf
exports.config = {
  nodeName: "thunder",
  logStreams: {

    "mysql-1-llmjp": [
          "/home/logio/logs/mysql-1-llmjp.log"
        ],

},
  nodeName: "jenkins-ci",
  logStreams: {

    "jenkins-1-rgfbt": [
          "/home/logio/logs/jenkins-1-rgfbt.log"
        ],

},

  server: {
    host: 'logio-server.thunder.svc',
    port: 28777
  }
}
EOF
