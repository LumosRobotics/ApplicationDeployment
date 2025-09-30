#!/bin/bash

set -e

DEPLOYMENT_TARGET=${1:-"10.15"}
ARCHITECTURES=${2:-"x86_64;arm64"}

echo "Building Qt Application for macOS (Universal Binary)..."
echo "Deployment Target: $DEPLOYMENT_TARGET"
echo "Architectures: $ARCHITECTURES"

# Create build directory for release builds
mkdir -p build_release
cd build_release

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
echo "Build artifacts location: build_release/"
echo "Application bundle copied to: $(pwd)/../Release/MacOS/QtApplication.app"

# Verify architecture support
echo ""
echo "Verifying architecture support:"
if [ -f "../Release/MacOS/QtApplication.app/Contents/MacOS/QtApplication" ]; then
    lipo -info ../Release/MacOS/QtApplication.app/Contents/MacOS/QtApplication
else
    echo "Warning: Application bundle not found in Release/MacOS/"
fi

# Create DMG package if create-dmg is available
if command -v create-dmg &> /dev/null; then
    echo ""
    echo "Creating DMG package..."
    
    # Get app name from bundle
    APP_NAME="QtApplication"
    
    # Final output directory is always Release/MacOS at repo root
    OUTPUT_DIR="../Release/MacOS"
    
    if [ -d "$OUTPUT_DIR/${APP_NAME}.app" ]; then
        # Architecture string for DMG filename
        ARCH_STRING=""
        if [[ "$ARCHITECTURES" == *"x86_64"* && "$ARCHITECTURES" == *"arm64"* ]]; then
            ARCH_STRING="universal"
        elif [[ "$ARCHITECTURES" == *"arm64"* ]]; then
            ARCH_STRING="arm64"
        elif [[ "$ARCHITECTURES" == *"x86_64"* ]]; then
            ARCH_STRING="x86_64"
        fi
        
        DMG_NAME="${APP_NAME}-${ARCH_STRING}-${DEPLOYMENT_TARGET}.dmg"
        
        # Remove existing DMG if it exists
        [ -f "$OUTPUT_DIR/$DMG_NAME" ] && rm "$OUTPUT_DIR/$DMG_NAME"
        
        # Create DMG with proper configuration
        cd "$OUTPUT_DIR"
        
        # Build create-dmg command
        CREATE_DMG_CMD=(
            create-dmg
            --volname "$APP_NAME"
            --window-pos 200 120
            --window-size 600 400
            --icon-size 100
            --icon "${APP_NAME}.app" 175 190
            --hide-extension "${APP_NAME}.app"
            --app-drop-link 425 190
            --no-internet-enable
        )
        
        # Add volume icon if available
        if [ -f "${APP_NAME}.app/Contents/Resources/AppIcon.icns" ]; then
            CREATE_DMG_CMD+=(--volicon "${APP_NAME}.app/Contents/Resources/AppIcon.icns")
        fi
        
        # Add background if available
        if [ -f "${APP_NAME}.app/Contents/Resources/dmg-background.png" ]; then
            CREATE_DMG_CMD+=(--background "${APP_NAME}.app/Contents/Resources/dmg-background.png")
        fi
        
        CREATE_DMG_CMD+=("$DMG_NAME" ".")
        
        # Execute create-dmg command
        "${CREATE_DMG_CMD[@]}"
        
        if [ $? -eq 0 ]; then
            echo "DMG package created successfully: $DMG_NAME"
            echo "DMG size: $(du -h "$DMG_NAME" | cut -f1)"
            echo "DMG location: $(pwd)/$DMG_NAME"
            echo "Application bundle location: $(pwd)/${APP_NAME}.app"
        else
            echo "Warning: DMG creation failed, but application build was successful"
        fi
    else
        echo "Warning: Application bundle not found at $OUTPUT_DIR/${APP_NAME}.app"
        echo "Make sure the build completed successfully and the app was copied to Release/MacOS/"
    fi
else
    echo ""
    echo "create-dmg not found. Install with: brew install create-dmg"
    echo "Skipping DMG creation."
fi