# log.io Real-time log monitoringin your browser

This repository contains components for running either an operational log.io server and harvester setup for your OpenShift cluster. 

This Implimentation based on from preconfigurated components in 
<img src="https://i1.wp.com/blog.openshift.com/wp-content/uploads/redhatopenshift.png?w=1376&ssl=1" alt="Thunder" width="10%"/> **"[openshift](https://github.com/ros-kamach/openshift.git)"** with Jenkins and Thunder CMS for OpenShift

To deploy, run:

syntax:
```
$ bash prometheus-grafana.sh <project name for monitoring> <apply or delete> 
```
example:
```
$ bash prometheus-grafana.sh openshift-metrics apply
```
![alt text](http://logio.org/logio_diagram1.png)
