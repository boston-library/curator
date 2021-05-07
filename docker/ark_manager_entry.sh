#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
mkdir -p /ark-manager-app/tmp/pids
if [ -f /ark-manager-app/tmp/pids/server.pid ]; then
  rm /ark-manager-app/tmp/pids/server.pid
fi

if [ -f /ark-manager-app/tmp/pids/server.state ]; then
  rm /ark-manager-app/tmp/pids/server.state
fi

database_config_file=/ark-manager-app/config/database.yml
if [ -f "$database_config_file" ]; then
    echo "$database_config_file exist"
else
    cp /ark-manager-app/config/database.yml.sample $database_config_file
fi

bundle exec rake db:prepare

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

# based on instructions here: https://docs.docker.com/compose/rails/
