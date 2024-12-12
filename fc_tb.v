`timescale  1ps / 1ps

module fc_tb#(
    parameter STARTING_SIZE = 2, // this is the initial height & width
    parameter ELEMENT_SIZE = 20,
    parameter WEIGHT_DEPTH = 8,
    parameter CLASSIFICATIONS = 10,
    parameter ENDING_ELEMENT_SIZE = 30
)();


reg   clk, rst, en;
reg  [(STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE)-1:0] i_featuremap;
reg  [STARTING_SIZE*STARTING_SIZE*CLASSIFICATIONS*WEIGHT_DEPTH-1:0] weights;
wire [CLASSIFICATIONS*ENDING_ELEMENT_SIZE-1:0] o_featuremap;
wire done;

fc uut(
    .clk(clk),
    .rst(rst),
    .en(en),
    .weights(weights),
    .i_featuremap(i_featuremap),
    .o_featuremap(o_featuremap),
    .done(done)
);

localparam i_feature_size = STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE;
localparam o_feature_size = CLASSIFICATIONS*ENDING_ELEMENT_SIZE;
localparam i_row_size = STARTING_SIZE*ELEMENT_SIZE;

// clock generator
initial begin
    clk = 0;
    forever #1 clk = ~clk; // toggle the clk
end


integer row, col, class_index, i ,j;
reg[i_feature_size-1:0] example_input;

initial begin

    example_input <= 0;
    // Weights are arranged as a flattened version of weights[row_node][col_node][classification]. i.e. from starting node to ending node
    for (row = 0; row < STARTING_SIZE; row = row + 1) begin
        for(col = 0; col < STARTING_SIZE; col = col + 1) begin
            example_input[row*STARTING_SIZE*ELEMENT_SIZE + col*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE] <= (10); // TODO: change this to a more complicated case later
             for (class_index = 0; class_index < CLASSIFICATIONS; class_index = class_index + 1) begin
                weights[(row*STARTING_SIZE + col)*WEIGHT_DEPTH + class_index*WEIGHT_DEPTH + WEIGHT_DEPTH - 1 -: WEIGHT_DEPTH] <= class_index == 2 ? 10 : 0; // TODO: change this to a more complicated case later
            end
        end
    end

    // test signals
    #5 rst = 0;
    en = 0;
    #5 rst = 1;
    #5 rst = 0;
    #5 i_featuremap = example_input;
    #5 en = 1;

    wait(done);
    for(i = 0; i < CLASSIFICATIONS; i = i + 1) begin
        $display("output[%d]: %d",i, o_featuremap[i*CLASSIFICATIONS*ENDING_ELEMENT_SIZE+ENDING_ELEMENT_SIZE*(j + 1)-1-: ENDING_ELEMENT_SIZE] );
    end
    #400 $finish;
end

endmodule

