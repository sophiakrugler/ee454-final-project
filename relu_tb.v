`timescale  1ps / 1ps

module relu_tb#(
    parameter CLASSIFICATIONS = 10,
    parameter ELEMENT_SIZE = 30,
    parameter NORMALIZED_SIZE = 25 // 25 bits for normalized results
)();


reg   clk, rst, en;
reg  [(CLASSIFICATIONS*ELEMENT_SIZE)-1:0] fc_results;
wire [CLASSIFICATIONS-1:0] class_hotcoded;
wire [4:0] class_encoded;
wire [(CLASSIFICATIONS*NORMALIZED_SIZE)-1:0] normalized_results;
wire done;

relu uut(
    .clk(clk),
    .rst(rst),
    .en(en),
    .fc_results(fc_results),
    .class_hotcoded(class_hotcoded),
    .class_encoded(class_encoded),
    .normalized_results(normalized_results),
    .done(done)
);

// clock generator
initial begin
    clk = 0;
    forever #1 clk = ~clk; // toggle the clk
end


integer fc_index, class_index, i ,j;
reg[(CLASSIFICATIONS*ELEMENT_SIZE)-1:0] example_fc_results;

initial begin
    example_fc_results <= 0;
    // Weights are arranged as a flattened version of weights[row_node][col_node][classification]. i.e. from starting node to ending node
    for (fc_index = 0; fc_index < CLASSIFICATIONS; fc_index = fc_index + 1) begin
        example_fc_results[fc_index*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE] <= 1000 - fc_index*100;
    end

    // test signals
    #5 rst = 0;
    en = 0;
    #5 rst = 1;
    #5 rst = 0;
    #5 fc_results = example_fc_results;
    #5 en = 1;

    wait(done);
    $display("classification: %d", class_encoded);
    for(i = 0; i < CLASSIFICATIONS; i = i + 1) begin
	    $display("Classification %d? %d", i, class_hotcoded[i]);
        $display("input[%d}: %d normalized to output[%d]: %d",i, example_fc_results[i*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE], i, normalized_results[i*NORMALIZED_SIZE + NORMALIZED_SIZE - 1 -: NORMALIZED_SIZE]);
    end
    #400 $finish;
end

endmodule

