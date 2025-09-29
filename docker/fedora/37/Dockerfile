FROM fedora:37

RUN dnf update -y && dnf install -y \
    gcc-c++ \
    cmake \
    ninja-build \
    qt6-qtbase-devel \
    qt6-qttools-devel \
    mesa-libGL-devel \
    git \
    && dnf clean all

WORKDIR /app

COPY . .

RUN mkdir build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. && \
    ninja

CMD ["./build/QtApplication"]