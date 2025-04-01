#!/bin/bash
# Simple script for handling PBaaS checks. Works with Zabbix variables for the chain.
# All that's needed is the conf file with the variable flag/identifier to then pass the desired chain server-side

pbaas_chain=$1
verustest='/home/verustest/bin/verus -datadir=/home/verustest/.komodo/vrsctest -testnet'
pbaas_hex=$($verustest getvdxfid "$pbaas_chain@" | jq -r '.hash160result')
pbaas_call="/home/verustest/bin/verus -datadir=/home/bridgekeeper/.verustest/pbaas/$pbaas_hex -testnet -chain=$pbaas_chain -conf=/home/bridgekeeper/.verustest/pbaas/${pbaas_hex}/${pbaas_hex}.conf"
if [ $2 == "height" ]; then
	$pbaas_call getinfo | jq -r '.blocks'
fi
if [ $2 == "runcheck" ]; then
	if ps faux | grep [v]erusd | grep "chain=$pbaas_chain" > /dev/null 2>&1; then
		echo 1
	else
		echo 0
	fi
fi
