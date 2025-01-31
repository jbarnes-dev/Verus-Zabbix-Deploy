#!/bin/bash

HOST=136.243.31.98
HOST_HEIGHT=$(curl --silent https://explorer.verus.io/api/getblockcount --resolve "explorer.verus.io:443:$HOST")
DAEMON_HEIGHT=$(/home/verus/bin/verus --datadir=/home/verus/.komodo/VRSC getinfo | jq '.blocks')
DELTA=$(echo "$DAEMON_HEIGHT - $HOST_HEIGHT" | bc)
echo $DELTA
