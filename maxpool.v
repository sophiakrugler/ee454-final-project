
// According to the reference python model, this module will take in a 26x26 feature map and produce a 2x2 reduced feature map

`timescale  1ps / 1ps

module maxpool#(
    parameter STARTING_SIZE = 26, // this is the initial height & width
    parameter ELEMENT_SIZE = 20,
    parameter ENDING_SIZE = 2,
    )(
    //input wires for a feature map
    input wire clk,
    input wire rst,
    input wire en,
    input wire [(STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE)-1:0] i_featuremap,  // Maximum number of bits for 8x8 image of 8-bit depth
    output reg [ENDING_SIZE*ENDING_SIZE*ELEMENT_SIZE-1:0] o_featuremap,  // Maximum size of resulting feature_map, 6x6 of 8-bit depth
    output reg done
); 

localparam WINDOW_SIZE = STARTING_SIZE / ENDING_SIZE; // 26 / 2 = 13

// register to act as an array
reg [ENDING_SIZE*ENDING_SIZE*ELEMENT_SIZE-1:0] feature_map = 0;

// counters used later
reg [5:0] row_index, column_index, element_index;
reg [2:0] element_column, element_row;
reg [ELEMENT_SIZE-1 : 0] element_max;
reg [ENDING_SIZE-1:0] output_index; // Max value of output index is ENDING_SIZE*ENDING_SIZE*ELEMENT_SIZE-1
reg [STARTING_SIZE - 1:0] image_index; // Max value of image index is STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE - 1

always @(posedge clk or posedge rst) begin
    // implement positive rst logic
    if (rst) begin
        o_featuremap <= 0;
        feature_map <= 0;
	    done <= 0;
    end else if (en && !done) begin
        for (row_index = 0; row_index < ENDING_SIZE; row_index = row_index + 1) begin
            for (column_index = 0; column_index < ENDING_SIZE; column_index = column_index + 1) begin
                element_max = 0;
                // Iterate over the window to find the max
                for (element_index = 0; element_index < WINDOW_SIZE*WINDOW_SIZE; element_index = element_index + 1) begin
                    element_column = patch_element % WINDOW_SIZE; // the elements column
                    element_row = patch_element / WINDOW_SIZE; // the elements row
                    image_index = (element_row * (STARTING_SIZE * ELEMENT_SIZE)) + (element_column * ELEMENT_SIZE) + ELEMENT_SIZE - 1; // The upper index of this pixel in the input image
                            
                    if(i_featuremap[image_index -: ELEMENT_SIZE] > element_max) begin
                        element_max = i_featuremap[image_index -: ELEMENT_SIZE];
                    end
                end
                
            output_index = row_index*ENDING_SIZE*ELEMENT_SIZE + column_index*ELEMENT_SIZE + ELEMENT_SIZE - 1;
        
            // assign the summations to the featuremap
            $display("row_index: %d, column_index: %d, max: %d", row_index, column_index, element_max);
            feature_map[output_index -: ELEMENT_SIZE] = element_max;
            end // of a column
        end // of a row
        
        o_featuremap <= feature_map;
	    done <= 1;
    end
end

endmodule

