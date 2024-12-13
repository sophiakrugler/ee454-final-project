
// This is Phase 3 of the EE454 Final Project

// The goal is to build a convolutional layer and compare it's results

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

// Define the convolution as a kernel which can be done in parallel
#define STARTING_SIZE 5
#define ENDING_SIZE   3
#define WINDOW_SIZE    3

cudaError_t convWithCuda(const int(*i_map)[STARTING_SIZE], const int(*kernel)[WINDOW_SIZE], int (*o_map)[ENDING_SIZE]);
void create_input_featuremap(int (*featuremap)[STARTING_SIZE]);
void create_kernel(int (*kernel)[WINDOW_SIZE]);

//__global__ void Convolution(int i_featuremap[STARTING_SIZE][STARTING_SIZE], int o_featuremap[STARTING_SIZE - WINDOW_SIZE + 1][STARTING_SIZE - WINDOW_SIZE + 1], int kernel[WINDOW_SIZE][WINDOW_SIZE])
__global__ void Convolution(int (*i_featuremap)[STARTING_SIZE], int (*o_featuremap)[ENDING_SIZE], int (*kernel)[WINDOW_SIZE])
{
    // This will take in a featuremap, apply a filter (kernel), and output an element of the resulting featuremap
    // The input featuremap is STARTING_SIZE x STARTING SIZE, or 28x28, the output is (STARTING_SIZE - WINDOW_SIZE + 1) x (STARTING_SIZE - WINDOW_SIZE + 1), or 26x26

    // Extract the 3x3 window from i_featuremap
    int i = threadIdx.x; // which element we are currently computing
    int sum = 0;

    for (int j = 0; j < (WINDOW_SIZE * WINDOW_SIZE); j++)
    {
        // Multiply Window Element-wise by the Kernel and Sum the result
        sum = sum + i_featuremap[(i / ENDING_SIZE) + (j / WINDOW_SIZE)][(j % ENDING_SIZE) + (j % WINDOW_SIZE)] * kernel[j / WINDOW_SIZE][j % WINDOW_SIZE];
    }

    // Return that sum as an element of o_featuremap
    o_featuremap[i / ENDING_SIZE][i % ENDING_SIZE] = sum;
}

int main()
{
    // Make i_featuremap
    int i_featuremap[STARTING_SIZE][STARTING_SIZE] = { 0 }; // TODO: Need to initialize this to something
    create_input_featuremap(i_featuremap);

    // Initialize o_featuremap
    int o_featuremap[(STARTING_SIZE - WINDOW_SIZE + 1)][(STARTING_SIZE - WINDOW_SIZE + 1)] = {0}; // TODO: Need to initialize this to something

    // Make kernel
    int kernel[WINDOW_SIZE][WINDOW_SIZE] = { 1 }; // Need to initialize this to something
    create_kernel(kernel);

    int total_threads = (STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1);

    cudaError_t cudaStatus = convWithCuda(i_featuremap, kernel, o_featuremap);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "addWithCuda failed!");
        return 1;
    }

    // invoke the kernel for a number of threads
    //Convolution<<<1,total_threads>>>(i_featuremap, o_featuremap, kernel);

    // Print the input map
    for (int i = 0; i < STARTING_SIZE; i++)
    {
        for (int j = 0; j < STARTING_SIZE; j++)
        {
            printf("{%d}", i_featuremap[i][j]);
        }
        printf("\n");
    }
    printf("\n");

    // Print the kernel
    for (int i = 0; i < WINDOW_SIZE; i++)
    {
        for (int j = 0; j < WINDOW_SIZE; j++)
        {
            printf("{%d}", kernel[i][j]);
        }
        printf("\n");
    }
    printf("\n");

    // Print the output map
    for (int i = 0; i < ENDING_SIZE; i++)
    {
        for (int j = 0; j < ENDING_SIZE; j++)
        {
            printf("{%d}", o_featuremap[i][j]);
        }
        printf("\n");
    }

    // cudaDeviceReset must be called before exiting in order for profiling and
    // tracing tools such as Nsight and Visual Profiler to show complete traces.
    cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceReset failed!");
        return 1;
    }

    return 0;
}

void create_input_featuremap(int (*featuremap)[STARTING_SIZE])
{
    for (int i = 0; i < STARTING_SIZE; i++)
    {
        for (int j = 0; j < STARTING_SIZE; j++)
        {
            featuremap[i][j] = j%(STARTING_SIZE/2); // Creates vertical lines
        }
    }
}

void create_kernel(int (*kernel)[WINDOW_SIZE])
{
    for (int i = 0; i < WINDOW_SIZE; i++)
    {
        for (int j = 0; j < WINDOW_SIZE; j++)
        {
            if (i != j)
            {
                kernel[i][j] = 1;
            }
            else
            {
                kernel[i][j] = 0;
            }
        }
    }
}

cudaError_t convWithCuda(const int(*i_map)[STARTING_SIZE], const int(*kernel)[WINDOW_SIZE], int (*o_map)[ENDING_SIZE])
{
    int (*dev_input)[STARTING_SIZE] = { 0 };
    int (*dev_output)[ENDING_SIZE] = { 0 };
    int (*dev_kernel)[WINDOW_SIZE] = { 0 };
    cudaError_t cudaStatus;
    
    // Choose which GPU to run on
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for the 3 arrays
    cudaStatus = cudaMalloc((void**)&dev_output, ENDING_SIZE * ENDING_SIZE * sizeof(int)); // allocate ENDING_SIZE^2 * size of int for the output featuremap
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_input, STARTING_SIZE * STARTING_SIZE * sizeof(int)); // allocate STARTING_SIZE^2 * size of int for the input featuremap
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_kernel, WINDOW_SIZE * WINDOW_SIZE * sizeof(int)); // allocate WINDOW_SIZE^2 * size of int for the input kernel
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Copy the vectors from Host to GPU buffers
    cudaStatus = cudaMemcpy(dev_input, i_map, STARTING_SIZE * STARTING_SIZE * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_output, o_map, ENDING_SIZE * ENDING_SIZE * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_kernel, kernel, WINDOW_SIZE * WINDOW_SIZE * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    // Launch a kernel on the GPU with one thread for each element
    Convolution << <1, ENDING_SIZE*ENDING_SIZE >> > (dev_input, dev_output, dev_kernel);

    // Check for any errors when launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

Error:
    // Free the memory for the 3 arrays
    cudaFree(dev_input);
    cudaFree(dev_output);
    cudaFree(dev_kernel);

    // Return whether it failed
    return cudaStatus;
}