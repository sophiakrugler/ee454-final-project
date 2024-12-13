// This is Phase 3 of the EE454 Final Project

// The goal is to build a convolutional layer and compare it's results

// Define the convolution as a kernel which can be done in parallel
#define STARTING_SIZE 28
#define WINDOW_SIZE 3

__global__ void Convolution(int i_featuremap[STARTING_SIZE][STARTING_SIZE], int o_featuremap[STARTING_SIZE-WINDOW_SIZE+1][STARTING_SIZE-WINDOW_SIZE+1],  int kernel[WINDOW_SIZE][WINDOW_SIZE])
{
    // This will take in a featuremap, apply a filter (kernel), and output an element of the resulting featuremap
    // The input featuremap is STARTING_SIZE x STARTING SIZE, or 28x28, the output is (STARTING_SIZE - WINDOW_SIZE + 1) x (STARTING_SIZE - WINDOW_SIZE + 1), or 26x26

    // Extract the 3x3 window from i_featuremap

    // Multiply Window Element-wise by the Kernel

    // Sum the resulting array

    // Return that sum as an element of o_featuremap
}

int main()
{
    // TODO: determine how many convolutions are done in parallel
    int total_threads = (STARTING_SIZE-WINDOW_SIZE+1)*(STARTING_SIZE-WINDOW_SIZE+1);

    // invoke the kernel for a number of threads
    Convolution<<<1 , total_threads>>>(i_featuremap, kernel);
    return 0;
}