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
        target_link_libraries(${TARGET_NAME} PRIVATE Qt6::${module})
    endforeach()

    # Link additional libraries
    if(APP_LIBRARIES)
        target_link_libraries(${TARGET_NAME} PRIVATE ${APP_LIBRARIES})
    endif()

    # Apply deployment configuration
    set(APP_DEPLOY_OPTIONS)
    if(APP_MACOS_DEPLOYMENT_TARGET)
        list(APPEND APP_DEPLOY_OPTIONS MACOS_DEPLOYMENT_TARGET ${APP_MACOS_DEPLOYMENT_TARGET})
    endif()
    if(APP_MACOS_ARCHITECTURES)
        list(APPEND APP_DEPLOY_OPTIONS MACOS_ARCHITECTURES ${APP_MACOS_ARCHITECTURES})
    endif()
    if(APP_MACOS_BUNDLE_ID)
        list(APPEND APP_DEPLOY_OPTIONS MACOS_BUNDLE_ID ${APP_MACOS_BUNDLE_ID})
    endif()
    if(APP_MACOS_INFO_PLIST)
        list(APPEND APP_DEPLOY_OPTIONS MACOS_INFO_PLIST ${APP_MACOS_INFO_PLIST})
    endif()
    if(APP_WINDOWS_SUBSYSTEM)
        list(APPEND APP_DEPLOY_OPTIONS WINDOWS_SUBSYSTEM ${APP_WINDOWS_SUBSYSTEM})
    endif()
    if(APP_MACOS_FRAMEWORKS)
        list(APPEND APP_DEPLOY_OPTIONS MACOS_FRAMEWORKS ${APP_MACOS_FRAMEWORKS})
    endif()
    if(APP_WINDOWS_LIBRARIES)
        list(APPEND APP_DEPLOY_OPTIONS WINDOWS_LIBRARIES ${APP_WINDOWS_LIBRARIES})
    endif()
    
    qt_deploy_application(${TARGET_NAME} ${APP_DEPLOY_OPTIONS})
endfunction()

