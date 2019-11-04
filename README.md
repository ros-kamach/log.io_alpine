# log.io Real-time log monitoring in your browser

![alt text](https://raw.githubusercontent.com/ros-kamach/log.io_openshift/master/logio.png)
This repository contains components for running either an operational log.io server and harvester setup for your OpenShift cluster. 

#### Before begin:
1) must be logged via openshift-cli with the account which has administrator privileges (cluster-admin)
2) clone the repository<img src="https://help.github.com/assets/images/help/repository/clone-repo-clone-url-button.png" alt="Thunder" width="20%"/>
3) project for build and deploy must exist, recomends to use "openshift" for build and "openshift-infra" (or other project dedicated to cluster admins) for deploy. If you want other project name, you can create it by ```oc new-project < project name >```
4) building image runs by default in namespace "openshift", but can be changed by adding to command parameter ```-p BUILD_PROJECT=< project name > ```

#### Build Property:
| Property                   | Valid options   | Description                        |
|:-------------------------|:-----------------:|------------------------------------|         
| ```INSTALL_OPENSHIFT_CLI``` | ```"yes"```    | Install Openshift CLI (needs on the pod with harvester) |

#### Deployment Property:
| Property                | Valid options   | Description                        |
|:-------------------------|:-----------------:|------------------------------------|
| ```LOGIO_WEB_OPENSHIFT```     |               ```"apply"```                 | pod with log.io server demon  |
| ```HARVESTER_OPENSHIFT```     |               ```"apply"```                 | pod with harvester demon and resource discovery script  |
| ```LOGIO_SERVER_URL```        | ```"logio-server.${DEPLOY_PROJECT}.svc"```  | harvester sends logs to this URL |
| ```SINCE_TIME```              |```"30s"```<br>```"5m"```<br>```"1h"```      | Only return logs newer than a relative duration like 5s, 2m, or 3h. Defaults to all logs. Only one of since-time / since may be used.  |
| ```GREP_POD_NAMES```           |              ```<pattern>```             | connect pods with literal matched by pattern only |
| ```SKIP_POD_NAMES```          |               ```<pattern>```             | skip pod names with literal matched by pattern |
| ```PROJECT_NAME```            |          ```"1_project 2_project n_project"```        | project to scan for pod logs ("<1> <'n'>..." Attention projects must be separated by "space"). **If empty it scans all project names** |
| ```READ_PERIODICALY```        |                ```"yes"```                  | open and close connection to pods by applying parameter "--follow=false" and applying script to restart and read out every pod periodically |
| ```READOUT_LOG_PERIOD```      |                ```"30s"``` / ```"1h"```                  | interval of reading out logs from pods (depends on READ_PERIODICALY parameter) |

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