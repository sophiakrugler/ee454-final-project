// This module calculates the convolution of an 8x8 image and spits out a 6x6
// by running a 3x3 kernel over it. The data depth is TBD.

`timescale 1ns / 1ps

module convolutionTwo #(
    parameter DATA_WIDTH_IN = 10 // TODO: adjust these once we figure out the kernel magnitudes
    parameter DATA_WIDTH_KERNEL = 4; // Signed value. Max value is 2^3 - 1 = 7. Min is -8. TODO: adjust after deciding on backprop method.
    parameter DATA_WIDTH_OUT = 12
)(
    input clk,
    input enable,
    output reg done,

    // flattened image input.
    input signed in[(DATA_WIDTH_IN * 8 * 8) - 1: 0],
    // flattened Kernel input
    input signed kernel[(DATA_WIDTH_KERNEL * 3 * 3) - 1: 0],

    // flattened output
    output reg signed out[(DATA_WIDTH_OUT * 6 * 6) - 1: 0]
);

// TODO: adjust states as needed
parameter IDLE = 2'b00, CALC_CONVOLUTION = 2'b01, DONE = 2'b11;
reg [1:0] state; 

always@(posedge clk) begin
    if(enable) begin
        case(state)
            IDLE: begin
                state <= CALC_CONVOLUTION;
                done <= 0;
            end
            CALC_CONVOLUTION: begin
                // TODO: do work
                state <= DONE;
            end
            DONE: begin
                state <= IDLE;
            end
        endcase
    end
end



endmodule