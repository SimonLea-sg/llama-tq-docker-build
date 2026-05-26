## Llama.cpp with Turbo Quant Docker intermediant image build.


FROM nvidia/cuda:12.8.1-devel-ubuntu24.04 AS build

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
    -DCMAKE_EXE_LINKER_FLAGS=-Wl,--allow-shlib-undefined . && \
    cmake --build build --config Release -j$(nproc)

RUN mkdir -p /app/lib /app/full/
RUN cp build/bin/* /app/full/
RUN find /app/full -name "*.so*" -exec cp -P {} /app/lib/ \;
RUN cp *.py requirements.txt /app/full/
RUN cp -r conversion gguf-py requirements /app/full/
RUN cp .devops/tools.sh /app/full/tools.sh


## Base Runtime Image

FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04 as base

RUN mkdir /app

COPY --from=build /app/lib/* /app

WORKDIR /app

RUN apt-get update \
    && apt-get install -y libgomp1 curl \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete


## Full Runtime image

FROM base AS full

COPY --from=build /app/full /app

RUN apt-get update \
    && apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-wheel \
    && pip install --break-system-packages --upgrade setuptools \
    && pip install --break-system-packages -r requirements.txt \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

RUN echo "/app/lib" > /etc/ld.so.conf.d/llama-bin.conf \
    && ldconfig

ENTRYPOINT ["/app/tools.sh"]


## CLI Runtime Image

FROM base AS light

COPY --from=build /app/full/llama-cli /app/full/llama-completion /app/

WORKDIR /app

ENTRYPOINT [ "/app/llama-cli" ]


### Server Runtime Image
FROM base AS server

ENV LLAMA_ARG_HOST=0.0.0.0

COPY --from=build /app/full/llama-server /app

WORKDIR /app

HEALTHCHECK CMD [ "curl", "-f", "http://localhost:8080/health" ]

ENTRYPOINT [ "/app/llama-server" ]
