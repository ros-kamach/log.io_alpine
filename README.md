# log.io Real-time log monitoringin your browser

This repository contains components for running either an operational log.io server and harvester setup for your OpenShift cluster. 

#### Befoure begin:
1) must be logged in
2) need project for deploying logio 
3) build image runs in namespace "openshift", but you can specify by adding to deploy command parameter ```"-p BUILD_PROJECT=<project name> "```


| Property      | Valid options   | Description   |
|------------------|--------------------|--------------------|
| LOGIO_WEB_OPENSHIFT |     "apply"        |  |
| HARVESTER_OPENSHIFT   | "apply"   |  |
| INSTALL_OPENSHIFT_CLI   | "yes"    |  |
| routingcafile    | routing CA file    |  |
| routingcertfile  | routing CERT file  |  |
| routingkeyfile   | routing Key file   |  |

# To implement, run:

syntax:
```
$ oc process -f logio_build.yaml -p DEPLOY_PROJECT_NAME=<project name for deploy> | oc <apply or delete> -f - 
```
```
$ oc process -f logio_deployment.yaml -p DEPLOY_PROJECT_NAME=<project name for deploy> | oc <apply or delete> -f - 
```
example:
```
$ oc process -f logio_build.yaml -p DEPLOY_PROJECT_NAME=thunder | oc apply -f -
```
```
$ oc process -f logio_deployment.yaml -p DEPLOY_PROJECT_NAME=thunder | oc apply -f -
```
![alt text](https://raw.githubusercontent.com/ros-kamach/log.io_alpine/master/logio.png)

# How does it work?

*Harvesters* watch log files for changes, send new log messages to the *server* via TCP, which broadcasts to *web clients* via socket.io.

Log streams are defined by mapping file paths to a stream name in harvester configuration.

Users browse streams and nodes in the web UI, and activate (stream, node) pairs to view and search log messages in screen widgets.