`timescale  1ps / 1ps

module convolution8_tb(
    output reg clk, rst,
    output reg [511:0] i_featuremap,
    output reg [71:0] kernel,
    input reg [287:0] o_featuremap
);

convolution8 uut(
    .clk(clk),
    .rst(rst),
    .i_featuremap(i_featuremap),
    .kernel(kernel),
    .o_featuremap(o_featuremap)
);

// clock generator
initial begin
    clk = 0;
    forever #1 clk = ~clk; // toggle the clk
end

// Monitor for output feature map
always @(o_featuremap) begin
    $display("[%0t] o_featuremap changed: %h", $time, o_featuremap);
end

always @(i_featuremap) begin
    $display("[%0t] i_featuremap changed: %h", $time, i_featuremap);
end

reg [511:0] example_image;
reg [71:0]  example_kernel;
integer row, pixel;

initial begin

    // ----- CREATE IMAGE ----- //
    example_image <= 0;
    // create alternating horizontal lines
    for (row = 0; row < 8; row = row + 1) begin
        if (row % 3 == 0) begin // every 3 rows
            example_image[511-(row*64) -: 64] <= {8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF}; // every 3rd row is dark
        end
        else begin
            example_image[511-(row*64) -: 64] <= {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
        end
    end 

    #1

    // ----- DEFINE KERNEL ----- //
    example_kernel <= 0;
    for (pixel = 0; pixel < 9; pixel = pixel +1) begin
        example_kernel[71-(pixel*8) -: 8] <= pixel;
    end

    #1

    // test signals
    #5 rst = 0;
    #5 rst = 1;
    #5 rst = 0;
    #5 i_featuremap = example_image;
    kernel = example_kernel;
    #40 $finish;
end

endmodule