`timescale  1ps / 1ps

module maxpool_tb#(
    parameter STARTING_SIZE = 26, // this is the initial height & width
    parameter ELEMENT_SIZE = 20,
    parameter ENDING_SIZE = 2, // According to the python reference
)();

reg clk, rst, en;
reg [STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE-1:0] i_featuremap;
wire [ENDING_SIZE*ENDING_SIZE*ELEMENT_SIZE-1:0] o_featuremap;
wire done;

maxpool uut(
    .clk(clk),
    .rst(rst),
    .en(en),
    .i_featuremap(i_featuremap),
    .o_featuremap(o_featuremap),
    .done(done)
);

localparam i_feature_size = STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE;
localparam o_feature_size = ENDING_SIZE*ENDING_SIZE*ELEMENT_SIZE;
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
reg[ELEMENT_SIZE-1:0] pixel;
reg[5:0] i, j;

initial begin

    // ----- CREATE IMAGE ----- //
    example_image <= 0;
    // create alternating horizontal lines
    for (row = 0; row < STARTING_SIZE; row = row + 1) begin
        if (row < STARTING_SIZE / ENDING_SIZE) begin // every 3 rows
            example_image[i_feature_size - 1 -(row*i_row_size) -: i_row_size] <= {
			8'h01, 8'h02, 8'h03, 8'h04,
			8'h05, 8'h06, 8'h07, 8'h08,
			8'h09, 8'h0A, 8'h0B, 8'h0C,
			8'h0D, 8'h0E, 8'h0F, 8'h10,
			8'h11, 8'h12, 8'h13, 8'h14,
			8'h15, 8'h16, 8'h17, 8'h18,
			8'h19, 8'h1A};
        end
        else begin
            example_image[i_feature_size-1-(row*i_row_size) -: i_row_size] <= 1;
        end
    end 

    #1

    // test signals
    #5 rst = 0;
    en = 0;
    #5 rst = 1;
    #5 rst = 0;
    #5 i_featuremap = example_image;
    #5 en = 1;

    wait(done);
    for(i = 0; i < ENDING_SIZE; i = i + 1) begin
        for(j = 0; j < ENDING_SIZE; j = j + 1) begin
            $display("output[%d][%d]: %d",i, j, o_featuremap[i*ENDING_SIZE*ELEMENT_SIZE+ELEMENT_SIZE*(j + 1)-1-: ELEMENT_SIZE] );
        end
    end
    #400 $finish;
end

endmodule

