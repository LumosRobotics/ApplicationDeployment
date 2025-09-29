#!/bin/bash

set -e

echo "Building Qt Application for macOS Big Sur and later (11.0+)..."

# Build for macOS 11.0+ with universal binary
../build-universal.sh "11.0" "x86_64;arm64"