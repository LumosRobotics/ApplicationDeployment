# This file serves as an example when used standalone
# When used as a submodule, include deployment.cmake in your parent project

cmake_minimum_required(VERSION 3.20)

# Only create project if this is the main CMakeLists.txt
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(QtApplicationDeployment VERSION 1.0.0 LANGUAGES CXX)
    
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)

    find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
    qt_standard_project_setup()

    # Example application (remove when using as submodule)
    set(SOURCES
        src/main.cpp
        src/mainwindow.cpp
    )

    set(HEADERS
        src/mainwindow.h
    )

    qt_add_executable(QtApplication
        ${SOURCES}
        ${HEADERS}
    )

    target_link_libraries(QtApplication Qt6::Core Qt6::Widgets)
    
    # Include deployment configuration
    include(${CMAKE_CURRENT_SOURCE_DIR}/deployment.cmake)
    
    # Apply deployment to example application
    qt_deploy_application(QtApplication)
else()
    # When used as submodule, just include the deployment functions
    include(${CMAKE_CURRENT_LIST_DIR}/deployment.cmake)
endif()

if(WIN32)
    set_target_properties(QtApplication PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
    
    qt_generate_deploy_app_script(
        TARGET QtApplication
        FILENAME_VARIABLE deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
endif()

if(APPLE)
    # Set minimum macOS version (can be overridden via -DCMAKE_OSX_DEPLOYMENT_TARGET)
    if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
        set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15" CACHE STRING "Minimum macOS deployment version")
    endif()
    
    # Support universal binaries (Intel + Apple Silicon)
    if(NOT CMAKE_OSX_ARCHITECTURES)
        set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "macOS architectures")
    endif()
    
    set_target_properties(QtApplication PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_GUI_IDENTIFIER com.example.QtApplication
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/scripts/macos/Info.plist.in
    )
    
    # Set deployment target for the target
    set_target_properties(QtApplication PROPERTIES
        XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET ${CMAKE_OSX_DEPLOYMENT_TARGET}
    )
    
    qt_generate_deploy_app_script(
        TARGET QtApplication
        FILENAME_VARIABLE deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
    
    # Code signing (optional)
    if(CMAKE_BUILD_TYPE STREQUAL "Release" AND DEFINED ENV{APPLE_DEVELOPER_ID})
        set_target_properties(QtApplication PROPERTIES
            XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Developer ID Application: $ENV{APPLE_DEVELOPER_ID}"
            XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Manual"
        )
    endif()
endif()

if(UNIX AND NOT APPLE)
    install(TARGETS QtApplication
        BUNDLE DESTINATION .
        RUNTIME DESTINATION bin
    )
    
    qt_generate_deploy_app_script(
        TARGET QtApplication
        FILENAME_VARIABLE deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
endif()