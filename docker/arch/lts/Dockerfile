FROM archlinux:base-devel

RUN pacman -Syu --noconfirm && pacman -S --noconfirm \
    cmake \
    ninja \
    qt6-base \
    qt6-tools \
    mesa \
    git \
    && pacman -Scc --noconfirm

WORKDIR /app

COPY . .

RUN mkdir build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. && \
    ninja

CMD ["./build/QtApplication"]