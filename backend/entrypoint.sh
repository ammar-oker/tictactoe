#!/bin/sh
set -e

# Create the db if it doesn't exist
if ! bundle exec rake db:exists; then
  bundle exec rake db:create
fi

# Run migrations
bundle exec rake db:migrate

# Then exec the container's main process.
exec "$@"
