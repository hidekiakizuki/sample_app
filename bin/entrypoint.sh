#!/usr/bin/env bash

set -e

rm -f "/${APP_NAME}/tmp/pids/server.pid"

exec "$@"