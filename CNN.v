`timescale 1ns/100ps

module CCN #(parameter DATA_WIDTH = 8) (
    input wire clk,
    input wire rst_,  // Active-low reset
    input wire [DATA_WIDTH-1:0] data,
    output reg [9:0] out //for example, one hot encoding of 10 classes? 
);

always @(posedge clk or negedge rst_) begin
    if (!rst_) begin
        out <= 10'b0000_0000_00;  // Reset the output when reset is low
    end
    else begin
        //make the convolution and pooling layers
        
        //eventually check output
        out <= 10'b0001_0000_00;
    end
end

endmodule
