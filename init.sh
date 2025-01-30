#!/bin/bash

#Run as root on desired server, will install zabbix-agent and base configuration. 
#If it still wont show up once script finishes, try to restart the service
#and check /var/log/zabbix/zabbix-agentd.conf or /var/log/zabbix-agent/zabbix-agentd.conf
#Written for debian and debian derivative systems.

#Specify if verus or verustest, this assumes standard config - e.g. /home/verus/bin/verus for mainnet
#and /home/verustest/bin/verustest for testnet
#Also requires specifying th IP for the zabbix server

zabbixserverip=
verustype="verus"
if [ ${verustype} == "verus" ]; then
    datadir="VRSC"
    sitecheck="https://api.verus.services"
    check_prefix="vrsc"
elif [ ${verustype} == "verustest" ]; then
    datadir="vrsctest"
    sitecheck="https://testex.verus.io"\
    check_prefix="vrsctest"
else
    echo "Unknown verustype"
    exit 1
fi

# Install dependencies for verus monitoring
apt install jq curl bc -y

# Install Zabbix agent (assumes debian or debian-like OS)
apt update && apt upgrade -y && apt install -y zabbix-agent

#Remove stock config
rm /etc/zabbix/zabbix_agentd.conf

#Create standard config
cat << EOF >> /etc/zabbix/zabbix_agentd.conf
Include=/etc/zabbix/zabbix_agentd.conf.d/*.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=${zabbixserverip}
ListenPort=10050
ListenIP=0.0.0.0
ServerActive=${zabbixserverip}
Hostname=${HOSTNAME}
EOF

# Make directories so it doesn't complain
mkdir -p /etc/zabbix/zabbix_agentd.conf.d
mkdir -p /etc/zabbix/zabbix_agentd.d
mkdir -p /var/log/zabbix/
chown -R zabbix:zabbix /var/log/zabbix

# Finish up

echo "Base Zabbix-agent configured"
