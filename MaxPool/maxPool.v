// This module calculates the maximum value of a region of an input array. 
// The input array is of size 6x6 and the window size is 2x2 with a stride of 2.
// The output array is of size 3x3.

// Both input and output arrays have a depth of 9 to store the correlation found
// in the first convolutoinal layer. We may need to adjust these comparisons to account
// for signed values.

`timescale 1ns / 1ps

module maxPool6x6 #(
    parameter DATA_WIDTH = 10 // TODO: change to 12, assuming two convolutional layers before this max pool
)(
    input clk,
    input enable,
    output reg done,

    // Row 0
    input signed [DATA_WIDTH - 1:0] in_0_0,
    input signed [DATA_WIDTH - 1:0] in_0_1,
    input signed [DATA_WIDTH - 1:0] in_0_2,
    input signed [DATA_WIDTH - 1:0] in_0_3,
    input signed [DATA_WIDTH - 1:0] in_0_4,
    input signed [DATA_WIDTH - 1:0] in_0_5,

    // Row 1
    input signed [DATA_WIDTH - 1:0] in_1_0,
    input signed [DATA_WIDTH - 1:0] in_1_1,
    input signed [DATA_WIDTH - 1:0] in_1_2,
    input signed [DATA_WIDTH - 1:0] in_1_3,
    input signed [DATA_WIDTH - 1:0] in_1_4,
    input signed [DATA_WIDTH - 1:0] in_1_5,

    // Row 2
    input signed [DATA_WIDTH - 1:0] in_2_0,
    input signed [DATA_WIDTH - 1:0] in_2_1,
    input signed [DATA_WIDTH - 1:0] in_2_2,
    input signed [DATA_WIDTH - 1:0] in_2_3,
    input signed [DATA_WIDTH - 1:0] in_2_4,
    input signed [DATA_WIDTH - 1:0] in_2_5,

    // Row 3
    input signed [DATA_WIDTH - 1:0] in_3_0,
    input signed [DATA_WIDTH - 1:0] in_3_1,
    input signed [DATA_WIDTH - 1:0] in_3_2,
    input signed [DATA_WIDTH - 1:0] in_3_3,
    input signed [DATA_WIDTH - 1:0] in_3_4,
    input signed [DATA_WIDTH - 1:0] in_3_5,

    // Row 4
    input signed [DATA_WIDTH - 1:0] in_4_0,
    input signed [DATA_WIDTH - 1:0] in_4_1,
    input signed [DATA_WIDTH - 1:0] in_4_2,
    input signed [DATA_WIDTH - 1:0] in_4_3,
    input signed [DATA_WIDTH - 1:0] in_4_4,
    input signed [DATA_WIDTH - 1:0] in_4_5,

    // Row 5
    input signed [DATA_WIDTH - 1:0] in_5_0,
    input signed [DATA_WIDTH - 1:0] in_5_1,
    input signed [DATA_WIDTH - 1:0] in_5_2,
    input signed [DATA_WIDTH - 1:0] in_5_3,
    input signed [DATA_WIDTH - 1:0] in_5_4,
    input signed [DATA_WIDTH - 1:0] in_5_5,

    // Row 0 of output array
    output reg signed [DATA_WIDTH - 1:0] out_0_0,
    output reg signed [DATA_WIDTH - 1:0] out_0_1,
    output reg signed [DATA_WIDTH - 1:0] out_0_2,

    // Row 1 of output array
    output reg signed [DATA_WIDTH - 1:0] out_1_0,
    output reg signed [DATA_WIDTH - 1:0] out_1_1,
    output reg signed [DATA_WIDTH - 1:0] out_1_2,

    // Row 2 of output array
    output reg signed [DATA_WIDTH - 1:0] out_2_0,
    output reg signed [DATA_WIDTH - 1:0] out_2_1,
    output reg signed [DATA_WIDTH - 1:0] out_2_2
);

parameter IDLE = 2'b00, CALC_MAX_ROW = 2'b01, CALC_MAX_REGION = 2'b10, DONE = 2'b11;
reg [1:0] state; 
reg [DATA_WIDTH - 1:0] max_per_slide [5:0][2:0]; // Intermediate max for each slide in a row

always@(posedge clk) begin
    if(enable) begin
        case(state)
            IDLE: begin
                state <= CALC_MAX_ROW;
                done <= 0;
            end
            CALC_MAX_ROW: begin
                max_per_slide[0][0] <= (in_0_0 > in_0_1) ? in_0_0 : in_0_1;
                max_per_slide[0][1] <= (in_0_2 > in_0_3) ? in_0_2 : in_0_3;
                max_per_slide[0][2] <= (in_0_4 > in_0_5) ? in_0_4 : in_0_5;
                max_per_slide[1][0] <= (in_1_0 > in_1_1) ? in_1_0 : in_1_1;
                max_per_slide[1][1] <= (in_1_2 > in_1_3) ? in_1_2 : in_1_3;
                max_per_slide[1][2] <= (in_1_4 > in_1_5) ? in_1_4 : in_1_5;
                max_per_slide[2][0] <= (in_2_0 > in_2_1) ? in_2_0 : in_2_1;
                max_per_slide[2][1] <= (in_2_2 > in_2_3) ? in_2_2 : in_2_3;
                max_per_slide[2][2] <= (in_2_4 > in_2_5) ? in_2_4 : in_2_5;
                max_per_slide[3][0] <= (in_3_0 > in_3_1) ? in_3_0 : in_3_1;
                max_per_slide[3][1] <= (in_3_2 > in_3_3) ? in_3_2 : in_3_3;
                max_per_slide[3][2] <= (in_3_4 > in_3_5) ? in_3_4 : in_3_5;
                max_per_slide[4][0] <= (in_4_0 > in_4_1) ? in_4_0 : in_4_1;
                max_per_slide[4][1] <= (in_4_2 > in_4_3) ? in_4_2 : in_4_3;
                max_per_slide[4][2] <= (in_4_4 > in_4_5) ? in_4_4 : in_4_5;
                max_per_slide[5][0] <= (in_5_0 > in_5_1) ? in_5_0 : in_5_1;
                max_per_slide[5][1] <= (in_5_2 > in_5_3) ? in_5_2 : in_5_3;
                max_per_slide[5][2] <= (in_5_4 > in_5_5) ? in_5_4 : in_5_5;

                state <= CALC_MAX_REGION;
            end
            CALC_MAX_REGION: begin
                // Compare top two rows of slide maxes
                out_0_0 <= (max_per_slide[0][0] > max_per_slide[1][0]) ? max_per_slide[0][0] : max_per_slide[1][0];
                out_0_1 <= (max_per_slide[0][1] > max_per_slide[1][1]) ? max_per_slide[0][1] : max_per_slide[1][1];
                out_0_2 <= (max_per_slide[0][2] > max_per_slide[1][2]) ? max_per_slide[0][2] : max_per_slide[1][2];
                // Compare middle two rows of slide maxes
                out_1_0 <= (max_per_slide[2][0] > max_per_slide[3][0]) ? max_per_slide[2][0] : max_per_slide[3][0];
                out_1_1 <= (max_per_slide[2][1] > max_per_slide[3][1]) ? max_per_slide[2][1] : max_per_slide[3][1];
                out_1_2 <= (max_per_slide[2][2] > max_per_slide[3][2]) ? max_per_slide[2][2] : max_per_slide[3][2];
                // Compare bottom two rows of slide maxes
                out_2_0 <= (max_per_slide[4][0] > max_per_slide[5][0]) ? max_per_slide[4][0] : max_per_slide[5][0];
                out_2_1 <= (max_per_slide[4][1] > max_per_slide[5][1]) ? max_per_slide[4][1] : max_per_slide[5][1];
                out_2_2 <= (max_per_slide[4][2] > max_per_slide[5][2]) ? max_per_slide[4][2] : max_per_slide[5][2];

                state <= DONE;
                done <= 1;
            end
            DONE: begin
                state <= IDLE;
            end
        endcase
    end
end



endmodule


/* `timescale 1ns / 1ps

