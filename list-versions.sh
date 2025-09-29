#!/bin/bash

echo "Available Linux distributions and versions:"
echo ""

echo "Ubuntu:"
echo "  18.04 (Bionic Beaver)"
echo "  20.04 (Focal Fossa)"
echo "  22.04 (Jammy Jellyfish) [default]"
echo "  24.04 (Noble Numbat)"
echo ""

echo "Debian:"
echo "  buster (Debian 10)"
echo "  bullseye (Debian 11)"
echo "  bookworm (Debian 12) [default]"
echo "  trixie (Debian 13)"
echo ""

echo "Fedora:"
echo "  37"
echo "  38"
echo "  39 [default]"
echo "  40"
echo ""

echo "Arch Linux:"
echo "  base [default]"
echo "  lts"
echo ""

echo "Usage examples:"
echo "  ./scripts/linux/build.sh ubuntu 22.04"
echo "  ./scripts/linux/build.sh debian bookworm"
echo "  ./scripts/linux/build.sh fedora 39"
echo "  ./scripts/linux/build.sh arch base"
echo ""
echo "To build all versions:"
echo "  ./build-all.sh"