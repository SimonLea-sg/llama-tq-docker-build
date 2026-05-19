# Llama Turbo Quant TMP Docker Build (Cuda)


Build a Llama.cpp with Turbo Quant docker image.

- ***Expected Use***: As a base image for AI projects requiring Llama.cpp with Turbo Quant backend.
- ***Build Root Image***: nvidia/cuda:12.8.1-devel-ubuntu24.04.
- ***Release Root image***: nvidia/cuda:12.8.1-runtime-ubuntu24.04
- ***LLama.cpp Src***: TheToms Llama.cpp with TQ branch.


## Image creation flow:

Build Root Image --> Setup build env --> Build Llama.cpp (llama-server / all)

Release Image    --> Setup run env   --> Copy built Llama.cpp 


## Options (which Dockerfile to use)

- ***llama-server.Dockerfile*** : Lightweight image with only llama-server.
- ***llama-all.Dockerfile***    : Full llama.cpp build.


## Build Instructions:
User the command below to build the image.

Suggested image names based on Docker file used (to align with my other repos).
|      [Dockerfile]         |        [image name]           |
| :---: | :---: |
|  llama-all.Dockerfile     |  llamacpp-tq-mtp-base-all     |
|  llama-server.Dockerfile  |  llamacpp-tq-mtp-base-server  |

```
docker build --no-cache -t [image name] -f ./[Dockerfile] .
```


## Usage in other builds:

Use the following at the top of your Dockerfile to use this image as the start to your application / service.

```
FROM llamacpp-tq-base
```

---

## llama.cpp with Turbo Quant source:

Thanks to Tom Turney for making his llama.cpp build with Turbo Quant available for use by all.

TheTom: [llama-cpp-turboquant](https://github.com/TheTom/llama-cpp-turboquant)
