`timescale  1ps / 1ps

module maxpool_tb#(
    parameter STARTING_SIZE = 26, // this is the initial height & width
    parameter ELEMENT_SIZE = 20,
    parameter ENDING_SIZE = 2 // According to the python reference
)();


reg   clk, rst, en;
reg  [STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE-1:0] i_featuremap;
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


integer row, col;
reg[i_feature_size-1:0] example_image;
reg[5:0] i, j;

initial begin

    // ----- CREATE IMAGE ----- //
    example_image <= 0;
   
    for (row = 0; row < STARTING_SIZE; row = row + 1) begin
        for(col = 0; col < STARTING_SIZE; col = col + 1) begin
            example_image[row*STARTING_SIZE*ELEMENT_SIZE + col*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE] <= (row + col);
	    end
    end 

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

