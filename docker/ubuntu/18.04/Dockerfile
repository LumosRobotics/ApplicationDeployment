FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

# Add Qt6 PPA for older Ubuntu versions
RUN apt-get update && apt-get install -y software-properties-common wget gnupg2 && \
    wget -qO - https://download.qt.io/official_releases/qt/6.6/6.6.0/single/qt-everywhere-src-6.6.0.tar.xz | tar -xJ && \
    apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-glx0-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# For Ubuntu 18.04, we need to build Qt6 from source or use a compatible version
# Using Qt5 as fallback for better compatibility
RUN apt-get update && apt-get install -y \
    qt5-default \
    qttools5-dev \
    qttools5-dev-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

# Create a CMakeLists.txt variant for Qt5
RUN sed 's/Qt6/Qt5/g; s/qt_/qt5_/g' CMakeLists.txt > CMakeLists-qt5.txt && \
    mkdir build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -f ../CMakeLists-qt5.txt .. && \
    ninja

CMD ["./build/QtApplication"]