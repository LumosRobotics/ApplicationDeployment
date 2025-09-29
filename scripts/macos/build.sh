#!/bin/bash

set -e

VERSION=${1:-"default"}

echo "Building Qt Application for macOS..."

case $VERSION in
    "monterey"|"12.0"|"12")
        echo "Building for macOS Monterey (12.0+)..."
        ./versions/build-monterey.sh
        ;;
    "bigsur"|"11.0"|"11")
        echo "Building for macOS Big Sur (11.0+)..."
        ./versions/build-bigsur.sh
        ;;
    "catalina"|"10.15")
        echo "Building for macOS Catalina (10.15+)..."
        ./versions/build-catalina.sh
        ;;
    "mojave"|"10.14")
        echo "Building for macOS Mojave (10.14+)..."
        ./versions/build-mojave.sh
        ;;
    "universal"|"default")
        echo "Building universal binary for macOS 10.15+..."
        ./build-universal.sh "10.15" "x86_64;arm64"
        ;;
    *)
        echo "Available versions:"
        echo "  monterey (12.0+) - Universal binary"
        echo "  bigsur (11.0+)   - Universal binary"
        echo "  catalina (10.15+) - Intel only"
        echo "  mojave (10.14+)   - Intel only (requires Qt5)"
        echo "  universal         - Default universal binary (10.15+)"
        echo ""
        echo "Usage: $0 [version]"
        echo "Example: $0 monterey"
        exit 1
        ;;
esac