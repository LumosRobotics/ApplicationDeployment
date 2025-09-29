# Integration Guide: Using as a Git Submodule

This guide shows how to integrate this deployment system into your existing Qt application repository as a Git submodule.

## Quick Setup

### 1. Add as Submodule

```bash
# In your main application repository
git submodule add https://github.com/yourusername/ApplicationDeployment.git deployment
git submodule update --init --recursive
```

### 2. Update Your CMakeLists.txt

Choose one of these approaches:

**Option A: All-in-one (Recommended)**
```cmake
include(deployment/integrate.cmake)

create_qt_application(MyApp
    SOURCES
        src/main.cpp
        src/mainwindow.cpp
    HEADERS
        src/mainwindow.h
    QT_MODULES Core Widgets
    BUNDLE_ID "com.company.myapp"
    MACOS_DEPLOYMENT_TARGET "10.15"
    ENABLE_DOCKER_BUILD
    ENABLE_CI_CONFIG
)
```

**Option B: Manual target creation**
```cmake
include(deployment/integrate.cmake)

# Create your target manually
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
qt_standard_project_setup()

qt_add_executable(MyApp
    src/main.cpp
    src/mainwindow.cpp
)

target_link_libraries(MyApp Qt6::Core Qt6::Widgets)

# Then setup deployment
setup_qt_deployment(MyApp
    BUNDLE_ID "com.company.myapp"
    MACOS_DEPLOYMENT_TARGET "10.15"
    ENABLE_DOCKER_BUILD
    ENABLE_CI_CONFIG
)
```

### 3. Build Your Application

```bash
# Local build
mkdir build && cd build
cmake ..
cmake --build . --config Release

# Or use the deployment scripts
./deployment/build-parent.sh . MyApp macos monterey
./deployment/build-parent.sh . MyApp linux ubuntu
```

## Detailed Integration

### CMake Integration Options

#### Basic Integration
```cmake
# Minimal setup - just include deployment functions
include(deployment/deployment.cmake)

# Apply to your target
qt_deploy_application(MyApp)
```

#### Advanced Integration
```cmake
# Full integration with all features
include(deployment/integrate.cmake)

setup_qt_deployment(MyApp
    BUNDLE_ID "com.company.myapp"
    MACOS_DEPLOYMENT_TARGET "11.0"          # macOS Big Sur+
    MACOS_ARCHITECTURES "x86_64;arm64"      # Universal binary
    WINDOWS_SUBSYSTEM WIN32                  # Windows GUI app
    ENABLE_DOCKER_BUILD                      # Copy Docker files
    ENABLE_CI_CONFIG                         # Copy CI/CD config
)
```

#### Platform-Specific Configuration
```cmake
# Skip specific platforms
setup_qt_deployment(MyApp
    SKIP_LINUX          # Don't configure Linux deployment
    BUNDLE_ID "com.company.myapp"
)

# Or configure deployment manually
qt_deploy_application(MyApp
    MACOS_DEPLOYMENT_TARGET "10.14"    # Support older macOS
    MACOS_ARCHITECTURES "x86_64"       # Intel only
    SKIP_WINDOWS                       # Skip Windows config
)
```

### Directory Structure

Your project structure should look like this:

```
MyApplication/
├── CMakeLists.txt           # Your main CMake file
├── src/                     # Your application source
├── deployment/              # This submodule
│   ├── deployment.cmake
│   ├── integrate.cmake
│   ├── scripts/
│   ├── docker/
│   └── .github/
└── build/                   # Build directory
    └── deploy/              # Deployment files copied here
        ├── windows/
        ├── macos/
        ├── linux/
        └── docker/
```

### Build Scripts

The submodule provides a parent build script:

```bash
# Usage: ./deployment/build-parent.sh <parent_dir> <target_name> [platform] [version]

# Build for current platform
./deployment/build-parent.sh . MyApp

# Build for specific platforms
./deployment/build-parent.sh . MyApp windows
./deployment/build-parent.sh . MyApp macos monterey
./deployment/build-parent.sh . MyApp linux ubuntu 22.04

# Build for all Linux distributions
cd deployment && ./build-all.sh
```

### CI/CD Integration

#### Automatic CI/CD Setup
When using `ENABLE_CI_CONFIG`, the GitHub Actions workflow is copied to your repository:

```cmake
setup_qt_deployment(MyApp ENABLE_CI_CONFIG)
```

This copies `.github/workflows/parent-build.yml` to your repository root.

#### Manual CI/CD Setup
Copy and customize the provided workflow:

```bash
cp deployment/.github/workflows/parent-build.yml .github/workflows/build.yml
# Edit to match your application name and requirements
```

#### Key CI/CD Features
- Builds for Windows, macOS (multiple versions), and Linux (multiple distros)
- Creates universal macOS binaries
- Automatic release asset creation
- Docker-based Linux builds for consistency

### Advanced Configuration

#### Custom Docker Builds
```cmake
# Enable Docker files to be copied to your build directory
qt_setup_docker_deployment(MyApp)
```

This copies all Docker configurations to `build/deploy/docker/` for customization.

#### Custom Info.plist for macOS
```cmake
qt_deploy_application(MyApp
    MACOS_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/resources/Info.plist.in"
)
```

#### Code Signing
Set environment variable for automatic signing:

```bash
export APPLE_DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"
cmake --build build --config Release
```

### Troubleshooting

#### Submodule Not Found
```bash
# Initialize submodules if missing
git submodule update --init --recursive

# Update to latest version
cd deployment
git pull origin main
cd ..
git add deployment
git commit -m "Update deployment submodule"
```

#### CMake Integration Issues
```cmake
# Check if submodule exists before including
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/deployment/integrate.cmake")
    include(deployment/integrate.cmake)
else()
    message(WARNING "Deployment submodule not found")
endif()
```

#### Docker Build Issues
```bash
# Ensure Docker is running
docker --version

# Build manually to debug
cd deployment
docker build -t test-build -f docker/ubuntu/22.04/Dockerfile ..
```

### Migration from Standalone

If you already have a Qt project, here's how to migrate:

1. **Add the submodule**:
   ```bash
   git submodule add <this-repo-url> deployment
   ```

2. **Update your CMakeLists.txt**:
   ```cmake
   # Add after your qt_add_executable
   include(deployment/integrate.cmake)
   setup_qt_deployment(YourAppName)
   ```

3. **Update your CI/CD**:
   ```bash
   cp deployment/.github/workflows/parent-build.yml .github/workflows/
   # Edit to match your app name
   ```

4. **Test the integration**:
   ```bash
   mkdir build && cd build
   cmake ..
   cmake --build . --config Release
   ```

## Examples

See the `examples/` directory (if available) for complete working examples of:
- Simple Qt Widget application
- Qt Quick/QML application  
- Multi-target application (mobile + desktop)
- Custom deployment configurations