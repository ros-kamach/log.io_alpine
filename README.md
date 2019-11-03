# log.io Real-time log monitoringin your browser

![alt text](https://raw.githubusercontent.com/ros-kamach/log.io_openshift/master/logio.png)
This repository contains components for running either an operational log.io server and harvester setup for your OpenShift cluster. 

#### Befoure begin:
1) must be logged via openshift-cli with account which has administrator privileges (cluster-admin)
2) project for build and deploy must exist. If not , you can create it by ```oc new-project <project name>```
3) building image runs in namespace "openshift" by default, but you can change by adding to command parameter ```-p BUILD_PROJECT=<project name> ```

#### Build Proberty:
| Property                | Valid options   | Description                        |
|-------------------------|-----------------|------------------------------------|         
| INSTALL_OPENSHIFT_CLI | "yes"    | Install Openshift CLI (needs on pod with harvester) |

#### Deployment Proberty:
| Property                | Valid options   | Description                        |
|-------------------------|-----------------|------------------------------------|
| LOGIO_WEB_OPENSHIFT     |               "apply"                 | Runs pod with log.io server demon  |
| HARVESTER_OPENSHIFT     |               "apply"                 | Runs pod with harvester demon and resource discovery script  |
| LOGIO_SERVER_URL        | "logio-server.${DEPLOY_PROJECT}.svc"  | harvester sends logs to this URL |
| SINCE_TIME              |                 '1h'                  | Only return logs newer than a relative duration like 5s, 2m, or 3h. Defaults to all logs. Only one of since-time / since may be used.  |
| GREP_POD_NAMES           |              < pattern >             | connect pods with literal matched by pattern only |
| SKIP_POD_NAMES          |               < pattern >             | skip pod names with literal matched by pattern |
| PROJECT_NAME            |          "thunder jenkins-ci"         | project to scan for pod logs ("<1> <'n'>..." Attancion projects must be seperated by "space") If empty it scans all project names |
| READ_PERIODICALY        |                "yes"                  | open and close connection to pods by applying paraneter "--follow=false" and applying script to restart and read out every pod periodicaly |
| READOUT_LOG_PERIOD      |                "30s"                  | period of reading out logs from pods, depends on READ_PERIODICALY parameter |

# To implement:

syntax:
```
$ oc process -f logio_build.yaml -p BUILD_PROJECT=<project name for deploy> | oc <apply or delete> -f - 
```
```
$ oc process -f logio_deployment_oauth.yaml -p DEPLOY_PROJECT=<project name for deploy> -p BUILD_PROJECT=<project name for deploy> | oc <apply or delete> -f - 
```
examples:
### Process Build
```
$ oc process -f logio_build.yaml | oc apply -f -
```
or (specific build namespace)
```
$ oc process -f logio_build.yaml -p BUILD_PROJECT=openshift | oc apply -f -
```
### Process Deploy with OpenShift OAuth Proxy
```
$ oc process -f logio_deployment_oauth.yaml -p DEPLOY_PROJECT=thunder -p | oc apply -f -
```
or (specific build namespace)
```
$ oc process -f logio_deployment_oauth.yaml -p DEPLOY_PROJECT=thunder -p BUILD_PROJECT=openshift | oc apply -f -
```
### Process Deploy without OpenShift OAuth Proxy
```
$ oc process -f logio_deployment.yaml -p DEPLOY_PROJECT=thunder -p | oc apply -f -
```
or (specific build namespace)
```
$ oc process -f logio_deployment.yaml -p DEPLOY_PROJECT=thunder -p BUILD_PROJECT=openshift | oc apply -f -
```

# How does it work?

*Harvesters* watch log files for changes, send new log messages to the *server* via TCP, which broadcasts to *web clients* via socket.io.

Log streams are defined by mapping file paths to a stream name in harvester configuration.

Users browse streams in the web UI, and activate (stream, node) pairs to view and search log messages in screen widgets.