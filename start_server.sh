#!/bin/bash

# this is only to be used by phoenix.new AI agents.
# for now, config/.env is present in the repository (which is insecure)
# but as soon as phoenix.new allows env variables to be set persistently,
# we won't need to load config/.env like this anymore.

# Check if config/.env file exists
if [ -f config/.env ]; then
    echo "Loading environment variables from config/.env file..."
    set -a; source config/.env; set +a
    echo "Environment variables loaded!"
else
    echo "Warning: config/.env file not found"
fi

# Start the Phoenix server
echo "Starting Phoenix server..."
mix phx.server
