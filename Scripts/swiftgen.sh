#!/bin/bash

# SwiftGen Build Script
# This script runs SwiftGen to generate localization files

set -e

# Get the project directory
PROJECT_DIR="${SRCROOT}"

# Check if SwiftGen is available
if ! command -v swiftgen &> /dev/null; then
    echo "warning: SwiftGen not found. Please install it via Homebrew: brew install swiftgen"
    exit 0
fi

# Run SwiftGen with the configuration file
echo "Running SwiftGen..."
cd "$PROJECT_DIR"
swiftgen config run --config swiftgen.yml

echo "SwiftGen completed successfully"
