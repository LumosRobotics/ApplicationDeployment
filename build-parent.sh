#!/bin/bash

set -e

# This script is designed to be run from the parent repository
# It builds the application using the deployment submodule

PARENT_DIR=${1:-".."}
TARGET_NAME=${2:-""}
PLATFORM=${3:-""}
VERSION=${4:-""}

if [ -z "$TARGET_NAME" ]; then
    echo "Usage: $0 <parent_dir> <target_name> [platform] [version]"
    echo ""
    echo "Examples:"
    echo "  $0 .. MyApp linux ubuntu"
    echo "  $0 .. MyApp macos monterey"
    echo "  $0 .. MyApp windows"
    echo ""
    echo "Platforms: windows, macos, linux"
    echo "Linux versions: ubuntu, debian, fedora, arch (with version numbers)"
    echo "macOS versions: monterey, bigsur, catalina, mojave"
    exit 1
fi

echo "Building $TARGET_NAME from parent directory: $PARENT_DIR"

# Change to parent directory
cd "$PARENT_DIR"

# Determine build strategy based on platform
case $PLATFORM in
    "windows")
        echo "Building for Windows..."
        mkdir -p build_release
        cd build_release
        cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release ..
        cmake --build . --config Release
        cmake --install . --config Release
        echo "Windows build completed!"
        ;;
    "macos")
        echo "Building for macOS..."
        if [ -n "$VERSION" ]; then
            echo "Building for macOS version: $VERSION"
            case $VERSION in
                "monterey"|"12.0"|"12")
                    DEPLOYMENT_TARGET="12.0"
                    ARCHITECTURES="x86_64;arm64"
                    ;;
                "bigsur"|"11.0"|"11")
                    DEPLOYMENT_TARGET="11.0"
                    ARCHITECTURES="x86_64;arm64"
                    ;;
                "catalina"|"10.15")
                    DEPLOYMENT_TARGET="10.15"
                    ARCHITECTURES="x86_64"
                    ;;
                "mojave"|"10.14")
                    DEPLOYMENT_TARGET="10.14"
                    ARCHITECTURES="x86_64"
                    ;;
                *)
                    DEPLOYMENT_TARGET="10.15"
                    ARCHITECTURES="x86_64;arm64"
                    ;;
            esac
        else
            DEPLOYMENT_TARGET="10.15"
            ARCHITECTURES="x86_64;arm64"
        fi
        
        mkdir -p build_release
        cd build_release
        cmake -G "Xcode" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=$DEPLOYMENT_TARGET \
            -DCMAKE_OSX_ARCHITECTURES="$ARCHITECTURES" \
            ..
        cmake --build . --config Release
        cmake --install . --config Release
        echo "macOS build completed!"
        ;;
    "linux")
        echo "Building for Linux..."
        if [ -n "$VERSION" ]; then
            echo "Using Docker for Linux build: $VERSION"
            # Use the deployment submodule's Docker build
            ./deployment/scripts/linux/build.sh "$VERSION"
        else
            echo "Building locally for Linux..."
            mkdir -p build_release
            cd build_release
            cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
            ninja
            cmake --install .
        fi
        echo "Linux build completed!"
        ;;
    "")
        echo "No platform specified. Building for current platform..."
        mkdir -p build_release
        cd build_release
        cmake -DCMAKE_BUILD_TYPE=Release ..
        cmake --build . --config Release
        cmake --install . --config Release
        echo "Build completed!"
        ;;
    *)
        echo "Unknown platform: $PLATFORM"
        echo "Supported platforms: windows, macos, linux"
        exit 1
        ;;
esac