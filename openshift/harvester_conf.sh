#!/bin/bash
touch /home/logio/logs/error.log
touch /home/logio/logs/access.log
rm /home/logio/.log.io/harvester.conf
cat <<EOF | sudo tee -a /home/logio/.log.io/harvester.conf
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
