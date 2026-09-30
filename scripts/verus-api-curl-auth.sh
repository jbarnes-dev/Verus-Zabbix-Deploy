#!/usr/bin/env bash
set -euo pipefail

url=${VERUS_API_URL:-https://api.verus.services/} # authenticated endpoint
app_id=${VERUS_APP_ID:-zabbix} # Change to reflect your key
key_file=${VERUS_API_KEY_FILE:-./zabbix-api.key} # Change to where your key is located and secured
body=${1:?Usage: verus-api-curl-auth.sh 'JSON request body'}
auth=$(python3 -c '
import hashlib
from pathlib import Path
import secrets
import sys
import time

app_id, key_file, body = sys.argv[1:]
key = Path(key_file).read_bytes().rstrip(b"\r\n")
if not key:
    sys.exit("Empty Verus API key file")

timestamp = str(time.time_ns() // 1_000_000)
salt = secrets.token_bytes(32)
message = (
    timestamp.encode("ascii") + key + body.encode("utf-8")
    + app_id.encode("utf-8") + b"2" + salt
)
token = hashlib.blake2b(message, digest_size=64).hexdigest()
print(timestamp, salt.hex(), token)
' "$app_id" "$key_file" "$body")
read -r timestamp salt token <<< "$auth"

curl -q --fail --silent --show-error --max-time 10 \
    -H 'Content-Type: application/json' \
    -H "X-App-ID: $app_id" \
    -H "X-Timestamp: $timestamp" \
    -H "X-VRPC-API-Version: 2" \
    -H "X-Salt: $salt" \
    -H "X-Auth-Token: $token" \
    --data-binary "$body" "$url"
