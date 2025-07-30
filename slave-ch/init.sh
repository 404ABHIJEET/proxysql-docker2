#!/bin/bash

# This script is to be run inside the slave container
# or from host using `docker exec`

# Update these variables for each slave
MASTER_HOST="state-ch-master-host"
MASTER_PORT=3306
REPL_USER="repl"
REPL_PASS="replpass"

# Set for slave-1
# SLAVE DB: admin_replica1
# Replicate from admin_master

echo "Setting up replication..."

mysql -uroot -proot -e "
STOP SLAVE;

CHANGE MASTER TO
  MASTER_HOST='${MASTER_HOST}',
  MASTER_USER='${REPL_USER}',
  MASTER_PASSWORD='${REPL_PASS}',
  MASTER_PORT=${MASTER_PORT},
  MASTER_USE_GTID=slave_pos;

START SLAVE;
"

echo "Replication status:"
mysql -uroot -proot -e "SHOW SLAVE STATUS\G"
