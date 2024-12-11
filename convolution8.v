// Assumptions
// Starting N (Height & Width): 8
// image/color bit depth: 8

// set i_featuremap size = N*N*depth
// set o_featuremap size = (N-2)*(N-2)*depth
// update parameter STARTING_SIZE to new N value

`timescale  1ps / 1ps

// This convolution module will take in an 8x8, and produce a 6x6
module convolution8#(
    parameter STARTING_SIZE = 8, // this is the initial height & width
    parameter WINDOW_SIZE = 3,    // this is the height & width of the window
    parameter ELEMENT_SIZE = 8
    )(
    //input wires for a feature map
    input wire clk,
    input wire rst,
    input wire [(STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE)-1:0] i_featuremap,  // Maximum number of bits for 8x8 image of 8-bit depth
    input wire [(WINDOW_SIZE*WINDOW_SIZE*ELEMENT_SIZE)-1:0] kernel, // 3x3 8-bit kernel
    output reg [(((STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1))*ELEMENT_SIZE)-1:0] o_featuremap  // Maximum size of resulting feature_map, 6x6 of 8-bit depth

); 

// input elements rows indices: [511:448], [447:384], [383:320], [319:256], [255:192], [191:128], [127:64], [63:0]
// input elements rows indices: [287:240], [239:192], [191:144], [143:96], [95:48], [47:0]
// patch row indicies: [71:48], [47:24], [23:0]

// register to act as an array
reg [(((STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1))*ELEMENT_SIZE)-1:0] feature_map = 0;

// register to act as the window's array
reg [ELEMENT_SIZE-1 : 0] window_patch_pixel; // represents a single element of the window patch
reg [ELEMENT_SIZE-1 : 0] kernel_pixel; // represents a single element of the kernel

// counters used later
// TODO: to optimize registers, change these to reg type instead of integer, which are each 32-bit
reg [3:0] row_index, column_index, patch_element, element_column, element_row; 
reg [7:0] SCALE_FACTOR = 255; // TODO: find a way to generalize this
integer MAX_PATCH_SUM = 586305; // 255(max 8-bit value) * 255(max 8-bit value) * 9
reg [31:0] scaled_sum = 0;
reg [19:0] patch_sum = 0;
//reg [8:0] row_offset;
reg [8:0] output_index;
reg [8:0] image_index;

//row_offset = (STARTING_SIZE * ELEMENT_SIZE); // each row is seperated by the number of elements in a row * size of elements

// Debugging Tools
always @(patch_sum) begin
    $display("[%0t] patch_sum changed: %h", $time, patch_sum);
end

always @(column_index) begin
    $display("[%0t] column_index changed: %h", $time, column_index);
end

always @(row_index) begin
    $display("[%0t] row_index changed: %h", $time, row_index);
end

always @(kernel) begin
    $display("[%0t] row_index changed: %h", $time, row_index);
end

always @(posedge clk or posedge rst) begin
    // implement positive rst logic
    if (rst) begin
    // TODO: implement positive reset for the feature map
    // just reset the output for now?
        o_featuremap <= 0;
        feature_map <= 0;
        patch_sum <= 0;
    end else begin
        for (row_index = 0; row_index < STARTING_SIZE - WINDOW_SIZE + 1; row_index = row_index + 1) begin
            for (column_index = 0; column_index < STARTING_SIZE - WINDOW_SIZE + 1; column_index = column_index + 1) begin
                o_featuremap <= 0; // reset the output featuremap
                patch_sum <= 0; // reset the sum each time

                // ---------- PATCH CREATION ----------//
                // Create patch starting top left and navigating to the right, then go down 1 and all the way back over left
                for (patch_element = 0; patch_element < WINDOW_SIZE*WINDOW_SIZE; patch_element = patch_element + 1) begin

                    element_column = patch_element % WINDOW_SIZE; // the elements column
                    element_row = patch_element / WINDOW_SIZE; // the elements row
                    image_index = (STARTING_SIZE * STARTING_SIZE * ELEMENT_SIZE - 1) - (element_row * (STARTING_SIZE * ELEMENT_SIZE)) - (element_column * ELEMENT_SIZE); // the upper bit location of this pixel
                    
                    window_patch_pixel = i_featuremap[image_index -: ELEMENT_SIZE]; // extracts the desired image pixel
                    kernel_pixel = kernel[((WINDOW_SIZE * WINDOW_SIZE - patch_element) * ELEMENT_SIZE - 1) -: ELEMENT_SIZE]; // extracts desired kernel pixel

                    patch_sum = patch_sum + (window_patch_pixel * kernel_pixel);
                end

                // Normalize the sum to fit into an 8-bit featuremap element
                
                scaled_sum = (patch_sum * SCALE_FACTOR) / MAX_PATCH_SUM;
    
                output_index = (((STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1)) * ELEMENT_SIZE - 1) - (ELEMENT_SIZE*column_index) - ((STARTING_SIZE * ELEMENT_SIZE)*row_index);
    
                // assign the summations to the featuremap
                $display("[%0t] row_index: %d, column_index: %d, patch_sum: %d", $time, row_index, column_index, patch_sum);
                feature_map[output_index -: ELEMENT_SIZE] = scaled_sum [7:0];
            end // of a column
        end // of a row
        
        o_featuremap <= feature_map;
    end
end

endmodule