// This module calculates the maximum value of a region of an input array. 
// The input array is of size 6x6 and the window size is 2x2 with a stride of 2.
// The output array is of size 3x3.

// Both input and output arrays have a depth of 8 to store the correlation found
// in the first convolutoinal layer. We may need to adjust these comparisons to account
// for signed values.

`timescale 1ns / 1ps

module maxPool6x6(
    input clk,
    input enable,
    input [7:0] input_array[5:0][5:0], // 6x6, 8 bit wide input array
    output reg [7:0] output_max[2:0][2:0], // 3x3, 8 bit wide output array
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
            end
            DONE: begin
                done <= 1;
            end
        endcase
    end else begin
        state <= IDLE;
        done <= 0;
    end
end



endmodule