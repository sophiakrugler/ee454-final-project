// Fully connect layer
`timescale  1ps / 1ps

module fc#(
    parameter STARTING_SIZE = 2, // this is the initial height & width
    parameter ELEMENT_SIZE = 20,
    parameter WEIGHT_DEPTH = 8,
    parameter CLASSIFICATIONS = 10,
    parameter ENDING_ELEMENT_SIZE = 30 // element size + weight size + 2 since we have to sum the products
    )(
    //input wires for a feature map
    input wire clk,
    input wire rst,
    input wire en,
    input wire [(STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE)-1:0] i_featuremap,
    input wire [STARTING_SIZE*STARTING_SIZE*CLASSIFICATIONS*WEIGHT_DEPTH-1:0] weights,  // For a 2x2 input an d10 classifications, there should be 40 weights
    output reg [CLASSIFICATIONS*ENDING_ELEMENT_SIZE-1:0] o_featuremap,  // Output is a 1 dimensional vector of the value for each classification
    output reg done
);

reg [5:0] row_index, column_index, weight_index;
reg [WEIGHT_DEPTH-1:0] weight;
reg [ELEMENT_SIZE-1 : 0] element;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        o_featuremap <= 0;
	    done <= 0;
    end else if (en && !done) begin
        for (row_index = 0; row_index < STARTING_SIZE; row_index = row_index + 1) begin
            for (column_index = 0; column_index < STARTING_SIZE; column_index = column_index + 1) begin
                element = i_featuremap[row_index*STARTING_SIZE*ELEMENT_SIZE + column_index*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE];
                for (weight_index = 0; weight_index < CLASSIFICATIONS; weight_index = weight_index + 1) begin
                    weight = weights[(row_index*STARTING_SIZE*CLASSIFICATIONS + column_index*CLASSIFICATIONS + weight_index + 1)*WEIGHT_DEPTH - 1 -: WEIGHT_DEPTH];
                    o_featuremap[weight_index*ENDING_ELEMENT_SIZE + ENDING_ELEMENT_SIZE - 1 -: ENDING_ELEMENT_SIZE] = o_featuremap[weight_index*ENDING_ELEMENT_SIZE + ENDING_ELEMENT_SIZE - 1 -: ENDING_ELEMENT_SIZE] + element * weight;
                    $display("weight index: %d, weight value: %d, element value: %d, new output value for classification %d: %d", weight_index, weight, element, weight_index, o_featuremap[weight_index*ENDING_ELEMENT_SIZE + ENDING_ELEMENT_SIZE - 1 -: ENDING_ELEMENT_SIZE]);
                end
            end // of a column
        end // of a row
	    done <= 1;
    end
end

endmodule

