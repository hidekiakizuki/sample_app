#!/bin/sh

set -e

rm -f "/${APP_NAME}/tmp/pids/server.pid"

exec "$@"
