# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Qt multi-platform application deployment system designed as a Git submodule for Qt projects. It provides CMake functions and build scripts for cross-platform deployment to Windows, macOS, and multiple Linux distributions using Docker.

## Common Commands

### Building Applications

```bash
# Build for current platform (avoids conflicts with dev builds)
mkdir build_release && cd build_release
cmake .. && cmake --build . --config Release

# Build using deployment scripts for specific platforms
./scripts/windows/build.bat                    # Windows build
./scripts/macos/build.sh monterey              # macOS Monterey (universal)
./scripts/macos/build.sh catalina              # macOS Catalina (Intel)
./scripts/linux/build.sh ubuntu 22.04         # Ubuntu 22.04
./scripts/linux/build.sh debian bookworm      # Debian Bookworm

# Build all Linux distributions
./build-all.sh

# Build from parent project (when used as submodule)
./deployment/build-parent.sh . MyApp windows
./deployment/build-parent.sh . MyApp macos monterey
./deployment/build-parent.sh . MyApp linux ubuntu 22.04
```

### Output Directory Structure

When used as a submodule, deployment outputs are placed in the parent repository's root:
```
ParentProject/
├── Release/
│   └── MacOS/
│       ├── MyApp.app              # Application bundle
│       └── MyApp-universal-10.15.dmg  # DMG file (if CREATE_DMG enabled)
│   ├── Windows/                   # Windows builds (future)
│   └── Linux/                     # Linux builds (future)
├── build/                         # Development build directory
└── build_release/                 # Release build directory (avoids conflicts)
```

When used standalone, outputs go to the build_release directory's Release/MacOS folder.

### DMG Creation (macOS)

```bash
# Create DMG after building (when CREATE_DMG option is enabled)
cmake --build . --target MyApp_dmg

# DMG creation is automatically handled by build scripts
# Requires: brew install create-dmg
# Output: Release/MacOS/MyApp-universal-10.15.dmg (when used as submodule)
# Output: build_release/Release/MacOS/MyApp-universal-10.15.dmg (when standalone)
```

### Testing and Development

```bash
# Local build without Docker
mkdir build_release && cd build_release
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja

# Check architecture support (macOS)
lipo -info QtApplication.app/Contents/MacOS/QtApplication

# Verify code signing (macOS)
codesign --verify --deep --verbose=2 QtApplication.app
```

## Core Architecture

### CMake Module Structure

- **`deployment.cmake`**: Core deployment functions (`qt_deploy_application`, `qt_create_application`)
- **`integrate.cmake`**: High-level integration functions for parent projects (`create_qt_application`, `setup_qt_deployment`)
- **`CMakeLists.txt`**: Example standalone usage and submodule detection

### Key CMake Functions

1. **`create_qt_application(TARGET_NAME)`**: All-in-one function that creates Qt target and configures deployment
2. **`setup_qt_deployment(TARGET_NAME)`**: Applies deployment configuration to existing targets
3. **`qt_deploy_application(TARGET_NAME)`**: Low-level deployment configuration
4. **`qt_create_deployment_package(TARGET_NAME)`**: Copies build scripts and Docker files

### Platform-Specific Configuration

**Windows**: Uses Visual Studio 2022, generates deployment scripts, WIN32 subsystem
**macOS**: Supports universal binaries (x86_64 + arm64), deployment targets 10.14+, code signing, DMG creation
**Linux**: Docker-based builds for multiple distributions, AppImage support

### Supported Platforms

- **macOS**: Monterey (12.0+), Big Sur (11.0+), Catalina (10.15+), Mojave (10.14+)
- **Linux**: Ubuntu (18.04-24.04), Debian (Buster-Trixie), Fedora (37-40), Arch Linux
- **Windows**: Windows 10/11 x64

## Integration Patterns

### As Git Submodule (Primary Use Case)

```cmake
# In parent project CMakeLists.txt
include(deployment/integrate.cmake)

# Option 1: All-in-one approach
create_qt_application(MyApp
    SOURCES src/main.cpp src/window.cpp
    HEADERS src/window.h
    QT_MODULES Core Widgets
    BUNDLE_ID "com.company.myapp"
    CREATE_DMG                              # Enable DMG creation
    ENABLE_DOCKER_BUILD
    ENABLE_CI_CONFIG
)

# Option 2: Manual target + deployment
qt_add_executable(MyApp src/main.cpp)
target_link_libraries(MyApp Qt6::Core Qt6::Widgets)
setup_qt_deployment(MyApp 
    BUNDLE_ID "com.company.myapp"
    CREATE_DMG                              # Enable DMG creation
    DMG_BACKGROUND "path/to/background.png" # Optional custom background
    DMG_ICON "path/to/icon.icns"            # Optional custom volume icon
)
```

### Standalone Usage (Development)

Used for testing the deployment system itself with the example application in `src/`.

## Build System Details

### Docker Integration

- Each Linux distribution has dedicated Dockerfiles in `docker/`
- `build-all.sh` builds for all supported distributions
- Container builds extract binaries to `dist/` directory

### Cross-Platform Scripts

- `build-parent.sh`: Unified build script for parent projects
- Platform-specific scripts in `scripts/{windows,macos,linux}/`
- Version-specific macOS builds in `scripts/macos/versions/`

### CI/CD Integration

- `.github/workflows/` contains GitHub Actions for automated builds
- `ENABLE_CI_CONFIG` option copies workflows to parent projects
- Automatic release asset creation and universal binary builds

## Development Notes

- Repository expects Qt6 (Qt5 only for macOS 10.14 and older)
- Uses CMake 3.20+ for Qt6 compatibility
- Code signing via `APPLE_DEVELOPER_ID` environment variable
- AppImage creation with `linuxdeploy` when available
- Universal macOS binaries default to targeting 10.15+ with x86_64+arm64