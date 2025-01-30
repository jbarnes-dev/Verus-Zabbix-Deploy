#!/bin/bash

hash_local=$(/home/verus/bin/verus -datadir=/home/verus/.komodo/VRSC getbestblockhash)
height_local=$(/home/verus/bin/verus -datadir=/home/verus/.komodo/VRSC getinfo | jq -r '.blocks')
hash_remote=$(curl --silent --data-binary "{\"jsonrpc\" : \"1.0\", \"id\" : \"hashget\", \"method\" : \"getblock\", \"params\" : [$height_local]}" -H 'content-type:text/plain;' https://api.verus.services | jq -r '.result.hash')
if [ -z "${hash_local}" ] || [ -z "${hash_remote}" ]; then
	check_status=0
elif [ "${hash_local}" == "${hash_remote}" ]; then
	check_status=1
else
	check_status=0
fi
echo $check_status
