#!/bin/bash
mkdir /home/logio/logs
touch /home/logio/logs/error.log
touch /home/logio/logs/access.log
rm /home/logio/.log.io/harvester.conf 2>/dev/null
cat <<EOF | tee -a /home/logio/.log.io/harvester.conf
exports.config = {
  nodeName: "node",
  logStreams: {

    error: [
          "/home/logio/logs/error.log"
        ],

    access: [
          "/home/logio/logs/access.log"
        ],

},

  server: {
    host: 'logio-server.thunder.svc',
    port: 28777
  }
}
EOF

log.io-harvester
