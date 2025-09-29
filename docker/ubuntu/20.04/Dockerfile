FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Add Qt6 PPA for Ubuntu 20.04
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:okirby/qt6-backports -y && \
    apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    qt6-base-dev \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    libgl1-mesa-dev \
    git \
    || (apt-get install -y \
        qt5-default \
        qttools5-dev \
        qttools5-dev-tools) \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN mkdir build && cd build && \
    (cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. || \
     (sed 's/Qt6/Qt5/g; s/qt_/qt5_/g' ../CMakeLists.txt > ../CMakeLists-qt5.txt && \
      cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -f ../CMakeLists-qt5.txt ..)) && \
    ninja

CMD ["./build/QtApplication"]