# macOS Deployment Guide

## Overview

This guide covers building Qt applications for different macOS versions with backward compatibility and universal binary support.

## Key Features

- **Deployment Target**: Set minimum macOS version your app supports
- **Universal Binaries**: Support both Intel (x86_64) and Apple Silicon (arm64) architectures
- **Automatic Code Signing**: Optional support for Developer ID signing
- **DMG Creation**: Automated disk image creation for distribution

## Supported macOS Versions

| Version | Min Deployment | Architecture | Qt Support |
|---------|---------------|--------------|------------|
| Monterey (12.0+) | 12.0 | Universal (x86_64 + arm64) | Qt6 |
| Big Sur (11.0+) | 11.0 | Universal (x86_64 + arm64) | Qt6 |
| Catalina (10.15+) | 10.15 | Intel only (x86_64) | Qt6 |
| Mojave (10.14+) | 10.14 | Intel only (x86_64) | Qt5 only |

## Building for Specific Versions

### Quick Commands

```bash
# Universal binary for modern macOS (default)
./scripts/macos/build.sh

# Specific versions
./scripts/macos/build.sh monterey    # 12.0+ Universal
./scripts/macos/build.sh bigsur      # 11.0+ Universal  
./scripts/macos/build.sh catalina    # 10.15+ Intel only
./scripts/macos/build.sh mojave      # 10.14+ Intel only
```

### Custom Deployment Target

```bash
# Build with custom deployment target and architecture
./scripts/macos/build-universal.sh "11.0" "x86_64;arm64"
```

### Manual CMake Configuration

```bash
mkdir build && cd build

# For universal binary targeting macOS 11.0+
cmake -G "Xcode" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    ..

cmake --build . --config Release
```

## Architecture Support

### Universal Binaries
Universal binaries contain code for both Intel and Apple Silicon processors:

```bash
# Check architecture support
lipo -info QtApplication.app/Contents/MacOS/QtApplication

# Expected output for universal binary:
# Architectures in the fat file: QtApplication are: x86_64 arm64
```

### Architecture-Specific Builds

```bash
# Intel only (for older macOS versions)
cmake -DCMAKE_OSX_ARCHITECTURES="x86_64" ..

# Apple Silicon only
cmake -DCMAKE_OSX_ARCHITECTURES="arm64" ..
```

## Code Signing

### Automatic Signing (CI/CD)
Set environment variable for automatic signing:

```bash
export APPLE_DEVELOPER_ID="Your Developer Name"
```

### Manual Signing

```bash
# Sign the application bundle
codesign --force --verify --verbose --sign "Developer ID Application: Your Name" QtApplication.app

# Verify signature
codesign --verify --deep --verbose=2 QtApplication.app
```

## DMG Creation

The build scripts automatically create DMG files if `create-dmg` is available:

```bash
# Install create-dmg
brew install create-dmg

# DMG will be created automatically during build
# Output: QtApplication-universal-10.15.dmg
```

## Troubleshooting

### Qt6 on Older macOS
- macOS 10.14 and older require Qt5
- Check Qt version compatibility before building
- Consider building separate versions for older systems

### Architecture Mismatches
```bash
# Check what architectures your Mac supports
uname -m

# x86_64 = Intel
# arm64 = Apple Silicon
```

### Missing Dependencies
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Qt via Homebrew
brew install qt@6
```

## Best Practices

1. **Choose Appropriate Deployment Target**: 
   - Use 10.15+ for Qt6 applications
   - Use 11.0+ for Apple Silicon support
   - Test on actual target macOS versions

2. **Universal Binaries**:
   - Always build universal for maximum compatibility
   - Only use architecture-specific builds when necessary

3. **Code Signing**:
   - Sign all release builds
   - Use Developer ID for distribution outside App Store
   - Notarize for macOS 10.15+ compatibility

4. **Testing**:
   - Test on both Intel and Apple Silicon Macs
   - Verify minimum deployment target works
   - Check bundle structure and dependencies