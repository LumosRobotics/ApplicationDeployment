#!/bin/bash

set -e

echo "Building Qt Application for macOS Mojave and later (10.14+)..."

# Note: Qt6 requires macOS 10.15+, so this will require Qt5
echo "Warning: macOS 10.14 requires Qt5. Please ensure Qt5 is installed."

# Build for macOS 10.14+ with Intel-only
../build-universal.sh "10.14" "x86_64"