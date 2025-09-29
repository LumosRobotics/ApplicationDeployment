#!/bin/bash

set -e

DEPLOYMENT_TARGET=${1:-"10.15"}
ARCHITECTURES=${2:-"x86_64;arm64"}

echo "Building Qt Application for macOS (Universal Binary)..."
echo "Deployment Target: $DEPLOYMENT_TARGET"
echo "Architectures: $ARCHITECTURES"

# Create build directory
mkdir -p build
cd build

# Configure with CMake for universal binary
cmake -G "Xcode" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$DEPLOYMENT_TARGET \
    -DCMAKE_OSX_ARCHITECTURES="$ARCHITECTURES" \
    ..

# Build the application
cmake --build . --config Release

echo "Build completed successfully!"
echo ""
echo "Running deployment..."

# Install and deploy
cmake --install . --config Release

echo "Deployment completed successfully!"
echo "Application bundle location: build/Release/QtApplication.app"

# Verify architecture support
echo ""
echo "Verifying architecture support:"
lipo -info Release/QtApplication.app/Contents/MacOS/QtApplication

# Optional: Create DMG package
if command -v create-dmg &> /dev/null; then
    echo ""
    echo "Creating DMG package..."
    create-dmg \
        --volname "QtApplication" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "QtApplication.app" 175 120 \
        --hide-extension "QtApplication.app" \
        --app-drop-link 425 120 \
        "QtApplication-universal-${DEPLOYMENT_TARGET}.dmg" \
        "Release/"
    echo "DMG package created: QtApplication-universal-${DEPLOYMENT_TARGET}.dmg"
fi