#!/bin/bash

set -e

echo "Building Qt Application for macOS Monterey and later (12.0+)..."

# Build for macOS 12.0+ with universal binary
../build-universal.sh "12.0" "x86_64;arm64"