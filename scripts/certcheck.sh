#!/bin/bash

CERT_FILE="/etc/nginx/ssl/cert.pem"

if [[ ! -f "$CERT_FILE" ]]; then
    echo "❌ Certificate file '$CERT_FILE' not found."
    exit 1
fi

# Extract expiration info
EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
NOW_EPOCH=$(date +%s)

DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

echo $DAYS_LEFT
