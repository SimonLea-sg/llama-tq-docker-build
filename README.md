# Llama Turbo Quant Docker Build (Cuda)


Build a Llama.cpp with Turbo Quant docker image.

- ***Expected Use***: As a base image for AI projects requiring Llama.cpp with Turbo Quant backend.
- ***Build Image***: nvidia/cuda:12.8.1-devel-ubuntu24.04.
- ***Base Image***: nvidia/cuda:12.8.1-runtime-ubuntu24.04
- ***Release images***: nvidia/cuda:12.8.1-runtime-ubuntu24.04
- ***LLama.cpp Src***: TheToms Llama.cpp with the TQ branch.


## Build Instructions:

Rename the Dockerfile of choice to ```Dockerfile``` and then run

Build specific images with the command below. 

Image Options;
- Build:  Source code build environment.
- Base:   Base runtime image.
- Full:   Everything included from llama.cpp 
- Light:  Only the llama-cli and llama-completion.
- Server: Only llama-server.

Output Image Name:  Would suggest llamacpp-tq-[Target Image]

```
docker build --target [Target Image] -t [Output Image Name] .

```


## Usage in other builds:

Use the following at the top of your Dockerfile to use this image as the start to your application / service.

llama.cpp is installed in the /app/llama.cpp hierachy of directories.

```
FROM llamacpp-tq-base-[Target Image]
```

---

## llama.cpp with Turbo Quant source:

Thanks to Tom Turney for making his llama.cpp build with Turbo Quant available for use by all.

TheTom: [llama-cpp-turboquant](https://github.com/TheTom/llama-cpp-turboquant)