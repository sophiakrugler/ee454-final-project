

`timescale 1ns/100ps

module CNN_transmit#(
    parameter IMAGE_SIZE = 28, // The starting height & width of the input image
    parameter PIXEL_DEPTH = 8, // The depth of each pixel of the input image
    parameter WINDOW_SIZE = 3, // this is the height & width of the window/kernel
    parameter CONV_IMAGE_SIZE = 26, // The size of the convoluted image
    parameter CONV_PIXEL_DEPTH = 20, // The depth of each pixel of the convoluted image
    parameter POOL_IMAGE_SIZE = 2, // The dimensions of the pooled image (2x2)
    parameter FC_WEIGHT_DEPTH = 8, // The depth of each weight in fully connect
    parameter CLASSIFICATIONS = 10, // Number of classifications
    parameter FC_RESULT_DEPTH = 30 // Depth of the output of fully connect layer
    // TODO: add kernel depth parameter
) (
    input wire clk,
    input wire rst,  // Active-low reset
    output reg [CLASSIFICATIONS-1:0] led, //for one hot encoding of 10 classes
    output reg done,
    output reg [2:0] state  // States: 0 = idle, 1 = conv, 2 = pool, 3 = fc, 4 = relu, 5 = done
);

reg conv_rst, pool_rst, fc_rst, relu_rst;
reg conv_en, pool_en, fc_en, relu_en;
wire conv_done, pool_done, fc_done, relu_done;
reg [5:0] i, j, k; // for iterating
reg [7:0] expected_class;


reg [IMAGE_SIZE*IMAGE_SIZE*PIXEL_DEPTH-1:0] input_image; // TODO: consider adding another dimension for multiple images
reg [WINDOW_SIZE*WINDOW_SIZE*PIXEL_DEPTH-1:0] kernel;
reg [CONV_IMAGE_SIZE*CONV_IMAGE_SIZE*CONV_PIXEL_DEPTH-1:0] conv_image;
wire [CONV_IMAGE_SIZE*CONV_IMAGE_SIZE*CONV_PIXEL_DEPTH-1:0] conv_image_wire;
reg [POOL_IMAGE_SIZE*POOL_IMAGE_SIZE*CONV_PIXEL_DEPTH-1:0] pool_image;
wire [POOL_IMAGE_SIZE*POOL_IMAGE_SIZE*CONV_PIXEL_DEPTH-1:0] pool_image_wire;
reg [POOL_IMAGE_SIZE*POOL_IMAGE_SIZE*CLASSIFICATIONS*FC_WEIGHT_DEPTH-1:0] fc_weights;
reg [CLASSIFICATIONS*FC_RESULT_DEPTH-1:0] fc_result;
wire [CLASSIFICATIONS*FC_RESULT_DEPTH-1:0] fc_result_wire;
wire [CLASSIFICATIONS-1:0] relu_result;
wire[4:0] actual_class_wire;

reg [PIXEL_DEPTH-1:0] input_image_mem [IMAGE_SIZE*IMAGE_SIZE-1:0];
reg [7:0] expected_class_mem [1:0];



// Instantiate convolutional layer
convolution28 conv_layer (
    .clk(clk),
    .rst(conv_rst),
    .en(conv_en),
    .i_featuremap(input_image),
    .kernel(kernel),
    .o_featuremap(conv_image_wire),
    .done(conv_done)
);

// Instantiate max pooling layer
maxpool pool_layer (
    .clk(clk),
    .rst(pool_rst),
    .en(pool_en),
    .i_featuremap(conv_image),
    .o_featuremap(pool_image_wire),
    .done(pool_done)
);

// Instantiate fully connect layer
fc fc_layer (
    .clk(clk),
    .rst(fc_rst),
    .en(fc_en),
    .i_featuremap(pool_image),
    .weights(fc_weights),
    .o_featuremap(fc_result_wire),
    .done(fc_done)
);

// Instantiate relu layer
relu relu_layer (
    .clk(clk),
    .rst(relu_rst),
    .en(relu_en),
    .fc_results(fc_result),
    .class_hotcoded(relu_result),
    .class_encoded(actual_class_wire),
    .normalized_results(),
    .done(relu_done)
);

// This will only work during simulation
initial begin
    $display("initial begin");
    $readmemh("image.hex", input_image_mem);
    $readmemh("label.hex", expected_class_mem);
    $display("read image and label.");
    // FLatten the arrays
    expected_class = expected_class_mem[0];
    for(i = 0; i < IMAGE_SIZE; i = i+1) begin
 	for(j = 0; j < IMAGE_SIZE; j = j+1) begin
	    input_image[(i*IMAGE_SIZE + j + 1)*PIXEL_DEPTH - 1 -: PIXEL_DEPTH] = input_image_mem[i*IMAGE_SIZE + j];
    	end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
	$display("In CNN reset! Expected class: %d", expected_class);
        led <= 10'b1111111111;  // Reset the led output when reset is low
        state <= 3'b000;
        conv_rst <= 1'b1;
        pool_rst <= 1'b1;
        fc_rst <= 1'b1;
        relu_rst <= 1'b1;
        done <= 1'b0;
        conv_en <= 1'b0;
        pool_en <= 1'b0;
        fc_en <= 1'b0;
        relu_en <= 1'b0;

        // TODO: hard code a kernel. For now just use garbage values:
        for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
            for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
                // TODO: replace with kernel depth parameter?
                kernel[i*WINDOW_SIZE*PIXEL_DEPTH + j*PIXEL_DEPTH + PIXEL_DEPTH - 1 -: PIXEL_DEPTH] = ((i+j)%2 == 0) ? i*10 + j : 0;
            end
        end

        // TODO: hard code an array of input images. for now just use garbage data
        // TODO: hard code a set of 40 weights for the fully connect layer (2x2x10). For now just use garbage values.
        /* TODO: uncomment this when synthesizing
        for (i = 0; i < IMAGE_SIZE; i = i + 1) begin
            for (j = 0; j < IMAGE_SIZE; j = j + 1) begin
                input_image[i*IMAGE_SIZE*PIXEL_DEPTH + j*PIXEL_DEPTH + PIXEL_DEPTH - 1 -: PIXEL_DEPTH] = (i + j*8)%256;
            end
        end */

        for (i = 0; i < POOL_IMAGE_SIZE; i = i + 1) begin
            for (j = 0; j < POOL_IMAGE_SIZE; j = j + 1) begin
                for(k = 0; k < CLASSIFICATIONS; k = k + 1) begin
                    fc_weights[(i*POOL_IMAGE_SIZE*CLASSIFICATIONS + j*CLASSIFICATIONS + k + 1)*FC_WEIGHT_DEPTH - 1 -: FC_WEIGHT_DEPTH] = (k == 2) ? 100 : 0;
                end
            end
        end
    end
    else begin
        if(state == 3'b000) begin
	    $display("Entering convolution layer");
            state <= 3'b001; // Move to next state
            conv_rst <= 1'b0; // Lower conv reset
            conv_en <= 1'b1; // Enable conv
        end
        else if(state == 3'b001 && conv_done) begin
	    $display("Finished convolution layer!");
            state <= 3'b010;
            conv_en <= 1'b0; // Disable conv layer
            pool_rst <= 1'b0; // Lower pool reset
            pool_en <= 1'b1; // Enable pool
	        conv_image <= conv_image_wire;
        end
        else if(state == 3'b010 && pool_done) begin
	    $display("Finished max pool!");
            state <= 3'b011;
            pool_en <= 1'b0; // Disable pool layer
            fc_rst <= 1'b0; // Lower fc reset
            fc_en <= 1'b1; // Enable fc layer
	        pool_image <= pool_image_wire;
        end
        else if(state == 3'b011 && fc_done) begin
	    $display("Finished fully connect!");
            state <= 3'b100;
            fc_en <= 1'b0; // Disable fc layer
            relu_rst <= 1'b0; // Lower relu reset
            relu_en <= 1'b1; // Enable relu layer
	        fc_result <= fc_result_wire;
        end
        else if(state == 3'b100 && relu_done) begin
	        $display("Finished relu!");
            state <= 3'b101;
            relu_en <= 1'b0; // Disable relu layer
            led <= relu_result; // Set the led output to the classification
	        $display("Finished CNN! Expected classification: %d, Actual classification: %d", expected_class, actual_class_wire);
        end
        else if(state == 3'b101) begin
            done <= 1'b1; // Set done signal
      
            // TODO: if implementing multiple images, wait in this state for a few seconds before moving onto the next image
        end
    end
end

endmodule
