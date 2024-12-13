
// Fully connect layer
module relu#(
    parameter CLASSIFICATIONS = 10,
    parameter ELEMENT_SIZE = 30,
    parameter NORMALIZED_SIZE = 25 // 25 bits for normalized results
)(
    //input wires for a feature map
    input wire clk,
    input wire rst,
    input wire en,
    input wire [(CLASSIFICATIONS*ELEMENT_SIZE)-1:0] fc_results,
    output reg [CLASSIFICATIONS-1:0] class_hotcoded,
    output reg [4:0] class_encoded,
    output reg [(CLASSIFICATIONS*NORMALIZED_SIZE)-1:0] normalized_results, // For error calculation and back propagation
    output reg done
);

reg [4:0] index;
reg [4:0] max_index;
reg done_relu;
reg [ELEMENT_SIZE-1:0] max_value;
reg [ELEMENT_SIZE - NORMALIZED_SIZE - 1:0] normalized_cutoff = 5'b11111;
wire [CLASSIFICATIONS-1:0] class_hotcoded_wire;
reg [ELEMENT_SIZE -1:0] unnormal_element;
reg [NORMALIZED_SIZE-1:0] normal_element;

// Decode the max index
assign class_hotcoded_wire[0] = (max_index == 0) ? 1 : 0;
assign class_hotcoded_wire[1] = (max_index == 1) ? 1 : 0;
assign class_hotcoded_wire[2] = (max_index == 2) ? 1 : 0;
assign class_hotcoded_wire[3] = (max_index == 3) ? 1 : 0;
assign class_hotcoded_wire[4] = (max_index == 4) ? 1 : 0;
assign class_hotcoded_wire[5] = (max_index == 5) ? 1 : 0;
assign class_hotcoded_wire[6] = (max_index == 6) ? 1 : 0;
assign class_hotcoded_wire[7] = (max_index == 7) ? 1 : 0;
assign class_hotcoded_wire[8] = (max_index == 8) ? 1 : 0;
assign class_hotcoded_wire[9] = (max_index == 9) ? 1 : 0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        class_hotcoded <= 0;
        normalized_results <= 0;
	    done <= 0;
        done_relu <= 0;
	    max_value <= 0;
    end else if (en && !done_relu) begin
        for (index = 0; index < CLASSIFICATIONS; index = index + 1) begin
            // Find max
            if(fc_results[index*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE] > max_value) begin
                max_value = fc_results[index*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE];
                max_index = index;
            end
            // Normalize
            unnormal_element = fc_results[index*ELEMENT_SIZE + ELEMENT_SIZE - 1 -: ELEMENT_SIZE];
            if (unnormal_element > normalized_cutoff) begin
                normal_element = unnormal_element >> (ELEMENT_SIZE-NORMALIZED_SIZE); // Right shift by 5 bits
                normalized_results[index*NORMALIZED_SIZE + NORMALIZED_SIZE - 1 -: NORMALIZED_SIZE] = normal_element;
            end else begin
                normalized_results[index*NORMALIZED_SIZE + NORMALIZED_SIZE - 1 -: NORMALIZED_SIZE] = 0;
            end
        end
	    done_relu <= 1;
    end else if (en && done_relu) begin
        class_hotcoded <= class_hotcoded_wire;
        class_encoded <= max_index;
        done <= 1;
    end
end

endmodule
