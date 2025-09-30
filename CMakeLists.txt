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

    target_link_libraries(QtApplication 
        PRIVATE 
        Qt6::Core 
        Qt6::Widgets
    )
    
    # Include deployment configuration
    include(${CMAKE_CURRENT_SOURCE_DIR}/deployment.cmake)
    
    # Apply deployment to example application with DMG creation
    qt_deploy_application(QtApplication 
        CREATE_DMG
        MACOS_BUNDLE_ID "com.example.QtApplication"
    )
else()
    # When used as submodule, just include the deployment functions
    include(${CMAKE_CURRENT_LIST_DIR}/deployment.cmake)
endif()