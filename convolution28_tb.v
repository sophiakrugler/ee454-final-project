`timescale  1ps / 1ps

module convolution28_tb#(
    parameter STARTING_SIZE = 28, // this is the initial height & width
    parameter WINDOW_SIZE = 3,    // this is the height & width of the window
    parameter ELEMENT_SIZE = 8, // TODO: add kernel element size
    parameter ENDING_SIZE = 26, // starting size - window size + 1
    parameter ENDING_ELEMENT_SIZE = 20
)();

reg clk, rst, en;
reg [STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE-1:0] i_featuremap;
reg [WINDOW_SIZE*WINDOW_SIZE*ELEMENT_SIZE-1:0] kernel;
wire [ENDING_SIZE*ENDING_SIZE*ENDING_ELEMENT_SIZE-1:0] o_featuremap;
wire done;



convolution28 uut(
    .clk(clk),
    .rst(rst),
    .en(en),
    .i_featuremap(i_featuremap),
    .kernel(kernel),
    .o_featuremap(o_featuremap),
    .done(done)
);

localparam i_feature_size = STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE;
localparam kernel_size = WINDOW_SIZE*WINDOW_SIZE*ELEMENT_SIZE;
localparam o_feature_size = ENDING_SIZE*ENDING_SIZE*ENDING_ELEMENT_SIZE;
localparam i_row_size = STARTING_SIZE*ELEMENT_SIZE;

// clock generator
initial begin
    clk = 0;
    forever #1 clk = ~clk; // toggle the clk
end

// Monitor for output feature map
always @(o_featuremap) begin
    // $display("[%0t] o_featuremap changed: %h", $time, o_featuremap);
end

always @(i_featuremap) begin
    // $display("[%0t] i_featuremap changed: %h", $time, i_featuremap);
end

integer row;
reg[i_feature_size-1:0] example_image;
reg[kernel_size-1:0] example_kernel;
reg[ELEMENT_SIZE-1:0] pixel;
reg[5:0] i, j;

initial begin

    // ----- CREATE IMAGE ----- //
    example_image <= 0;
    // create alternating horizontal lines
    for (row = 0; row < STARTING_SIZE; row = row + 1) begin
        if (row % 3 == 0) begin // every 3 rows
            example_image[i_feature_size - 1 -(row*i_row_size) -: i_row_size] <= {
			8'h01, 8'h01, 8'h01, 8'h01,
			8'h01, 8'h01, 8'h01, 8'h01,
			8'h01, 8'h01, 8'h01, 8'h01,
			8'h01, 8'h01, 8'h01, 8'h01,
			8'h01, 8'h01, 8'h01, 8'h01,
			8'h01, 8'h01, 8'h01, 8'h01,
			8'h01, 8'h01, 8'h01, 8'h01}; // every 3rd row is dark
		$display("input image[%d] is a row of %d ones", row, STARTING_SIZE);
        end
        else begin
            example_image[i_feature_size-1-(row*i_row_size) -: i_row_size] <= 0;
	    $display("input image[%d] is a row of %d zeros", row, STARTING_SIZE);
        end
    end 

    #1

    // ----- DEFINE KERNEL ----- //
    example_kernel <= 0;
    for (pixel = 0; pixel < 9; pixel = pixel +1) begin
        example_kernel[kernel_size-(pixel*ELEMENT_SIZE)-1-: ELEMENT_SIZE] <= pixel; 
    end

    #1

    // test signals
    #5 rst = 0;
    en = 0;
    #5 rst = 1;
    #5 rst = 0;
    #5 i_featuremap = example_image;
    kernel = example_kernel;
    for(i = 0; i < WINDOW_SIZE; i = i + 1) begin
        for(j = 0; j < WINDOW_SIZE; j = j + 1) begin
            $display("kernel[%d][%d]: %d",i, j, kernel[i*3*ELEMENT_SIZE+j*ELEMENT_SIZE + ELEMENT_SIZE-1 -: ELEMENT_SIZE]);
        end
    end
    
    #5 en = 1;

    wait(done);
    for(i = 0; i < ENDING_SIZE; i = i + 1) begin
        for(j = 0; j < ENDING_SIZE; j = j + 1) begin
            $display("output[%d][%d]: %d",i, j, o_featuremap[i*ENDING_SIZE*ENDING_ELEMENT_SIZE+ENDING_ELEMENT_SIZE*(j + 1)-1-: ENDING_ELEMENT_SIZE] );
        end
    end
    #400 $finish;
end

endmodule

