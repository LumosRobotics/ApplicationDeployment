# Example CMakeLists.txt for parent project using deployment submodule

cmake_minimum_required(VERSION 3.20)
project(MyQtApplication VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include deployment integration (assuming submodule in 'deployment' directory)
include(deployment/integrate.cmake)

# Method 1: Create application with sources using deployment system
create_qt_application(MyQtApplication
    SOURCES
        src/main.cpp
        src/mainwindow.cpp
    HEADERS
        src/mainwindow.h
    UI_FILES
        ui/mainwindow.ui
    RESOURCES
        resources/icons.qrc
    QT_MODULES Core Widgets
    BUNDLE_ID "com.example.myqtapp"
    MACOS_DEPLOYMENT_TARGET "10.15"
    ENABLE_DOCKER_BUILD
    ENABLE_CI_CONFIG
)

# Method 2: Alternative - Create target manually then setup deployment
# Uncomment this section if you prefer manual target creation:

# find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
# qt_standard_project_setup()
# 
# qt_add_executable(MyQtApplication
#     src/main.cpp
#     src/mainwindow.cpp
#     src/mainwindow.h
# )
# 
# target_link_libraries(MyQtApplication Qt6::Core Qt6::Widgets)
# 
# setup_qt_deployment(MyQtApplication
#     BUNDLE_ID "com.example.myqtapp"
#     MACOS_DEPLOYMENT_TARGET "10.15"
#     ENABLE_DOCKER_BUILD
#     ENABLE_CI_CONFIG
# )