# Simple Integration Example

This example shows how to integrate the deployment system into a basic Qt application.

## Setup

1. **Add deployment as submodule** (from your project root):
   ```bash
   git submodule add <deployment-repo-url> deployment
   ```

2. **Copy this example** to your project or use as reference:
   ```bash
   cp -r deployment/examples/simple-integration/* .
   ```

3. **Build your application**:
   ```bash
   mkdir build && cd build
   cmake ..
   cmake --build . --config Release
   ```

## What This Example Includes

- Basic CMakeLists.txt with deployment integration
- Cross-platform build configuration
- Universal macOS binary support
- Docker-based Linux builds
- CI/CD workflow generation

## Customization

Modify the `setup_qt_deployment()` call in CMakeLists.txt:

```cmake
setup_qt_deployment(MyQtApplication
    BUNDLE_ID "com.yourcompany.yourapp"     # Your app bundle ID
    MACOS_DEPLOYMENT_TARGET "11.0"          # Require macOS 11.0+
    SKIP_LINUX                              # Don't build for Linux
)
```

## Platform-Specific Builds

```bash
# Build for specific platforms using the deployment scripts
./deployment/build-parent.sh . MyQtApplication macos monterey
./deployment/build-parent.sh . MyQtApplication linux ubuntu 22.04
./deployment/build-parent.sh . MyQtApplication windows
```

## CI/CD

The example includes automatic CI/CD setup. After building once with `ENABLE_CI_CONFIG`, you'll have:

- `.github/workflows/parent-build.yml` - GitHub Actions workflow
- `build/deploy/` - Deployment scripts and Docker files

Commit these to enable automatic builds on push/release.