# Llama Turbo Quant Docker Build


Build a Llama.cpp with Turbo Quant docker image.

- ***Expected Use***: As a base image for AI projects requiring Llama.cpp with Turbo Quant backend.
- ***Build Root Image***: nvidia/cuda:12.8.1-devel-ubuntu24.04.
- ***Release Root image***: nvidia/cuda:12.8.1-runtime-ubuntu24.04
- ***LLama.cpp Src***: TheToms Llama.cpp with TQ branch.


## Image creation flow:

Build Root Image --> Setup build env --> Build Llama.cpp

Release Image --> Setup run env --> Copy built Llama.cpp 


## Options (which Dockerfile to use)

- ***llama-server.Dockerfile*** : Lightweight image with only llama-server.
- ***llama-all.Dockerfile***    : Full llama.cpp build.


## Build Instructions:

Rename the Dockerfile of choice to ```Dockerfile``` and then run

```
docker build -t llamacpp-tq-base -f ./Dockerfile .
```


## Usage in other builds:

Use the following at the top of your Dockerfile to use this image as the start to your application / service.

```
FROM llamacpp-tq-base
```
