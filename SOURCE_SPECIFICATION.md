# Source Specification Guide

This guide covers the different ways to specify your target sources when using the deployment system.

## Methods Overview

There are two main approaches to specify your application sources:

1. **All-in-one approach**: Use `create_qt_application()` - creates the target and configures deployment
2. **Manual approach**: Create your target manually, then use `setup_qt_deployment()`

## Method 1: All-in-One with `create_qt_application()`

This function creates your Qt application target and configures deployment in one step.

### Basic Example

```cmake
include(deployment/integrate.cmake)

create_qt_application(MyApp
    SOURCES
        src/main.cpp
        src/mainwindow.cpp
        src/dialog.cpp
    HEADERS
        src/mainwindow.h
        src/dialog.h
    BUNDLE_ID "com.company.myapp"
)
```

### Complete Example with All Options

```cmake
create_qt_application(MyApp
    # Source files
    SOURCES
        src/main.cpp
        src/mainwindow.cpp
        src/settingsdialog.cpp
        src/utils.cpp
    
    # Header files
    HEADERS
        src/mainwindow.h
        src/settingsdialog.h
        src/utils.h
    
    # Qt UI files
    UI_FILES
        ui/mainwindow.ui
        ui/settingsdialog.ui
    
    # Resource files
    RESOURCES
        resources/icons.qrc
        resources/translations.qrc
    
    # QML files (for Qt Quick apps)
    QML_FILES
        qml/Main.qml
        qml/components/Button.qml
    
    # Qt modules to link
    QT_MODULES Core Widgets Network Sql
    
    # Additional libraries
    LIBRARIES
        ${CMAKE_CURRENT_SOURCE_DIR}/libs/mylib.a
        OpenSSL::SSL
    
    # Deployment configuration
    BUNDLE_ID "com.company.myapp"
    MACOS_DEPLOYMENT_TARGET "10.15"
    MACOS_ARCHITECTURES "x86_64;arm64"
    ENABLE_DOCKER_BUILD
    ENABLE_CI_CONFIG
)
```

### Application Types

```cmake
# GUI Application (default)
create_qt_application(MyGuiApp
    SOURCES src/main.cpp
    QT_MODULES Core Widgets
)

# Console Application
create_qt_application(MyConsoleApp
    SOURCES src/main.cpp
    QT_MODULES Core
    CONSOLE
    SKIP_MACOS  # Skip macOS bundle for console apps
)

# Windows-specific subsystem
create_qt_application(MyWindowsApp
    SOURCES src/main.cpp
    QT_MODULES Core Widgets
    WIN32  # Force WIN32 subsystem
)
```

### Qt Quick/QML Applications

```cmake
create_qt_application(MyQuickApp
    SOURCES
        src/main.cpp
        src/backend.cpp
    HEADERS
        src/backend.h
    QML_FILES
        qml/Main.qml
        qml/components/CustomButton.qml
        qml/views/SettingsView.qml
    QT_MODULES Core Quick QuickControls2
    BUNDLE_ID "com.company.quickapp"
)
```

## Method 2: Manual Target Creation

Create your target manually using standard CMake/Qt functions, then add deployment.

### Basic Manual Setup

```cmake
include(deployment/integrate.cmake)

# Standard Qt setup
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
qt_standard_project_setup()

# Create target manually
qt_add_executable(MyApp
    src/main.cpp
    src/mainwindow.cpp
    src/mainwindow.h
)

# Add UI files
qt_add_resources(MyApp "ui_resources"
    FILES ui/mainwindow.ui
)

# Link libraries
target_link_libraries(MyApp Qt6::Core Qt6::Widgets)

# Add deployment
setup_qt_deployment(MyApp
    BUNDLE_ID "com.company.myapp"
    ENABLE_DOCKER_BUILD
)
```

### Advanced Manual Setup

```cmake
include(deployment/integrate.cmake)

# Qt setup
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Network)
qt_standard_project_setup()

# Collect source files
set(SOURCES
    src/main.cpp
    src/application.cpp
    src/network/client.cpp
    src/widgets/mainwindow.cpp
)

set(HEADERS
    src/application.h
    src/network/client.h
    src/widgets/mainwindow.h
)

# Create executable
qt_add_executable(MyApp ${SOURCES} ${HEADERS})

# Add resources
qt_add_resources(MyApp "app_resources"
    PREFIX "/"
    FILES
        resources/icons/app.png
        resources/config/default.json
)

# Set up includes
target_include_directories(MyApp PRIVATE src)

# Link libraries
target_link_libraries(MyApp 
    Qt6::Core 
    Qt6::Widgets 
    Qt6::Network
    ${CMAKE_CURRENT_SOURCE_DIR}/third-party/lib/mylib.a
)

# Configure deployment
setup_qt_deployment(MyApp
    BUNDLE_ID "com.company.myapp"
    MACOS_DEPLOYMENT_TARGET "11.0"
    ENABLE_DOCKER_BUILD
    ENABLE_CI_CONFIG
)
```

