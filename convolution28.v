
// Assumptions
// Starting N (Height & Width): 28
// image/color bit depth: 8

// set i_featuremap size = N*N*depth
// set o_featuremap size = (N-2)*(N-2)*depth
// update parameter STARTING_SIZE to new N value

`timescale  1ps / 1ps

// This convolution module will take in an 28x28, and produce a 26x26
module convolution28#(
    parameter STARTING_SIZE = 28, // this is the initial height & width
    parameter WINDOW_SIZE = 3,    // this is the height & width of the window
    parameter ELEMENT_SIZE = 8,
    parameter ENDING_SIZE = 26, // starting size - window size + 1
    parameter ENDING_ELEMENT_SIZE = 20
    )(
    //input wires for a feature map
    input wire clk,
    input wire rst,
    input wire en,
    input wire [(STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE)-1:0] i_featuremap,  // Maximum number of bits for 8x8 image of 8-bit depth
    input wire [(WINDOW_SIZE*WINDOW_SIZE*ELEMENT_SIZE)-1:0] kernel, // 3x3 8-bit kernel
    output reg [ENDING_SIZE*ENDING_SIZE*ENDING_ELEMENT_SIZE-1:0] o_featuremap,  // Maximum size of resulting feature_map, 6x6 of 8-bit depth
    output reg done
); 

// register to act as an array
reg [ENDING_SIZE*ENDING_SIZE*ENDING_ELEMENT_SIZE-1:0] feature_map = 0;

// register to act as the window's array
reg [ELEMENT_SIZE-1 : 0] window_patch_pixel; // represents a single element of the window patch
reg [ELEMENT_SIZE-1 : 0] kernel_pixel; // represents a single element of the kernel

// counters used later
// TODO: to optimize registers, change these to reg type instead of integer, which are each 32-bit
reg [5:0] row_index, column_index, patch_element;
reg [2:0] element_column, element_row; 
reg [7:0] SCALE_FACTOR = 255; // TODO: find a way to generalize this
integer MAX_PATCH_SUM = 586305; // 255(max 8-bit value) * 255(max 8-bit value) * 9
reg [31:0] scaled_sum = 0;
reg [ENDING_ELEMENT_SIZE - 1:0] patch_sum = 0;
reg [ENDING_SIZE-1:0] output_index; // Max value of output index is ENDING_SIZE*ENDING_SIZE*ENDING_ELEMENT_SIZE-1
reg [STARTING_SIZE - 1:0] image_index; // Max value of image index is STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE - 1

always @(posedge clk or posedge rst) begin
    // implement positive rst logic
    if (rst) begin
        o_featuremap <= 0;
        feature_map <= 0;
        patch_sum <= 0;
	done <= 0;
    end else if (en && !done) begin
        for (row_index = 0; row_index < ENDING_SIZE; row_index = row_index + 1) begin
            for (column_index = 0; column_index < ENDING_SIZE; column_index = column_index + 1) begin
                patch_sum = 0; // reset the sum each time

                // ---------- PATCH CREATION ----------//
                // Create patch starting top left and navigating to the right, then go down 1 and all the way back over left
                for (patch_element = 0; patch_element < WINDOW_SIZE*WINDOW_SIZE; patch_element = patch_element + 1) begin

                    element_column = patch_element % WINDOW_SIZE; // the elements column
                    element_row = patch_element / WINDOW_SIZE; // the elements row
                    image_index = (element_row * (STARTING_SIZE * ELEMENT_SIZE)) + (element_column * ELEMENT_SIZE); // the upper bit location of this pixel
                            
                    kernel_pixel = kernel[element_row*WINDOW_SIZE*ELEMENT_SIZE + element_column*ELEMENT_SIZE +: ELEMENT_SIZE];
                    window_patch_pixel = i_featuremap[row_index*STARTING_SIZE*ELEMENT_SIZE + column_index*ELEMENT_SIZE + image_index +: ELEMENT_SIZE];
                    
                    patch_sum = patch_sum + (window_patch_pixel * kernel_pixel);
                    // $display("window_patch_pixel: %d, kernel_pixel: %d, new patch_sum: %d", window_patch_pixel, kernel_pixel, patch_sum);
                end
                
            // scaled_sum = (patch_sum * SCALE_FACTOR) / MAX_PATCH_SUM; // Normalize the sum to fit into an 8-bit featuremap element
            output_index = row_index*ENDING_SIZE*ENDING_ELEMENT_SIZE + column_index*ENDING_ELEMENT_SIZE + ENDING_ELEMENT_SIZE - 1;
        
            // assign the summations to the featuremap
            $display("[%0t] row_index: %d, column_index: %d, patch_sum: %d", $time, row_index, column_index, patch_sum);
            feature_map[output_index -: ENDING_ELEMENT_SIZE] = patch_sum; // TODO: if scaling, replace patch_sum with scaled_sum
            end // of a column
        end // of a row
        
        o_featuremap <= feature_map;
	    done <= 1;
    end
end

endmodule

