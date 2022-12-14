
#include "common.h"
#include "timer.h"
#define COARSENING_FACTOR 32
__global__ void histogram_private_kernel(unsigned char* image, unsigned int* bins, unsigned int width, unsigned int height) {
     __shared__ int hist_s[NUM_BINS];
     unsigned int i = blockIdx.x*blockDim.x+threadIdx.x;
     if(threadIdx.x < NUM_BINS){
          hist_s[threadIdx.x]=0;
     }
     
    __syncthreads();
     
    if(i<width*height) {
        unsigned char b = image[i];
        atomicAdd(&hist_s[b], 1);
    }
    
     __syncthreads();
     
    if (threadIdx.x < NUM_BINS) {
        atomicAdd(&bins[threadIdx.x],hist_s[threadIdx.x]);
    }
   
}

void histogram_gpu_private(unsigned char* image_d, unsigned int* bins_d, unsigned int width, unsigned int height) {

     const unsigned int numThreadsPerBlock = 1024;
     const unsigned int numBlocks = (width*height + numThreadsPerBlock - 1)/numThreadsPerBlock;
     histogram_private_kernel <<< numBlocks, numThreadsPerBlock >>>(image_d,bins_d, width,height);
}

__global__ void histogram_private_coarse_kernel(unsigned char* image, unsigned int* bins, unsigned int width, unsigned int height) {

   __shared__ unsigned int hist_s[NUM_BINS];
    unsigned int index = blockIdx.x * blockDim.x * COARSENING_FACTOR + threadIdx.x;

    if ( threadIdx.x < NUM_BINS ) 
        hist_s[ threadIdx.x ] = 0;
    
    __syncthreads();

    for(int i = 0; i < COARSENING_FACTOR; ++i) 
        if (i * blockDim.x + index < width * height)
            atomicAdd(&hist_s[image[i * blockDim.x + index ]], 1);

    __syncthreads();

    if (threadIdx.x < NUM_BINS && hist_s[threadIdx.x] > 0) 
        atomicAdd(&bins[threadIdx.x], hist_s[threadIdx.x]);

}

void histogram_gpu_private_coarse(unsigned char* image_d, unsigned int* bins_d, unsigned int width, unsigned int height) {

    unsigned int numThreadsPerBlock = 1024;
    
    unsigned int numBlocks = (width * height + numThreadsPerBlock   - 1) / (COARSENING_FACTOR * numThreadsPerBlock);
    histogram_private_coarse_kernel <<< numBlocks, numThreadsPerBlock >>> (image_d, bins_d, width, height);





}

