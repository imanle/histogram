
#include "common.h"
#include "timer.h"

__global__ void histogram_private_kernel(unsigned char* image, unsigned int* bins, unsigned int width, unsigned int height) {
     __shared__ char hist_s [NUM_BINS];
     unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < NUM_BINS){
        hist_s[threadIdx.x]=0;
    }
     __syncthreads();
    
    if(i < width * height) {
        unsigned char b = image[i];
        atomicAdd(&hist_s[b], 1);
    }
     __syncthreads();
    if (i < width * height && i < NUM_BINS) {
        unsigned char b = image[i];
        atomicAdd(&bins[b],hist_s[b]);
    }
}

void histogram_gpu_private(unsigned char* image_d, unsigned int* bins_d, unsigned int width, unsigned int height) {

    // TODO





}

__global__ void histogram_private_coarse_kernel(unsigned char* image, unsigned int* bins, unsigned int width, unsigned int height) {

    // TODO














}

void histogram_gpu_private_coarse(unsigned char* image_d, unsigned int* bins_d, unsigned int width, unsigned int height) {

    // TODO





}

