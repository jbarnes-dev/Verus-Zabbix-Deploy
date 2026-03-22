#!/bin/bash

# Easy way to give Zabbix access to the verus user directory for checks.
# Apply to other users/services as needed


# First, install acl
apt update && apt install -y acl

# Then give zabbix the desired permissions

setfacl -m u:zabbix:x /home/verus/
