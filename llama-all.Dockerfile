# Llama.cpp with Turbo Quant Docker intermediant image build.

## Dev Build.

FROM nvidia/cuda:12.8.1-devel-ubuntu24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    gcc-14 \
    g++-14 \
    cmake \
    build-essential \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    libssl-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

ENV CC=gcc-14 CXX=g++-14 CUDAHOSTCXX=g++-14

WORKDIR /build

# CRITICAL: Must use --branch feature/turboquant-kv-cache
# Default 'master' does NOT have turbo2/turbo3/turbo4 cache types.
RUN git clone https://github.com/TheTom/llama-cpp-turboquant.git \
    --branch feature/turboquant-kv-cache \
    --depth=1

WORKDIR /build/llama-cpp-turboquant

# Fix: libcuda.so.1 is not available at build time (driver is injected at runtime only).
RUN ln -sf /usr/local/cuda/lib64/stubs/libcuda.so \
           /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/cuda-stubs.conf \
    && ldconfig

RUN cmake -B build \
    -DGGML_CUDA=ON \
    -DGGML_NATIVE=OFF \
    -DGGML_BACKEND_DL=ON \
    -DGGML_CPU_ALL_VARIANTS=ON \
    -DLLAMA_OPENSSL=ON \
    -DLLAMA_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS=-Wl,--allow-shlib-undefined .&& \
    cmake --build build --config Release -j14

## Runtime Setup

FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04

COPY --from=builder /build/llama-cpp-turboquant/build/bin /opt/llama/bin

RUN ln -sf /opt/llama/bin/llama-server /usr/local/bin/llama-server \
    && echo "/opt/llama/bin" > /etc/ld.so.conf.d/llama-bin.conf \
    && ldconfig
