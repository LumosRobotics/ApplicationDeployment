@echo off
setlocal enabledelayedexpansion

echo Building Qt Application for Windows...

if not exist "build_release" mkdir build_release
cd build_release

cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release ..
if !errorlevel! neq 0 (
    echo CMake configuration failed!
    exit /b 1
)

cmake --build . --config Release
if !errorlevel! neq 0 (
    echo Build failed!
    exit /b 1
)

echo Build completed successfully!
echo.
echo Running deployment...
cmake --install . --config Release
if !errorlevel! neq 0 (
    echo Deployment failed!
    exit /b 1
)

echo Deployment completed successfully!
echo Binary location: build_release/Release/QtApplication.exe