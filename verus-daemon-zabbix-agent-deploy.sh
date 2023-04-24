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
    sitecheck="https://insight.verus.io"
    check_prefix="vrsc"
elif [ ${verustype} == "verustest" ]; then
    datadir="vrsctest"
    sitecheck="https://testex.verus.io"\
    check_prefix="vrsctest"
else
    echo "Unknown verustype"
    exit 1
fi

#Install dependencies for verus monitoring
apt install jq curl bc -y

#Make temporary directories for storing installer
mkdir -p /tmp/zbx && cd /tmp/zbx
wget https://repo.zabbix.com/zabbix/5.0/debian/pool/main/z/zabbix-release/zabbix-release_5.0-1+buster_all.deb
apt install ./zabbix-release_5.0-1+buster_all.deb -y
apt install zabbix-agent -y

#Remove stock config
rm /etc/zabbix/zabbix_agentd.conf

#Add our own standard config
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

#Make directories so it doesn't complain
mkdir -p /etc/zabbix/zabbix_agentd.conf.d
mkdir -p /etc/zabbix/zabbix_agentd.d
mkdir -p /var/log/zabbix/
chown -R zabbix:zabbix /var/log/zabbix

#Add in the verus specific config(s), comment this out and use a different script if a webserver/non-daemon machine
cat << EOF >> /etc/zabbix/zabbix_agentd.conf.d/${verustype}-daemon.conf
UserParameter=${check_prefix}.height,/home/${verustype}/bin/${verustype} -datadir=/home/${verustype}/.komodo/${datadir} getinfo | jq .blocks
UserParameter=${check_prefix}.hash,/home/${verustype}/bin/${verustype} -datadir=/home/${verustype}/.komodo/${datadir} getbestblockhash
UserParameter=${check_prefix}.connections,/home/${verustype}/bin/${verustype} -datadir=/home/${verustype}/.komodo/${datadir} getinfo | jq .connections
UserParameter=${check_prefix}.version,/home/${verustype}/bin/${verustype} -datadir=/home/${verustype}/.komodo/${datadir} getinfo | jq .VRSCversion
UserParameter=${check_prefix}.runningcheck,/etc/zabbix/zabbix_agentd.conf.d/verus_running.sh
UserParameter=${check_prefix}.heightdiff,local=\$(/home/${verustype}/bin/${verustype} -datadir=/home/${verustype}/.komodo/${datadir} getinfo | jq .blocks); remote=\$(curl --silent ${sitecheck}/api/getblockcount); echo "\${local}-\${remote}" | bc | tr -d -
UserParameter=${check_prefix}.hashmatch,/etc/zabbix/zabbix_agentd.conf.d/verus-hashdiff.sh
EOF

#Add script to verify verus is runnning
cat << EOF >> /etc/zabbix/zabbix_agentd.conf.d/verus_running.sh
#!/bin/bash

pidof verusd | awk 'BEGIN { n=0 } { if (NF>=1) n=NF} END { print n}'
EOF

#Make executable 
chmod +x /etc/zabbix/zabbix_agentd.conf.d/verus_running.sh

#Add script for checking hash difference
cat << EOF >> /etc/zabbix/zabbix_agentd.conf.d/verus-hashdiff.sh
#!/bin/bash

hash_local=\$(/home/verus/bin/verus -datadir=/home/verus/.komodo/VRSC getbestblockhash)
height_remote=\$(curl --silent ${sitecheck}/api/getblockcount)
hash_remote=\$(curl --silent ${sitecheck}/api/getblockhash?index=\${height_remote} | jq -r .)
if [ -z "\${hash_local}" ] || [ -z "\${hash_remote}" ]; then
	check_status=0
elif [ "\${hash_local}" == "\${hash_remote}" ]; then
	check_status=1
else
	check_status=0
fi
echo \$check_status
EOF
#Make executable
chmod +x /etc/zabbix/zabbix_agentd.conf.d/verus-hashdiff.sh

#Take this time to setup host in zabbix server
echo "Installation complete. Setup server-side then restart zabbix-agent"
