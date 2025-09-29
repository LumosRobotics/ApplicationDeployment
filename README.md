# Qt Multi-Platform Application Deployment

A cross-platform Qt application deployment system supporting Windows, macOS, and multiple Linux distributions using CMake and Docker. Designed to be used as a Git submodule in your Qt application projects.

## Quick Start (as Submodule)

```bash
# Add to your Qt project
git submodule add <this-repo-url> deployment

# In your CMakeLists.txt
include(deployment/integrate.cmake)
setup_qt_deployment(YourAppName)

# Build
mkdir build && cd build
cmake .. && cmake --build . --config Release
```

See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for detailed setup instructions.

## Structure

```
├── deployment.cmake         # Main CMake functions
├── integrate.cmake          # Easy integration for parent projects
├── CMakeLists.txt          # Standalone example (optional)
├── docker/                 # Docker configurations for Linux builds
│   ├── ubuntu/             # Multiple Ubuntu versions
│   ├── debian/             # Multiple Debian versions  
│   ├── fedora/             # Multiple Fedora versions
│   └── arch/               # Arch Linux variants
├── scripts/                # Platform-specific build scripts
│   ├── windows/build.bat
│   ├── macos/build.sh      # Version-specific macOS builds
│   └── linux/build.sh     # Docker-based Linux builds
├── .github/workflows/      # CI/CD configurations
├── examples/               # Integration examples
└── INTEGRATION_GUIDE.md    # Detailed setup guide
```

## Prerequisites

- **CMake** 3.20 or higher
- **Qt6** development libraries
- **Docker** (for Linux builds)

### Platform-specific requirements:

**Windows:**
- Visual Studio 2022 or Build Tools
- Qt6 for MSVC

**macOS:**
- Xcode Command Line Tools
- Qt6 for macOS

**Linux:**
- Build essentials (gcc, make, etc.)
- Qt6 development packages

## Usage as Submodule

### Integration

1. **Add as submodule**:
   ```bash
   git submodule add <this-repo-url> deployment
   ```

2. **In your CMakeLists.txt**:
   ```cmake
   include(deployment/integrate.cmake)
   setup_qt_deployment(YourAppName)
   ```

3. **Build normally**:
   ```bash
   cmake --build build --config Release
   ```

### Manual Building (from Parent Project)

```bash
# Build for current platform
./deployment/build-parent.sh . YourAppName

# Platform-specific builds
./deployment/build-parent.sh . YourAppName windows
./deployment/build-parent.sh . YourAppName macos monterey
./deployment/build-parent.sh . YourAppName linux ubuntu 22.04
```

## Standalone Usage (Development/Testing)

### Local Build

**Windows:**
```cmd
scripts\windows\build.bat
```

**macOS:**
```bash
./scripts/macos/build.sh monterey    # macOS 12.0+ (Universal)
./scripts/macos/build.sh catalina    # macOS 10.15+ (Intel only)
```

**Linux:**
```bash
./scripts/linux/build.sh ubuntu 22.04
./scripts/linux/build.sh debian bookworm
```

**All Linux distributions:**
```bash
./build-all.sh
```

## Supported Platforms

### macOS Versions
- **macOS Monterey (12.0+)**: Universal Binary (Intel + Apple Silicon)
- **macOS Big Sur (11.0+)**: Universal Binary (Intel + Apple Silicon)
- **macOS Catalina (10.15+)**: Intel only
- **macOS Mojave (10.14+)**: Intel only (requires Qt5)

### Linux Distributions
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **Debian**: Buster, Bullseye, Bookworm, Trixie
- **Fedora**: 37, 38, 39, 40
- **Arch Linux**: Base, LTS

### Windows
- **Windows 10/11**: x64 architecture

## CI/CD

The repository includes GitHub Actions workflows that automatically build for all platforms on:
- Push to main/develop branches
- Pull requests to main
- Release creation

Artifacts are automatically uploaded and attached to releases.

## Customization

1. Update `CMakeLists.txt` with your application details
2. Add your source files to the `src/` directory
3. Add UI files to the `ui/` directory
4. Modify Docker files if you need additional dependencies
5. Update build scripts as needed for your specific requirements