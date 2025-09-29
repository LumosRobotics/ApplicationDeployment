# Integration script for parent CMake projects
# Include this file in your main CMakeLists.txt to integrate deployment

# Add the deployment submodule directory
if(NOT DEPLOYMENT_SUBMODULE_DIR)
    set(DEPLOYMENT_SUBMODULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/deployment" 
        CACHE STRING "Path to deployment submodule")
endif()

if(EXISTS "${DEPLOYMENT_SUBMODULE_DIR}/deployment.cmake")
    include("${DEPLOYMENT_SUBMODULE_DIR}/deployment.cmake")
    message(STATUS "Qt Deployment integration loaded from: ${DEPLOYMENT_SUBMODULE_DIR}")
else()
    message(WARNING "Qt Deployment submodule not found at: ${DEPLOYMENT_SUBMODULE_DIR}")
    message(WARNING "Make sure you have added this repository as a submodule named 'deployment'")
endif()

# Convenience function to create Qt application with deployment
function(create_qt_application TARGET_NAME)
    set(options 
        ENABLE_DOCKER_BUILD 
        ENABLE_CI_CONFIG 
        SKIP_MACOS 
        SKIP_WINDOWS 
        SKIP_LINUX
        WIN32
        CONSOLE
    )
    set(oneValueArgs 
        BUNDLE_ID
        MACOS_DEPLOYMENT_TARGET
        MACOS_ARCHITECTURES
        WINDOWS_SUBSYSTEM
    )
    set(multiValueArgs 
        SOURCES 
        HEADERS 
        UI_FILES 
        RESOURCES 
        QML_FILES
        LIBRARIES
        QT_MODULES
    )
    
    cmake_parse_arguments(CREATE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # Create the application with sources
    qt_create_application(${TARGET_NAME}
        ${CREATE_SOURCES:+SOURCES ${CREATE_SOURCES}}
        ${CREATE_HEADERS:+HEADERS ${CREATE_HEADERS}}
        ${CREATE_UI_FILES:+UI_FILES ${CREATE_UI_FILES}}
        ${CREATE_RESOURCES:+RESOURCES ${CREATE_RESOURCES}}
        ${CREATE_QML_FILES:+QML_FILES ${CREATE_QML_FILES}}
        ${CREATE_LIBRARIES:+LIBRARIES ${CREATE_LIBRARIES}}
        ${CREATE_QT_MODULES:+QT_MODULES ${CREATE_QT_MODULES}}
        ${CREATE_BUNDLE_ID:+MACOS_BUNDLE_ID ${CREATE_BUNDLE_ID}}
        ${CREATE_MACOS_DEPLOYMENT_TARGET:+MACOS_DEPLOYMENT_TARGET ${CREATE_MACOS_DEPLOYMENT_TARGET}}
        ${CREATE_MACOS_ARCHITECTURES:+MACOS_ARCHITECTURES ${CREATE_MACOS_ARCHITECTURES}}
        ${CREATE_WINDOWS_SUBSYSTEM:+WINDOWS_SUBSYSTEM ${CREATE_WINDOWS_SUBSYSTEM}}
        ${CREATE_WIN32:+WIN32}
        ${CREATE_CONSOLE:+CONSOLE}
    )
    
    # Create deployment package
    qt_create_deployment_package(${TARGET_NAME}
        ${CREATE_ENABLE_DOCKER_BUILD:+CREATE_DOCKER_FILES}
        ${CREATE_ENABLE_CI_CONFIG:+CREATE_CI_CONFIG}
    )
    
    message(STATUS "Qt application created and deployment configured for: ${TARGET_NAME}")
endfunction()

# Convenience function to setup deployment for existing application
function(setup_qt_deployment TARGET_NAME)
    set(options 
        ENABLE_DOCKER_BUILD 
        ENABLE_CI_CONFIG 
        SKIP_MACOS 
        SKIP_WINDOWS 
        SKIP_LINUX
    )
    set(oneValueArgs 
        BUNDLE_ID
        MACOS_DEPLOYMENT_TARGET
        MACOS_ARCHITECTURES
        WINDOWS_SUBSYSTEM
    )
    set(multiValueArgs)
    
    cmake_parse_arguments(SETUP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # Apply deployment configuration
    qt_deploy_application(${TARGET_NAME}
        ${SETUP_SKIP_MACOS:+SKIP_MACOS}
        ${SETUP_SKIP_WINDOWS:+SKIP_WINDOWS}
        ${SETUP_SKIP_LINUX:+SKIP_LINUX}
        ${SETUP_BUNDLE_ID:+MACOS_BUNDLE_ID ${SETUP_BUNDLE_ID}}
        ${SETUP_MACOS_DEPLOYMENT_TARGET:+MACOS_DEPLOYMENT_TARGET ${SETUP_MACOS_DEPLOYMENT_TARGET}}
        ${SETUP_MACOS_ARCHITECTURES:+MACOS_ARCHITECTURES ${SETUP_MACOS_ARCHITECTURES}}
        ${SETUP_WINDOWS_SUBSYSTEM:+WINDOWS_SUBSYSTEM ${SETUP_WINDOWS_SUBSYSTEM}}
    )
    
    # Create deployment package
    qt_create_deployment_package(${TARGET_NAME}
        ${SETUP_ENABLE_DOCKER_BUILD:+CREATE_DOCKER_FILES}
        ${SETUP_ENABLE_CI_CONFIG:+CREATE_CI_CONFIG}
    )
    
    message(STATUS "Deployment configured for target: ${TARGET_NAME}")
endfunction()