#!/usr/bin/env bash

set -e

rm -f "/${APP_NAME}/tmp/pids/server.pid"

if [ "$RAILS_ENV" = "development" ]; then
  echo "Running in development mode"
  bundle exec rails db:create
  bundle exec rails db:migrate
  bundle exec rails db:seed
  bundle exec rails s -p 3000 -b '0.0.0.0'
else
  echo "Running in production mode"
  # bundle exec rails db:create
  # bundle exec rails db:migrate
  # bundle exec rails db:seed
  bundle exec puma -C config/puma.rb
fi
