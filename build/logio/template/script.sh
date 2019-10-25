#!/bin/bash
FILE=/home/logio/startup.sh	
if test -f "$FILE"; then	
    echo "$FILE exist"	
    bash /home/logio/startup.sh	
fi