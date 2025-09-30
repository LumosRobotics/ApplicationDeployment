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
        CREATE_DMG
    )
    set(oneValueArgs 
        BUNDLE_ID
        MACOS_DEPLOYMENT_TARGET
        MACOS_ARCHITECTURES
        WINDOWS_SUBSYSTEM
        DMG_BACKGROUND
        DMG_ICON
        DMG_VOLNAME
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
    set(QT_CREATE_OPTIONS)
    if(CREATE_SOURCES)
        list(APPEND QT_CREATE_OPTIONS SOURCES ${CREATE_SOURCES})
    endif()
    if(CREATE_HEADERS)
        list(APPEND QT_CREATE_OPTIONS HEADERS ${CREATE_HEADERS})
    endif()
    if(CREATE_UI_FILES)
        list(APPEND QT_CREATE_OPTIONS UI_FILES ${CREATE_UI_FILES})
    endif()
    if(CREATE_RESOURCES)
        list(APPEND QT_CREATE_OPTIONS RESOURCES ${CREATE_RESOURCES})
    endif()
    if(CREATE_QML_FILES)
        list(APPEND QT_CREATE_OPTIONS QML_FILES ${CREATE_QML_FILES})
    endif()
    if(CREATE_LIBRARIES)
        list(APPEND QT_CREATE_OPTIONS LIBRARIES ${CREATE_LIBRARIES})
    endif()
    if(CREATE_QT_MODULES)
        list(APPEND QT_CREATE_OPTIONS QT_MODULES ${CREATE_QT_MODULES})
    endif()
    if(CREATE_BUNDLE_ID)
        list(APPEND QT_CREATE_OPTIONS MACOS_BUNDLE_ID ${CREATE_BUNDLE_ID})
    endif()
    if(CREATE_MACOS_DEPLOYMENT_TARGET)
        list(APPEND QT_CREATE_OPTIONS MACOS_DEPLOYMENT_TARGET ${CREATE_MACOS_DEPLOYMENT_TARGET})
    endif()
    if(CREATE_MACOS_ARCHITECTURES)
        list(APPEND QT_CREATE_OPTIONS MACOS_ARCHITECTURES ${CREATE_MACOS_ARCHITECTURES})
    endif()
    if(CREATE_WINDOWS_SUBSYSTEM)
        list(APPEND QT_CREATE_OPTIONS WINDOWS_SUBSYSTEM ${CREATE_WINDOWS_SUBSYSTEM})
    endif()
    if(CREATE_DMG_BACKGROUND)
        list(APPEND QT_CREATE_OPTIONS DMG_BACKGROUND ${CREATE_DMG_BACKGROUND})
    endif()
    if(CREATE_DMG_ICON)
        list(APPEND QT_CREATE_OPTIONS DMG_ICON ${CREATE_DMG_ICON})
    endif()
    if(CREATE_CREATE_DMG)
        list(APPEND QT_CREATE_OPTIONS CREATE_DMG)
    endif()
    if(CREATE_WIN32)
        list(APPEND QT_CREATE_OPTIONS WIN32)
    endif()
    if(CREATE_CONSOLE)
        list(APPEND QT_CREATE_OPTIONS CONSOLE)
    endif()
    
    qt_create_application(${TARGET_NAME} ${QT_CREATE_OPTIONS})
    
    # Create deployment package
    set(PACKAGE_OPTIONS)
    if(CREATE_ENABLE_DOCKER_BUILD)
        list(APPEND PACKAGE_OPTIONS CREATE_DOCKER_FILES)
    endif()
    if(CREATE_ENABLE_CI_CONFIG)
        list(APPEND PACKAGE_OPTIONS CREATE_CI_CONFIG)
    endif()
    
    qt_create_deployment_package(${TARGET_NAME} ${PACKAGE_OPTIONS})
    
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
        CREATE_DMG
    )
    set(oneValueArgs 
        BUNDLE_ID
        MACOS_DEPLOYMENT_TARGET
        MACOS_ARCHITECTURES
        WINDOWS_SUBSYSTEM
        DMG_BACKGROUND
        DMG_ICON
        DMG_VOLNAME
    )
    set(multiValueArgs)
    
    cmake_parse_arguments(SETUP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # Apply deployment configuration
    set(DEPLOY_OPTIONS)
    if(SETUP_SKIP_MACOS)
        list(APPEND DEPLOY_OPTIONS SKIP_MACOS)
    endif()
    if(SETUP_SKIP_WINDOWS)
        list(APPEND DEPLOY_OPTIONS SKIP_WINDOWS)
    endif()
    if(SETUP_SKIP_LINUX)
        list(APPEND DEPLOY_OPTIONS SKIP_LINUX)
    endif()
    if(SETUP_BUNDLE_ID)
        list(APPEND DEPLOY_OPTIONS MACOS_BUNDLE_ID ${SETUP_BUNDLE_ID})
    endif()
    if(SETUP_MACOS_DEPLOYMENT_TARGET)
        list(APPEND DEPLOY_OPTIONS MACOS_DEPLOYMENT_TARGET ${SETUP_MACOS_DEPLOYMENT_TARGET})
    endif()
    if(SETUP_MACOS_ARCHITECTURES)
        list(APPEND DEPLOY_OPTIONS MACOS_ARCHITECTURES ${SETUP_MACOS_ARCHITECTURES})
    endif()
    if(SETUP_WINDOWS_SUBSYSTEM)
        list(APPEND DEPLOY_OPTIONS WINDOWS_SUBSYSTEM ${SETUP_WINDOWS_SUBSYSTEM})
    endif()
    if(SETUP_DMG_BACKGROUND)
        list(APPEND DEPLOY_OPTIONS DMG_BACKGROUND ${SETUP_DMG_BACKGROUND})
    endif()
    if(SETUP_DMG_ICON)
        list(APPEND DEPLOY_OPTIONS DMG_ICON ${SETUP_DMG_ICON})
    endif()
    if(SETUP_CREATE_DMG)
        list(APPEND DEPLOY_OPTIONS CREATE_DMG)
    endif()
    
    qt_deploy_application(${TARGET_NAME} ${DEPLOY_OPTIONS})
    
    # Create deployment package
    set(SETUP_PACKAGE_OPTIONS)
    if(SETUP_ENABLE_DOCKER_BUILD)
        list(APPEND SETUP_PACKAGE_OPTIONS CREATE_DOCKER_FILES)
    endif()
    if(SETUP_ENABLE_CI_CONFIG)
        list(APPEND SETUP_PACKAGE_OPTIONS CREATE_CI_CONFIG)
    endif()
    
    qt_create_deployment_package(${TARGET_NAME} ${SETUP_PACKAGE_OPTIONS})
    
    message(STATUS "Deployment configured for target: ${TARGET_NAME}")
endfunction()