#!/bin/bash

SCRIPT_PID=$(ps -u "iquidus" x | grep "scripts/sync.js"| grep -v "grep\|cd /home/iquidus/explorer" | awk '{print $1}' | head -n 1)
if [[ "$SCRIPT_PID" == "" ]];
then
  SCRIPT_TIME=0
else
  SCRIPT_TIME=$(ps -o etimes= -p $SCRIPT_PID | awk '{print $1}')
fi
echo $SCRIPT_TIME
