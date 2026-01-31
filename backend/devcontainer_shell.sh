#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if devcontainer CLI is installed
if ! command -v devcontainer &> /dev/null; then
    echo "Error: devcontainer CLI is not installed."
    echo "Please install it first: npm install -g @devcontainers/cli"
    exit 1
fi

echo "🚀 Ensuring Dev Container environment is up..."

# Bring up the devcontainer if it's not already running
# --workspace-folder . assumes we are running this from the directory containing .devcontainer (the backend dir)
devcontainer up --workspace-folder .

echo "✅ Container is up. Opening interactive shell..."

# Exec into the container with an interactive bash shell
devcontainer exec --workspace-folder . /bin/bash