## Source File Organization

### Recommended Directory Structure

```
YourProject/
├── CMakeLists.txt
├── deployment/              # Submodule
├── src/
│   ├── main.cpp
│   ├── application.h
│   ├── application.cpp
│   ├── widgets/
│   │   ├── mainwindow.h
│   │   └── mainwindow.cpp
│   └── utils/
│       ├── helper.h
│       └── helper.cpp
├── ui/
│   ├── mainwindow.ui
│   └── dialogs/
│       └── settings.ui
├── qml/                     # For Qt Quick apps
│   ├── Main.qml
│   └── components/
│       └── Button.qml
├── resources/
│   ├── icons.qrc
│   ├── translations.qrc
│   └── assets/
│       ├── icon.png
│       └── logo.svg
└── libs/                    # Third-party libraries
    └── mylib.a
```

### Using Glob Patterns (Advanced)

```cmake
# Collect sources using glob (use with caution)
file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "src/*.h")
file(GLOB UI_FILES "ui/*.ui")

create_qt_application(MyApp
    SOURCES ${SOURCES}
    HEADERS ${HEADERS}
    UI_FILES ${UI_FILES}
    QT_MODULES Core Widgets
)
```

**Note**: Glob patterns are convenient but not recommended for production as CMake won't automatically reconfigure when files are added/removed.

## Resource Handling

### Qt Resource Files (.qrc)

```cmake
create_qt_application(MyApp
    SOURCES src/main.cpp
    RESOURCES
        resources/icons.qrc      # Will be compiled into binary
        resources/translations.qrc
    QT_MODULES Core Widgets
)
```

### Individual Resource Files

```cmake
create_qt_application(MyApp
    SOURCES src/main.cpp
    RESOURCES
        resources/icon.png       # Individual files
        resources/config.json
        resources/stylesheet.css
    QT_MODULES Core Widgets
)
```

## Platform-Specific Sources

```cmake
set(COMMON_SOURCES
    src/main.cpp
    src/application.cpp
)

set(PLATFORM_SOURCES)

if(WIN32)
    list(APPEND PLATFORM_SOURCES src/platform/windows.cpp)
elseif(APPLE)
    list(APPEND PLATFORM_SOURCES src/platform/macos.mm)
elseif(UNIX)
    list(APPEND PLATFORM_SOURCES src/platform/linux.cpp)
endif()

create_qt_application(MyApp
    SOURCES ${COMMON_SOURCES} ${PLATFORM_SOURCES}
    QT_MODULES Core Widgets
)
```

## Multiple Targets

```cmake
# Main application
create_qt_application(MyMainApp
    SOURCES src/main/main.cpp src/main/window.cpp
    QT_MODULES Core Widgets
    BUNDLE_ID "com.company.mainapp"
)

# Utility application
create_qt_application(MyUtility
    SOURCES src/utility/main.cpp src/utility/processor.cpp
    QT_MODULES Core
    CONSOLE
    BUNDLE_ID "com.company.utility"
)

# Test application
create_qt_application(MyTests
    SOURCES src/tests/main.cpp src/tests/testcase.cpp
    QT_MODULES Core Test
    CONSOLE
    SKIP_MACOS
    SKIP_WINDOWS
)
```

## Best Practices

1. **Use explicit file lists** instead of glob patterns for better build reliability
2. **Organize sources** in logical directory structures
3. **Separate platform-specific code** when necessary
4. **Use consistent naming** for your targets and bundle IDs
5. **Group related UI files** in subdirectories
6. **Keep resources organized** in dedicated directories
7. **Document your source structure** in your project README

## Troubleshooting

### Common Issues

**Missing source files**:
```cmake
# Make sure all source files exist
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
    message(FATAL_ERROR "main.cpp not found!")
endif()
```

**Qt modules not found**:
```cmake
# Check Qt installation
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
if(NOT Qt6_FOUND)
    message(FATAL_ERROR "Qt6 not found!")
endif()
```

**Resource files not found**:
```cmake
# Verify resource files exist
foreach(resource_file ${RESOURCE_FILES})
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${resource_file}")
        message(WARNING "Resource file not found: ${resource_file}")
    endif()
endforeach()
```