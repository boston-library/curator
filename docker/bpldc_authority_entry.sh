#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
mkdir -p /bpldc_authority_api-app/tmp/pids
if [ -f /bpldc_authority_api-app/tmp/pids/server.pid ]; then
  rm /bpldc_authority_api-app/tmp/pids/server.pid
fi

if [ -f /bpldc_authority_api-app/tmp/pids/server.state ]; then
  rm /bpldc_authority_api-app/tmp/pids/server.state
fi

bundle exec rake db:prepare

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

# based on instructions here: https://docs.docker.com/compose/rails/
