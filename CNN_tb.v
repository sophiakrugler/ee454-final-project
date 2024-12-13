`timescale  1ps / 1ps

module CNN_tb#(
    parameter IMAGE_SIZE = 28, // The starting height & width of the input image
    parameter PIXEL_DEPTH = 8, // The depth of each pixel of the input image
    parameter WINDOW_SIZE = 3, // this is the height & width of the window/kernel
    parameter CONV_IMAGE_SIZE = 26, // The size of the convoluted image
    parameter CONV_PIXEL_DEPTH = 20, // The depth of each pixel of the convoluted image
    parameter POOL_IMAGE_SIZE = 2, // The dimensions of the pooled image (2x2)
    parameter FC_WEIGHT_DEPTH = 8, // The depth of each weight in fully connect
    parameter CLASSIFICATIONS = 10, // Number of classifications
    parameter FC_RESULT_DEPTH = 30 // Depth of the output of fully connect layer
)();


reg   clk, rst; // CNN variables
wire [CLASSIFICATIONS-1:0] led;
wire done;

CNN uut(
    .clk(clk),
    .rst(rst),
	.led(led),
    .done(done)
);

// clock generator
initial begin
    clk = 0;
    forever #1 clk = ~clk; // toggle the clk
end

initial begin
    // test signals
    #5 rst = 0;
    #5 rst = 1;
    #5 rst = 0;

    wait(done);
    for(i = 0; i < CLASSIFICATIONS; i = i + 1) begin
        $display("led[%d]: %d",i, led[i]);
    end
    #400 $finish;
end

endmodule