# Function to configure Qt application deployment (for existing targets)
function(qt_deploy_application TARGET_NAME)
    set(options SKIP_MACOS SKIP_WINDOWS SKIP_LINUX CREATE_DMG)
    set(oneValueArgs 
        MACOS_DEPLOYMENT_TARGET 
        MACOS_ARCHITECTURES 
        MACOS_BUNDLE_ID
        MACOS_INFO_PLIST
        WINDOWS_SUBSYSTEM
        DMG_BACKGROUND
        DMG_ICON
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
        
        # Configure final output directory for deployment artifacts
        # When used as submodule, output to parent's Release/MacOS folder
        if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
            set(MACOS_FINAL_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/Release/MacOS")
        else()
            # When used standalone, output to repo root Release/MacOS
            set(MACOS_FINAL_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/Release/MacOS")
        endif()
        
        # Create final output directory
        file(MAKE_DIRECTORY ${MACOS_FINAL_OUTPUT_DIR})
        
        # Configure bundle properties (build artifacts stay in build directory)
        set_target_properties(${TARGET_NAME} PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_GUI_IDENTIFIER ${DEPLOY_MACOS_BUNDLE_ID}
            MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
            MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
            XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET ${DEPLOY_MACOS_DEPLOYMENT_TARGET}
        )
        
        # Add custom post-build step to copy final artifacts to Release/MacOS
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "${MACOS_FINAL_OUTPUT_DIR}"
            COMMAND ${CMAKE_COMMAND} -E copy_directory 
                "$<TARGET_BUNDLE_DIR:${TARGET_NAME}>" 
                "${MACOS_FINAL_OUTPUT_DIR}/${TARGET_NAME}.app"
            COMMENT "Copying ${TARGET_NAME}.app to Release/MacOS/"
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
        
        # Add DMG creation post-build step if requested
        if(DEPLOY_CREATE_DMG)
            set(DMG_OPTIONS)
            if(DEPLOY_DMG_BACKGROUND)
                list(APPEND DMG_OPTIONS BACKGROUND ${DEPLOY_DMG_BACKGROUND})
            endif()
            if(DEPLOY_DMG_ICON)
                list(APPEND DMG_OPTIONS ICON ${DEPLOY_DMG_ICON})
            endif()
            # Pass the final output directory to DMG creation
            list(APPEND DMG_OPTIONS OUTPUT_DIR ${MACOS_FINAL_OUTPUT_DIR})
            qt_add_dmg_creation(${TARGET_NAME} ${DMG_OPTIONS})
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

# Function to add DMG creation post-build step
function(qt_add_dmg_creation TARGET_NAME)
    set(options)
    set(oneValueArgs BACKGROUND ICON VOLNAME OUTPUT_DIR)
    set(multiValueArgs)
    
    cmake_parse_arguments(DMG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(NOT DMG_VOLNAME)
        set(DMG_VOLNAME ${TARGET_NAME})
    endif()
    
    # Set output directory - use provided OUTPUT_DIR or fallback to binary dir
    if(DMG_OUTPUT_DIR)
        set(OUTPUT_DIR ${DMG_OUTPUT_DIR})
    else()
        set(OUTPUT_DIR ${CMAKE_BINARY_DIR})
    endif()
    
    # Only add on macOS
    if(APPLE)
        # Create a script for DMG creation
        set(DMG_SCRIPT "${CMAKE_BINARY_DIR}/create_dmg_${TARGET_NAME}.sh")
        
        file(WRITE ${DMG_SCRIPT} "#!/bin/bash\n")
        file(APPEND ${DMG_SCRIPT} "set -e\n\n")
        file(APPEND ${DMG_SCRIPT} "# DMG Creation Script for ${TARGET_NAME}\n")
        file(APPEND ${DMG_SCRIPT} "echo \"Creating DMG package for ${TARGET_NAME}...\"\n\n")
        
        file(APPEND ${DMG_SCRIPT} "# Check if create-dmg is available\n")
        file(APPEND ${DMG_SCRIPT} "if ! command -v create-dmg &> /dev/null; then\n")
        file(APPEND ${DMG_SCRIPT} "    echo \"create-dmg not found. Install with: brew install create-dmg\"\n")
        file(APPEND ${DMG_SCRIPT} "    exit 1\n")
        file(APPEND ${DMG_SCRIPT} "fi\n\n")
        
        file(APPEND ${DMG_SCRIPT} "APP_BUNDLE=\"${TARGET_NAME}.app\"\n")
        file(APPEND ${DMG_SCRIPT} "OUTPUT_DIR=\"${OUTPUT_DIR}\"\n")
        file(APPEND ${DMG_SCRIPT} "BUNDLE_PATH=\"$OUTPUT_DIR/$APP_BUNDLE\"\n\n")
        
        file(APPEND ${DMG_SCRIPT} "if [ ! -d \"$BUNDLE_PATH\" ]; then\n")
        file(APPEND ${DMG_SCRIPT} "    echo \"Error: Application bundle not found at $BUNDLE_PATH\"\n")
        file(APPEND ${DMG_SCRIPT} "    exit 1\n")
        file(APPEND ${DMG_SCRIPT} "fi\n\n")
        
        file(APPEND ${DMG_SCRIPT} "# Determine architecture string\n")
        file(APPEND ${DMG_SCRIPT} "ARCH_INFO=$(lipo -info \"$BUNDLE_PATH/Contents/MacOS/${TARGET_NAME}\" 2>/dev/null || echo \"unknown\")\n")
        file(APPEND ${DMG_SCRIPT} "if [[ \"$ARCH_INFO\" == *\"x86_64\"* && \"$ARCH_INFO\" == *\"arm64\"* ]]; then\n")
        file(APPEND ${DMG_SCRIPT} "    ARCH_STRING=\"universal\"\n")
        file(APPEND ${DMG_SCRIPT} "elif [[ \"$ARCH_INFO\" == *\"arm64\"* ]]; then\n")
        file(APPEND ${DMG_SCRIPT} "    ARCH_STRING=\"arm64\"\n")
        file(APPEND ${DMG_SCRIPT} "elif [[ \"$ARCH_INFO\" == *\"x86_64\"* ]]; then\n")
        file(APPEND ${DMG_SCRIPT} "    ARCH_STRING=\"x86_64\"\n")
        file(APPEND ${DMG_SCRIPT} "else\n")
        file(APPEND ${DMG_SCRIPT} "    ARCH_STRING=\"unknown\"\n")
        file(APPEND ${DMG_SCRIPT} "fi\n\n")
        
        file(APPEND ${DMG_SCRIPT} "DEPLOYMENT_TARGET=\"${CMAKE_OSX_DEPLOYMENT_TARGET}\"\n")
        file(APPEND ${DMG_SCRIPT} "DMG_NAME=\"${TARGET_NAME}-$ARCH_STRING-$DEPLOYMENT_TARGET.dmg\"\n\n")
        
        file(APPEND ${DMG_SCRIPT} "# Remove existing DMG if it exists\n")
        file(APPEND ${DMG_SCRIPT} "[ -f \"$OUTPUT_DIR/$DMG_NAME\" ] && rm \"$OUTPUT_DIR/$DMG_NAME\"\n\n")
        
        file(APPEND ${DMG_SCRIPT} "# Build create-dmg command\n")
        file(APPEND ${DMG_SCRIPT} "CREATE_DMG_CMD=(\n")
        file(APPEND ${DMG_SCRIPT} "    create-dmg\n")
        file(APPEND ${DMG_SCRIPT} "    --volname \"${DMG_VOLNAME}\"\n")
        file(APPEND ${DMG_SCRIPT} "    --window-pos 200 120\n")
        file(APPEND ${DMG_SCRIPT} "    --window-size 600 400\n")
        file(APPEND ${DMG_SCRIPT} "    --icon-size 100\n")
        file(APPEND ${DMG_SCRIPT} "    --icon \"$APP_BUNDLE\" 175 190\n")
        file(APPEND ${DMG_SCRIPT} "    --hide-extension \"$APP_BUNDLE\"\n")
        file(APPEND ${DMG_SCRIPT} "    --app-drop-link 425 190\n")
        file(APPEND ${DMG_SCRIPT} "    --no-internet-enable\n")
        
        # Add optional background image
        if(DMG_BACKGROUND AND EXISTS ${DMG_BACKGROUND})
            file(APPEND ${DMG_SCRIPT} "    --background \"${DMG_BACKGROUND}\"\n")
        endif()
        
        # Add optional volume icon
        if(DMG_ICON AND EXISTS ${DMG_ICON})
            file(APPEND ${DMG_SCRIPT} "    --volicon \"${DMG_ICON}\"\n")
        endif()
        
        file(APPEND ${DMG_SCRIPT} "    \"$OUTPUT_DIR/$DMG_NAME\"\n")
        file(APPEND ${DMG_SCRIPT} "    \"$OUTPUT_DIR\"\n")
        file(APPEND ${DMG_SCRIPT} ")\n\n")
        
        # Add volume icon conditionally if not explicitly provided
        if(NOT DMG_ICON OR NOT EXISTS ${DMG_ICON})
            file(APPEND ${DMG_SCRIPT} "# Add volume icon if available\n")
            file(APPEND ${DMG_SCRIPT} "if [ -f \"$BUNDLE_PATH/Contents/Resources/AppIcon.icns\" ]; then\n")
            file(APPEND ${DMG_SCRIPT} "    CREATE_DMG_CMD+=(--volicon \"$BUNDLE_PATH/Contents/Resources/AppIcon.icns\")\n")
            file(APPEND ${DMG_SCRIPT} "fi\n\n")
        endif()
        
        file(APPEND ${DMG_SCRIPT} "# Execute create-dmg command\n")
        file(APPEND ${DMG_SCRIPT} "cd \"$OUTPUT_DIR\"\n")
        file(APPEND ${DMG_SCRIPT} "\"$\{CREATE_DMG_CMD\[@\]}\"\n\n")
        
        file(APPEND ${DMG_SCRIPT} "if [ $? -eq 0 ]; then\n")
        file(APPEND ${DMG_SCRIPT} "    echo \"DMG package created successfully: $DMG_NAME\"\n")
        file(APPEND ${DMG_SCRIPT} "    echo \"DMG size: $(du -h \"$OUTPUT_DIR/$DMG_NAME\" | cut -f1)\"\n")
        file(APPEND ${DMG_SCRIPT} "    echo \"DMG location: $OUTPUT_DIR/$DMG_NAME\"\n")
        file(APPEND ${DMG_SCRIPT} "    echo \"Application bundle location: $OUTPUT_DIR/$APP_BUNDLE\"\n")
        file(APPEND ${DMG_SCRIPT} "else\n")
        file(APPEND ${DMG_SCRIPT} "    echo \"Error: DMG creation failed\"\n")
        file(APPEND ${DMG_SCRIPT} "    exit 1\n")
        file(APPEND ${DMG_SCRIPT} "fi\n")
        
        # Make script executable
        file(CHMOD ${DMG_SCRIPT} 
             PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
        
        # Add custom target for DMG creation that depends on the app being copied
        add_custom_target(${TARGET_NAME}_dmg
            COMMAND ${DMG_SCRIPT}
            DEPENDS ${TARGET_NAME}
            COMMENT "Creating DMG package for ${TARGET_NAME}"
            VERBATIM
        )
        
        # Ensure DMG creation happens after the app is copied to final location
        add_dependencies(${TARGET_NAME}_dmg ${TARGET_NAME})
        
        message(STATUS "DMG creation target added: ${TARGET_NAME}_dmg")
        message(STATUS "Run 'cmake --build . --target ${TARGET_NAME}_dmg' to create DMG")
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