#!/bin/bash

set -e

echo "Building Qt Application for macOS Catalina and later (10.15+)..."

# Build for macOS 10.15+ with Intel-only (Apple Silicon wasn't available)
../build-universal.sh "10.15" "x86_64"