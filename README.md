# log.io Real-time log monitoringin your browser

This repository contains components for running either an operational log.io server and harvester setup for your OpenShift cluster. 

This Implimentation based on from preconfigurated components in 
<img src="https://i1.wp.com/blog.openshift.com/wp-content/uploads/redhatopenshift.png?w=1376&ssl=1" alt="Thunder" width="10%"/> **"[openshift](https://github.com/ros-kamach/openshift.git)"** with Jenkins and Thunder CMS for OpenShift

To deploy, run:

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
![alt text](http://logio.org/logio_diagram1.png)
