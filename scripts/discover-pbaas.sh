#!/bin/bash

EXCLUDE_LIST=("vrsctest" "VRSCTEST")

# Persistent file
PBAAS_FILE="/etc/zabbix/zabbix_agentd.conf.d/known_pbaas.txt"

# Temp file to hold new instances
TMP_FILE=$(mktemp)

# Discover currently running instances
ps faux | grep "verusd" | grep "\-chain\=" | grep -v grep | sed -n 's/.*chain\=\([^ ]*\).*/\1/p' | sort -u > "$TMP_FILE"

# Create the persistent instance list if it doesn't exist
touch "$PBAAS_FILE"

# Merge known and newly discovered instances
cat "$PBAAS_FILE" "$TMP_FILE" | sort -u > "${PBAAS_FILE}.new"
mv "${PBAAS_FILE}.new" "$PBAAS_FILE"

# Generate JSON for Zabbix LLD
echo '['
FIRST=1
while read -r pbaas_chain; do
    # Check exclusion
    skip=0
    for excluded in "${EXCLUDE_LIST[@]}"; do
        if [[ "$pbaas_chain" == "$excluded" ]]; then
            skip=1
            break
        fi
    done
    if [ $skip -eq 1 ]; then
        continue
    fi

    if [ $FIRST -eq 0 ]; then echo ','; fi
    echo -n "  { \"CHAIN\": \"$pbaas_chain\" }"
    FIRST=0
done < "$PBAAS_FILE"
echo ']'

rm "$TMP_FILE"
