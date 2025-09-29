# Advanced Integration Example - Multiple applications and configurations

cmake_minimum_required(VERSION 3.20)
project(MyQtProject VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(deployment/integrate.cmake)

# Example 1: Qt Widgets Application
create_qt_application(MyWidgetsApp
    SOURCES
        src/widgets/main.cpp
        src/widgets/mainwindow.cpp
        src/widgets/settingsdialog.cpp
    HEADERS
        src/widgets/mainwindow.h
        src/widgets/settingsdialog.h
    UI_FILES
        ui/mainwindow.ui
        ui/settingsdialog.ui
    RESOURCES
        resources/widgets.qrc
    QT_MODULES Core Widgets
    BUNDLE_ID "com.example.widgetsapp"
    MACOS_DEPLOYMENT_TARGET "10.15"
    ENABLE_DOCKER_BUILD
)

# Example 2: Qt Quick/QML Application
create_qt_application(MyQuickApp
    SOURCES
        src/quick/main.cpp
        src/quick/backend.cpp
    HEADERS
        src/quick/backend.h
    QML_FILES
        qml/Main.qml
        qml/components/CustomButton.qml
    RESOURCES
        resources/quick.qrc
    QT_MODULES Core Quick QuickControls2
    BUNDLE_ID "com.example.quickapp"
    MACOS_DEPLOYMENT_TARGET "11.0"  # Require newer macOS for Quick
    MACOS_ARCHITECTURES "x86_64;arm64"
    ENABLE_CI_CONFIG
)

# Example 3: Console Application (no GUI)
create_qt_application(MyConsoleApp
    SOURCES
        src/console/main.cpp
        src/console/processor.cpp
    HEADERS
        src/console/processor.h
    QT_MODULES Core Network
    CONSOLE  # Mark as console application
    BUNDLE_ID "com.example.consoleapp"
    SKIP_MACOS  # Skip macOS bundle creation for console app
)

# Example 4: Application with custom libraries
create_qt_application(MyAdvancedApp
    SOURCES
        src/advanced/main.cpp
        src/advanced/application.cpp
    HEADERS
        src/advanced/application.h
    LIBRARIES
        ${CMAKE_CURRENT_SOURCE_DIR}/libs/mylib.a
        # Add other custom libraries
    QT_MODULES Core Widgets Network Sql
    BUNDLE_ID "com.example.advancedapp"
    MACOS_DEPLOYMENT_TARGET "10.15"
    ENABLE_DOCKER_BUILD
    ENABLE_CI_CONFIG
)

# Example 5: Existing target with manual deployment setup
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
qt_standard_project_setup()

qt_add_executable(MyCustomApp
    src/custom/main.cpp
    src/custom/customwidget.cpp
)

target_link_libraries(MyCustomApp Qt6::Core Qt6::Widgets)

# Add deployment to existing target
setup_qt_deployment(MyCustomApp
    BUNDLE_ID "com.example.customapp"
    MACOS_DEPLOYMENT_TARGET "12.0"  # Monterey+ only
    SKIP_LINUX  # Don't build for Linux
)