#!/bin/bash

set -e

DISTRO=${1:-"ubuntu"}
VERSION=${2:-""}

# Default versions for each distro
declare -A DEFAULT_VERSIONS
DEFAULT_VERSIONS["ubuntu"]="22.04"
DEFAULT_VERSIONS["debian"]="bookworm"
DEFAULT_VERSIONS["fedora"]="39"
DEFAULT_VERSIONS["arch"]="base"

# Available versions for each distro
declare -A AVAILABLE_VERSIONS
AVAILABLE_VERSIONS["ubuntu"]="18.04 20.04 22.04 24.04"
AVAILABLE_VERSIONS["debian"]="buster bullseye bookworm trixie"
AVAILABLE_VERSIONS["fedora"]="37 38 39 40"
AVAILABLE_VERSIONS["arch"]="base lts"

# Use default version if not specified
if [ -z "$VERSION" ]; then
    VERSION=${DEFAULT_VERSIONS[$DISTRO]}
fi

# Validate version
if [[ ! " ${AVAILABLE_VERSIONS[$DISTRO]} " =~ " $VERSION " ]]; then
    echo "Error: Invalid version '$VERSION' for $DISTRO"
    echo "Available versions: ${AVAILABLE_VERSIONS[$DISTRO]}"
    exit 1
fi

echo "Building Qt Application for Linux ($DISTRO $VERSION)..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Building locally..."
    
    # Local build
    mkdir -p build_release
    cd build_release
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
    ninja
    
    echo "Build completed successfully!"
    echo "Binary location: build_release/QtApplication"
    
    # Create AppImage if linuxdeploy is available
    if command -v linuxdeploy &> /dev/null; then
        echo "Creating AppImage..."
        mkdir -p AppDir
        DESTDIR=AppDir cmake --install .
        linuxdeploy --appdir AppDir --output appimage
        echo "AppImage created!"
    fi
else
    echo "Using Docker for containerized build..."
    
    # Docker build
    DOCKERFILE_PATH="docker/$DISTRO/$VERSION/Dockerfile"
    if [ ! -f "$DOCKERFILE_PATH" ]; then
        echo "Error: Dockerfile not found at $DOCKERFILE_PATH"
        exit 1
    fi
    
    docker build -t qtapp-$DISTRO-$VERSION -f $DOCKERFILE_PATH .
    
    # Extract binary from container
    mkdir -p dist/$DISTRO-$VERSION
    docker run --rm -v $(pwd)/dist/$DISTRO-$VERSION:/output qtapp-$DISTRO-$VERSION cp /app/build_release/QtApplication /output/
    
    echo "Build completed successfully!"
    echo "Binary location: dist/$DISTRO-$VERSION/QtApplication"
fi