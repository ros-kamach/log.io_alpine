# log.io Real-time log monitoringin your browser

![alt text](https://raw.githubusercontent.com/ros-kamach/log.io_alpine/master/logio.png)
This repository contains components for running either an operational log.io server and harvester setup for your OpenShift cluster. 

#### Befoure begin:
1) must be logged in
2) need project for deploying logio 
3) build image runs in namespace "openshift", but you can specify by adding to deploy command parameter ```"-p BUILD_PROJECT=<project name> "```

#### Build Proberty:
| Property                | Valid options   | Description                        |
|-------------------------|-----------------|------------------------------------|         
| INSTALL_OPENSHIFT_CLI | "yes"    | Install Openshift CLI (harvester need it for recource  discovery) |

#### Deployment Proberty:
| Property                | Valid options   | Description                        |
|-------------------------|-----------------|------------------------------------|
| LOGIO_WEB_OPENSHIFT     |     "apply"     | Runs pod with log.io server demon  |
| HARVESTER_OPENSHIFT     |     "apply"     | Runs pod with harvester demon and resource discovery script  |
| LOGIO_SERVER_URL        | "logio-server.${DEPLOY_PROJECT}.svc"  | Here you can specify where harvester will send logs |
| SINCE_TIME              | '1h'   | Only return logs newer than a relative duration like 5s, 2m, or 3h. Defaults to all logs. Only one of since-time / since may be used.  |
| GREP_POD_NAME           | < pattern >   | grep can be used to connect only pods with literal matched by pattern |
| PROJECT_NAME            | "thunder jenkins-ci"  | write down what project to scan for pod logs ("<1> <'n'>..." Attancion projects must be seperated by "space") If blank than scan all projects |
| READ_PERIODICALY           | "yes"   | open and close connection to pods by applying paraneter "--follow=false" and applying script to restart readout every pod periodicaly |
| READOUT_PERIOD           | "30s"   | period of redout every pod, depends on READ_PERIODICALY parameter |

# To implement, run:

syntax:
```
$ oc process -f logio_build.yaml -p BUILD_PROJECT=<project name for deploy> | oc <apply or delete> -f - 
```
```
$ oc process -f logio_deployment.yaml -p DEPLOY_PROJECT=<project name for deploy> -p BUILD_PROJECT=<project name for deploy> | oc <apply or delete> -f - 
```
example:
```
$ oc process -f logio_build.yaml -p BUILD_PROJECT=openshift | oc apply -f -
```
```
$ oc process -f logio_deployment.yaml -p DEPLOY_PROJECT=thunder -p BUILD_PROJECT=openshift | oc apply -f -
```

# How does it work?

*Harvesters* watch log files for changes, send new log messages to the *server* via TCP, which broadcasts to *web clients* via socket.io.

Log streams are defined by mapping file paths to a stream name in harvester configuration.

Users browse streams and nodes in the web UI, and activate (stream, node) pairs to view and search log messages in screen widgets.