module maxPool6x6(
    input clk,
    input enable, // Unfortunately, we can't pass a 6x6 array directly
    input [8:0] input_array[5:0][5:0], // 6x6, 8 bit wide input array
    output reg [8:0] output_max[2:0][2:0], // 3x3, 8 bit wide output array
    output reg done
);

parameter IDLE = 2'b00, CALC_MAX_ROW = 2'b01, CALC_MAX_REGION = 2'b10, DONE = 2'b11;
reg [1:0] state; 
reg [7:0] max_per_slide [5:0][2:0]; // Intermediate max for each slide in a row

always@(posedge clk) begin
    if(enable) begin
        case(state)
            IDLE: begin
                state <= CALC_MAX_ROW;
                done <= 0;
            end
            CALC_MAX_ROW: begin
                max_per_slide[0][0] <= (input_array[0][0] > input_array[0][1]) ? input_array[0][0] : input_array[0][1];
                max_per_slide[0][1] <= (input_array[0][2] > input_array[0][3]) ? input_array[0][2] : input_array[0][3];
                max_per_slide[0][2] <= (input_array[0][4] > input_array[0][5]) ? input_array[0][4] : input_array[0][5];
                max_per_slide[1][0] <= (input_array[1][0] > input_array[1][1]) ? input_array[1][0] : input_array[1][1];
                max_per_slide[1][1] <= (input_array[1][2] > input_array[1][3]) ? input_array[1][2] : input_array[1][3];
                max_per_slide[1][2] <= (input_array[1][4] > input_array[1][5]) ? input_array[1][4] : input_array[1][5];
                max_per_slide[2][0] <= (input_array[2][0] > input_array[2][1]) ? input_array[2][0] : input_array[2][1];
                max_per_slide[2][1] <= (input_array[2][2] > input_array[2][3]) ? input_array[2][2] : input_array[2][3];
                max_per_slide[2][2] <= (input_array[2][4] > input_array[2][5]) ? input_array[2][4] : input_array[2][5];
                max_per_slide[3][0] <= (input_array[3][0] > input_array[3][1]) ? input_array[3][0] : input_array[3][1];
                max_per_slide[3][1] <= (input_array[3][2] > input_array[3][3]) ? input_array[3][2] : input_array[3][3];
                max_per_slide[3][2] <= (input_array[3][4] > input_array[3][5]) ? input_array[3][4] : input_array[3][5];
                max_per_slide[4][0] <= (input_array[4][0] > input_array[4][1]) ? input_array[4][0] : input_array[4][1];
                max_per_slide[4][1] <= (input_array[4][2] > input_array[4][3]) ? input_array[4][2] : input_array[4][3];
                max_per_slide[4][2] <= (input_array[4][4] > input_array[4][5]) ? input_array[4][4] : input_array[4][5];
                max_per_slide[5][0] <= (input_array[5][0] > input_array[5][1]) ? input_array[5][0] : input_array[5][1];
                max_per_slide[5][1] <= (input_array[5][2] > input_array[5][3]) ? input_array[5][2] : input_array[5][3];
                max_per_slide[5][2] <= (input_array[5][4] > input_array[5][5]) ? input_array[5][4] : input_array[5][5];

                state <= CALC_MAX_REGION;
            end
            CALC_MAX_REGION: begin
                // Compare top two rows of slide maxes
                output_max[0][0] <= (max_per_slide[0][0] > max_per_slide[1][0]) ? max_per_slide[0][0] : max_per_slide[1][0];
                output_max[0][1] <= (max_per_slide[0][1] > max_per_slide[1][1]) ? max_per_slide[0][1] : max_per_slide[1][1];
                output_max[0][2] <= (max_per_slide[0][2] > max_per_slide[1][2]) ? max_per_slide[0][2] : max_per_slide[1][2];
                // Compare middle two rows of slide maxes
                output_max[1][0] <= (max_per_slide[2][0] > max_per_slide[3][0]) ? max_per_slide[2][0] : max_per_slide[3][0];
                output_max[1][1] <= (max_per_slide[2][1] > max_per_slide[3][1]) ? max_per_slide[2][1] : max_per_slide[3][1];
                output_max[1][2] <= (max_per_slide[2][2] > max_per_slide[3][2]) ? max_per_slide[2][2] : max_per_slide[3][2];
                // Compare bottom two rows of slide maxes
                output_max[2][0] <= (max_per_slide[4][0] > max_per_slide[5][0]) ? max_per_slide[4][0] : max_per_slide[5][0];
                output_max[2][1] <= (max_per_slide[4][1] > max_per_slide[5][1]) ? max_per_slide[4][1] : max_per_slide[5][1];
                output_max[2][2] <= (max_per_slide[4][2] > max_per_slide[5][2]) ? max_per_slide[4][2] : max_per_slide[5][2];

                state <= DONE;
                done <= 1;
            end
            DONE: begin
                state <= IDLE;
            end
        endcase
    end
end



endmodule */