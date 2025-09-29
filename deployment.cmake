# Qt Application Deployment CMake Module
# This module provides functions to configure cross-platform Qt application deployment

# Function to create and configure Qt application with deployment
function(qt_create_application TARGET_NAME)
    set(options WIN32 CONSOLE MACOS_BUNDLE)
    set(oneValueArgs 
        MACOS_DEPLOYMENT_TARGET 
        MACOS_ARCHITECTURES 
        MACOS_BUNDLE_ID
        MACOS_INFO_PLIST
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
        MACOS_FRAMEWORKS 
        WINDOWS_LIBRARIES
    )
    
    cmake_parse_arguments(APP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Set default Qt modules if none specified
    if(NOT APP_QT_MODULES)
        set(APP_QT_MODULES Core Widgets)
    endif()

    # Find Qt packages
    find_package(Qt6 REQUIRED COMPONENTS ${APP_QT_MODULES})
    
    # Ensure qt_standard_project_setup is called
    if(COMMAND qt_standard_project_setup)
        qt_standard_project_setup()
    endif()

    # Create the executable target
    if(APP_QML_FILES)
        qt_add_executable(${TARGET_NAME} ${APP_SOURCES} ${APP_HEADERS})
        qt_add_qml_module(${TARGET_NAME}
            URI ${TARGET_NAME}
            VERSION 1.0
            QML_FILES ${APP_QML_FILES}
        )
    else()
        qt_add_executable(${TARGET_NAME} ${APP_SOURCES} ${APP_HEADERS})
    endif()

    # Add UI files if specified
    if(APP_UI_FILES)
        qt_add_resources(${TARGET_NAME} "ui_resources"
            FILES ${APP_UI_FILES}
        )
    endif()

    # Add resources if specified
    if(APP_RESOURCES)
        qt_add_resources(${TARGET_NAME} "app_resources"
            PREFIX "/"
            FILES ${APP_RESOURCES}
        )
    endif()

    # Link Qt modules
    foreach(module ${APP_QT_MODULES})
        target_link_libraries(${TARGET_NAME} Qt6::${module})
    endforeach()

    # Link additional libraries
    if(APP_LIBRARIES)
        target_link_libraries(${TARGET_NAME} ${APP_LIBRARIES})
    endif()

    # Apply deployment configuration
    qt_deploy_application(${TARGET_NAME}
        ${APP_MACOS_DEPLOYMENT_TARGET:+MACOS_DEPLOYMENT_TARGET ${APP_MACOS_DEPLOYMENT_TARGET}}
        ${APP_MACOS_ARCHITECTURES:+MACOS_ARCHITECTURES ${APP_MACOS_ARCHITECTURES}}
        ${APP_MACOS_BUNDLE_ID:+MACOS_BUNDLE_ID ${APP_MACOS_BUNDLE_ID}}
        ${APP_MACOS_INFO_PLIST:+MACOS_INFO_PLIST ${APP_MACOS_INFO_PLIST}}
        ${APP_WINDOWS_SUBSYSTEM:+WINDOWS_SUBSYSTEM ${APP_WINDOWS_SUBSYSTEM}}
        ${APP_MACOS_FRAMEWORKS:+MACOS_FRAMEWORKS ${APP_MACOS_FRAMEWORKS}}
        ${APP_WINDOWS_LIBRARIES:+WINDOWS_LIBRARIES ${APP_WINDOWS_LIBRARIES}}
    )
endfunction()

# Function to configure Qt application deployment (for existing targets)
function(qt_deploy_application TARGET_NAME)
    set(options SKIP_MACOS SKIP_WINDOWS SKIP_LINUX)
    set(oneValueArgs 
        MACOS_DEPLOYMENT_TARGET 
        MACOS_ARCHITECTURES 
        MACOS_BUNDLE_ID
        MACOS_INFO_PLIST
        WINDOWS_SUBSYSTEM
    )
    set(multiValueArgs MACOS_FRAMEWORKS WINDOWS_LIBRARIES)
    
    cmake_parse_arguments(DEPLOY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Set default values
    if(NOT DEPLOY_MACOS_DEPLOYMENT_TARGET)
        set(DEPLOY_MACOS_DEPLOYMENT_TARGET "10.15")
    endif()
    
    if(NOT DEPLOY_MACOS_ARCHITECTURES)
        set(DEPLOY_MACOS_ARCHITECTURES "x86_64;arm64")
    endif()
    
    if(NOT DEPLOY_MACOS_BUNDLE_ID)
        set(DEPLOY_MACOS_BUNDLE_ID "com.example.${TARGET_NAME}")
    endif()

    # Windows Configuration
    if(WIN32 AND NOT DEPLOY_SKIP_WINDOWS)
        if(NOT DEPLOY_WINDOWS_SUBSYSTEM)
            set(DEPLOY_WINDOWS_SUBSYSTEM WIN32)
        endif()
        
        set_target_properties(${TARGET_NAME} PROPERTIES
            ${DEPLOY_WINDOWS_SUBSYSTEM}_EXECUTABLE TRUE
        )
        
        qt_generate_deploy_app_script(
            TARGET ${TARGET_NAME}
            FILENAME_VARIABLE deploy_script
            NO_UNSUPPORTED_PLATFORM_ERROR
        )
        install(SCRIPT ${deploy_script})
    endif()

    # macOS Configuration
    if(APPLE AND NOT DEPLOY_SKIP_MACOS)
        # Set deployment target and architectures
        set(CMAKE_OSX_DEPLOYMENT_TARGET ${DEPLOY_MACOS_DEPLOYMENT_TARGET} PARENT_SCOPE)
        set(CMAKE_OSX_ARCHITECTURES ${DEPLOY_MACOS_ARCHITECTURES} PARENT_SCOPE)
        
        # Configure bundle properties
        set_target_properties(${TARGET_NAME} PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_GUI_IDENTIFIER ${DEPLOY_MACOS_BUNDLE_ID}
            MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
            MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
            XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET ${DEPLOY_MACOS_DEPLOYMENT_TARGET}
        )
        
        # Use custom Info.plist if provided
        if(DEPLOY_MACOS_INFO_PLIST AND EXISTS ${DEPLOY_MACOS_INFO_PLIST})
            set_target_properties(${TARGET_NAME} PROPERTIES
                MACOSX_BUNDLE_INFO_PLIST ${DEPLOY_MACOS_INFO_PLIST}
            )
        endif()
        
        qt_generate_deploy_app_script(
            TARGET ${TARGET_NAME}
            FILENAME_VARIABLE deploy_script
            NO_UNSUPPORTED_PLATFORM_ERROR
        )
        install(SCRIPT ${deploy_script})
        
        # Code signing (optional)
        if(CMAKE_BUILD_TYPE STREQUAL "Release" AND DEFINED ENV{APPLE_DEVELOPER_ID})
            set_target_properties(${TARGET_NAME} PROPERTIES
                XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Developer ID Application: $ENV{APPLE_DEVELOPER_ID}"
                XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Manual"
            )
        endif()
    endif()

    # Linux Configuration
    if(UNIX AND NOT APPLE AND NOT DEPLOY_SKIP_LINUX)
        install(TARGETS ${TARGET_NAME}
            BUNDLE DESTINATION .
            RUNTIME DESTINATION bin
        )
        
        qt_generate_deploy_app_script(
            TARGET ${TARGET_NAME}
            FILENAME_VARIABLE deploy_script
            NO_UNSUPPORTED_PLATFORM_ERROR
        )
        install(SCRIPT ${deploy_script})
    endif()
endfunction()

# Function to add deployment scripts to target
function(qt_add_deployment_scripts TARGET_NAME)
    set(DEPLOYMENT_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR})
    
    # Copy deployment scripts to build directory
    configure_file(
        ${DEPLOYMENT_DIR}/scripts/windows/build.bat
        ${CMAKE_BINARY_DIR}/deploy/windows/build.bat
        COPYONLY
    )
    
    configure_file(
        ${DEPLOYMENT_DIR}/scripts/macos/build.sh
        ${CMAKE_BINARY_DIR}/deploy/macos/build.sh
        COPYONLY
    )
    
    configure_file(
        ${DEPLOYMENT_DIR}/scripts/linux/build.sh
        ${CMAKE_BINARY_DIR}/deploy/linux/build.sh
        COPYONLY
    )
    
    # Make scripts executable on Unix systems
    if(UNIX)
        file(CHMOD ${CMAKE_BINARY_DIR}/deploy/macos/build.sh
             PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
        file(CHMOD ${CMAKE_BINARY_DIR}/deploy/linux/build.sh
             PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    endif()
endfunction()

# Function to setup Docker deployment for Linux
function(qt_setup_docker_deployment TARGET_NAME)
    set(DEPLOYMENT_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR})
    
    # Copy Docker files to project root or build directory
    file(COPY ${DEPLOYMENT_DIR}/docker DESTINATION ${CMAKE_BINARY_DIR}/deploy/)
    file(COPY ${DEPLOYMENT_DIR}/build-all.sh DESTINATION ${CMAKE_BINARY_DIR}/deploy/)
    
    # Make build script executable
    if(UNIX)
        file(CHMOD ${CMAKE_BINARY_DIR}/deploy/build-all.sh
             PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    endif()
endfunction()

# Function to create deployment package
function(qt_create_deployment_package TARGET_NAME)
    set(options CREATE_DOCKER_FILES CREATE_CI_CONFIG)
    set(oneValueArgs PACKAGE_NAME)
    set(multiValueArgs)
    
    cmake_parse_arguments(PACKAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT PACKAGE_NAME)
        set(PACKAGE_NAME ${TARGET_NAME})
    endif()
    
    # Add deployment scripts
    qt_add_deployment_scripts(${TARGET_NAME})
    
    # Add Docker files if requested
    if(PACKAGE_CREATE_DOCKER_FILES)
        qt_setup_docker_deployment(${TARGET_NAME})
    endif()
    
    # Copy CI configuration if requested
    if(PACKAGE_CREATE_CI_CONFIG)
        set(DEPLOYMENT_DIR ${CMAKE_CURRENT_FUNCTION_LIST_DIR})
        file(COPY ${DEPLOYMENT_DIR}/.github DESTINATION ${CMAKE_SOURCE_DIR}/)
    endif()
endfunction()