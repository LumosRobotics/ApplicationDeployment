FROM debian:buster

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    qt5-default \
    qttools5-dev \
    qttools5-dev-tools \
    libgl1-mesa-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

# Use Qt5 for older Debian versions
RUN sed 's/Qt6/Qt5/g; s/qt_/qt5_/g' CMakeLists.txt > CMakeLists-qt5.txt && \
    mkdir build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -f ../CMakeLists-qt5.txt .. && \
    ninja

CMD ["./build/QtApplication"]