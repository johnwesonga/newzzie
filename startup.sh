#!/bin/bash

set -e

echo "Starting newzzie web app..."

# Ensure dependencies are installed
gleam build

# Start the development server with hot reload
gleam run -m lustre/dev start
