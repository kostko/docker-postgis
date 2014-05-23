#!/bin/bash

DATADIR="/var/lib/postgresql/9.3/main"
CONF="/etc/postgresql/9.3/main/postgresql.conf"
POSTGRES="/usr/lib/postgresql/9.3/bin/postgres"
INITDB="/usr/lib/postgresql/9.3/bin/initdb"

# Test if DATADIR is existent
if [ ! -d $DATADIR ]; then
  echo "Creating PostgreSQL data at $DATADIR"
  mkdir -p $DATADIR
fi

# Test if DATADIR has content
if [ ! -f $DATADIR/PG_VERSION ]; then
  echo "Initializing PostgreSQL database at $DATADIR"
  chown postgres:postgres $DATADIR
  chmod 700 $DATADIR
  sudo -u postgres $INITDB -E UNICODE -D $DATADIR
  sudo -u postgres $POSTGRES --single -D $DATADIR -c config_file=$CONF <<< "CREATE USER $PGSQL_SUPERUSER_USERNAME WITH SUPERUSER PASSWORD '$PGSQL_SUPERUSER_PASSWORD';"
  echo "PostgreSQL database initialized."
fi

# Start PostgreSQL
trap "echo \"Sending SIGTERM to postgres\"; killall -s SIGTERM postgres" SIGTERM
sudo -u postgres $POSTGRES -D $DATADIR -c config_file=$CONF &
wait $!

