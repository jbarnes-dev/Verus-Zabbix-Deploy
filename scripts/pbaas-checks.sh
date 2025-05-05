#!/bin/bash
# Simple script for handling PBaaS checks. Works with Zabbix variables for the chain.
# All that's needed is the conf file with the variable flag/identifier to then pass the desired chain server-side

# Array to map chain name to explorer URL for external checks
# NOTE: vARRR/CHIPS currently does not have the API exposed or enabled. 
explorer_urls=(
    #[vARRR]="https://varrrexplorer.piratechain.com/"
    [vDEX]="https://explorer.vdex.to"
    #[CHIPS]="https://explorer.chips.cash/"
)

# Which chain
pbaas_chain=$1

# Function for passing requests to the daemon for the pbaas chain (general)
pbaas_call() {
    local verus='/home/verus/bin/verus -datadir=/home/verus/.komodo/VRSC'
    local pbaas_hex
    pbaas_hex=$($verus getvdxfid "$pbaas_chain@" | jq -r '.hash160result')

    local pbaas_cmd="/home/verus/bin/verus -datadir=/home/verus/.verus/pbaas/ -chain=$pbaas_chain -conf=/home/verus/.verus/pbaas/${pbaas_hex}/${pbaas_hex}.conf"

    $pbaas_cmd "$@"
}

pbaash_external_check() {
    if [ $1 == "heightcheck" ]; then
        local current_height=$(pbaas_call getinfo | jq .blocks)
        local remote=$(curl --silent ${explorer_urls[$pbaas_chain]}/api/getblockcount)
        echo "${current_height}-${remote}" | bc | tr -d -
    elif [ $1 == "hashcheck" ]; then
        echo "not implemented yet"
    fi
}

# Return if daemon for a given pbaas chain is running
if [ $2 == "runcheck" ]; then
	if ps faux | grep [v]erusd | grep "chain=$pbaas_chain" > /dev/null 2>&1; then
		echo 1
	else
		echo 0
	fi
        exit 0
# Specific calls for getting height, hash, external checks
elif [ $2 == "height" ]; then
	pbaas_call getinfo | jq -r '.blocks'
elif [ $2 == "hash" ]; then
	pbaas_call getbestblockhash
elif [ $2 == "heightcheck" ]; then
    echo "Not yet implemented"
elif [ $2 == "hashcheck" ]; then
    echo "Not yet implemented"
else
    echo "Invalid call"
fi


