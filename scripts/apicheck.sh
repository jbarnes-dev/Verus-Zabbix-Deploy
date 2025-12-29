#!/bin/bash

api_response=$(curl --silent --max-time 30 --data-binary '{"jsonrpc":"1.0","id":"curltest", "method": "getblock", "params": [1337] }' -H 'content-type: text/plain' http://127.0.0.1:3045 | jq -r '.result.hash')

known_hash="0000000000e1373d9c645c5a77376fe36b69c77180962414ebbf2e63c115d85e"


if [ $known_hash == $api_response ];
then
	echo 1
else
	echo 0
fi	
