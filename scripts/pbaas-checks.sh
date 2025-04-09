#!/bin/bash
# Simple script for handling PBaaS checks. Works with Zabbix variables for the chain.
# All that's needed is the conf file with the variable flag/identifier to then pass the desired chain server-side

# Which chain
pbaas_chain=$1

# For run check, does not require anything more than the chain name
if [ $2 == "runcheck" ]; then
	if ps faux | grep [v]erusd | grep "chain=$pbaas_chain" > /dev/null 2>&1; then
		echo 1
	else
		echo 0
	fi
        exit 0
fi

# For other checks, requires a bit more information. For now in a simple if statement, needs reworked into a function
# TODO: Rework into a function
if [ $2 != "runcheck" ]; then
    verus='/home/verus/bin/verus -datadir=/home/verus/.komodo/VRSC '
    pbaas_hex=$($verus getvdxfid "$pbaas_chain@" | jq -r '.hash160result')
    pbaas_call="/home/verus/bin/verus -datadir=/home/verus/.verus/pbaas/ -chain=$pbaas_chain -conf=/home/verus/.verus/pbaas/${pbaas_hex}/${pbaas_hex}.conf"
fi

if [ $2 == "height" ]; then
	$pbaas_call getinfo | jq -r '.blocks'
fi
