#!/bin/bash

# This small server is only used in case the user doesn't want to do the FLutter install locally

# Welcome
echo 'Server start script initialized...'

# Set the port
PORT=4040

# Kill anything that is already running on that port
echo 'Cleaning port' $PORT '...'
fuser -k 4040/tcp

# Change directories to the release folder
cd build/web/

# Start the server
echo 'Starting server on port' $PORT '...'
python3 -m http.server $PORT

# Exit
echo 'Server exited...'