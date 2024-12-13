
// This is Phase 3 of the EE454 Final Project

// The goal is to build a convolutional layer and compare it's results

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

// Define the convolution as a kernel which can be done in parallel
#define STARTING_SIZE  28
#define ENDING_SIZE    26
#define WINDOW_SIZE    3

cudaError_t convWithCuda(int* i_map, int* kernel, int* o_map);
void create_input_featuremap(int* featuremap);
void create_kernel(int* kernel);

//__global__ void Convolution(int i_featuremap[STARTING_SIZE][STARTING_SIZE], int o_featuremap[STARTING_SIZE - WINDOW_SIZE + 1][STARTING_SIZE - WINDOW_SIZE + 1], int kernel[WINDOW_SIZE][WINDOW_SIZE])
__global__ void Convolution(int* i_featuremap, int* o_featuremap, int* kernel)
{
    // This will take in a featuremap, apply a filter (kernel), and output an element of the resulting featuremap
    // The input featuremap is STARTING_SIZE x STARTING SIZE, or 28x28, the output is (STARTING_SIZE - WINDOW_SIZE + 1) x (STARTING_SIZE - WINDOW_SIZE + 1), or 26x26

    // Extract the 3x3 window from i_featuremap
    int output_element = threadIdx.x; // which element we are currently computing
    // element i corresponds to the window: from i_row  to i_row + WINDOW_SIZE - 1 by i_column to i_column + WINDOW_SIZE - 1
    int sum = 0;
    int out_row = output_element / ENDING_SIZE; // row and column of this element in the output featuremap
    int out_column = output_element % ENDING_SIZE;


    for (int i = 0; i < WINDOW_SIZE; i++)
    {
        for (int j = 0; j < WINDOW_SIZE; j++)
        {
            // Multiply Window Element-wise by the Kernel and Sum the result
            sum = sum + i_featuremap[(out_row + i) * STARTING_SIZE + (out_column + j)] * kernel[i * WINDOW_SIZE + j];
        }
    }
    o_featuremap[output_element] = sum;
}

int main()
{
    // Make i_featuremap
    int i_featuremap[STARTING_SIZE * STARTING_SIZE] = { 0 }; // TODO: Need to initialize this to something
    create_input_featuremap(i_featuremap);
    // Print the input map
    for (int i = 0; i < STARTING_SIZE; i++)
    {
        for (int j = 0; j < STARTING_SIZE; j++)
        {
            printf("{%d}", i_featuremap[(i * STARTING_SIZE) + j]);
        }
        printf("\n");
    }
    printf("\n");

    // Initialize o_featuremap
    int o_featuremap[(STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1)] = { 0 }; // TODO: Need to initialize this to something

    // Make kernel
    int kernel[WINDOW_SIZE * WINDOW_SIZE] = { 0 }; // Need to initialize this to something
    create_kernel(kernel);
    // Print the kernel
    for (int i = 0; i < WINDOW_SIZE; i++)
    {
        for (int j = 0; j < WINDOW_SIZE; j++)
        {
            printf("{%d}", kernel[(i * WINDOW_SIZE) + j]);
        }
        printf("\n");
    }
    printf("\n");

    // Apply convolutions in parallel
    cudaError_t cudaStatus = convWithCuda(i_featuremap, kernel, o_featuremap);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "addWithCuda failed!");
        return 1;
    }

    // Print the output map
    for (int i = 0; i < ENDING_SIZE; i++)
    {
        for (int j = 0; j < ENDING_SIZE; j++)
        {
            printf("{%d}", o_featuremap[(i * ENDING_SIZE) + j]);
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

void create_input_featuremap(int* featuremap)
{
    for (int i = 0; i < STARTING_SIZE; i++)
    {
        for (int j = 0; j < STARTING_SIZE; j++)
        {
            featuremap[(i * STARTING_SIZE) + j] = j % (STARTING_SIZE / 2); // Creates vertical lines
        }
    }
}

void create_kernel(int* kernel)
{
    for (int i = 0; i < WINDOW_SIZE; i++)
    {
        for (int j = 0; j < WINDOW_SIZE; j++)
        {
            if (i != j)
            {
                kernel[(i * WINDOW_SIZE) + j] = 2;
            }
            else
            {
                kernel[(i * WINDOW_SIZE) + j] = 0;
            }
        }
    }
}

cudaError_t convWithCuda(int* i_map, int* kernel, int* o_map)
{
    int* dev_input = 0;
    int* dev_output = 0;
    int* dev_kernel = 0;
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

    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy the output vector from GPU buffer back to host memory
    cudaStatus = cudaMemcpy(o_map, dev_output, ENDING_SIZE * ENDING_SIZE * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess)
    {
        fprintf(stderr, "cudaMemcpy failed!");
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