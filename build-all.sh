#!/bin/bash

set -e

echo "Building Qt Application for all platforms..."

# Define all platform-version combinations
declare -A DISTRO_VERSIONS
DISTRO_VERSIONS["ubuntu"]="18.04 20.04 22.04 24.04"
DISTRO_VERSIONS["debian"]="buster bullseye bookworm trixie"
DISTRO_VERSIONS["fedora"]="37 38 39 40"
DISTRO_VERSIONS["arch"]="base lts"

echo "Building for Linux distributions..."
for distro in "${!DISTRO_VERSIONS[@]}"; do
    echo "Building for $distro..."
    for version in ${DISTRO_VERSIONS[$distro]}; do
        echo "  Building $distro $version..."
        ./scripts/linux/build.sh $distro $version
        echo "  $distro $version build completed!"
    done
    echo ""
done

echo "All Linux builds completed!"
echo ""
echo "Built distributions and versions:"
for distro in "${!DISTRO_VERSIONS[@]}"; do
    echo "  $distro: ${DISTRO_VERSIONS[$distro]}"
done
echo ""
echo "To build for other platforms:"
echo "  Windows: Run scripts/windows/build.bat"
echo "  macOS:   Run scripts/macos/build.sh"