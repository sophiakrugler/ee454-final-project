// Assumptions
// Starting N (Height & Width): 8
// image/color bit depth: 8

// set i_featuremap size = N*N*depth
// set o_featuremap size = (N-2)*(N-2)*depth
// update parameter STARTING_SIZE to new N value


// This convolution module will take in an 8x8, and produce a 6x6
module convolution8#(
    parameter STARTING_SIZE = 8, // this is the initial height & width
    parameter WINDOW_SIZE = 3,    // this is the height & width of the window
    parameter ELEMENT_SIZE = 8
    )(
    //input wires for a feature map
    input wire clk;
    input wire rst;
    input wire [(STARTING_SIZE*STARTING_SIZE*ELEMENT_SIZE)-1:0] i_featuremap;  // Maximum number of bits for 8x8 image of 8-bit depth
    input wire [(WINDOW_SIZE*WINDOW_SIZE*ELEMENT_SIZE)-1:0] kernel; // 3x3 8-bit kernel
    output wire [(((STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1))*ELEMENT_SIZE)-1:0] o_featuremap;  // Maximum size of resulting feature_map, 6x6 of 8-bit depth

); 

// input elements rows indices: [511:448], [447:384], [383:320], [319:256], [255:192], [191:128], [127:64], [63:0]
// input elements rows indices: [287:240], [239:192], [191:144], [143:96], [95:48], [47:0]
// patch row indicies: [71:48], [47:24], [23:0]

// register to act as an array
reg [(((STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1))*ELEMENT_SIZE)-1:0] feature_map;

// register to act as the window's array
//reg [(WINDOW_SIZE*WINDOW_SIZE*ELEMENT_SIZE)-1:0] window_patch;
reg [ELEMENT_SIZE-1 : 0] window_patch_pixel; // represents a single element of the window patch
reg [ELEMENT_SIZE-1 : 0] kernel_pixel; // represents a single element of the kernel

// counters used later
integer row_index, column_index, patch_element, row_offset;

reg [19:0] patch_sum;

always @(posedge clk or posedge rst) begin
    // implement positive rst logic
    if (rst) begin
    // TODO: implement positive reset for the feature map
    // just reset the output for now?
        o_featuremap = 0;
    end else begin
        for (row_index = 0; row_index < STARTING_SIZE - WINDOW_SIZE + 1; row_index = row_index + 1) begin
            for (column_index = 0; j < STARTING_SIZE - WINDOW_SIZE + 1; column_index = column_index + 1) begin
                patch_sum = 0; // reset the sum each time

                // ---------- PATCH CREATION ----------//
                row_offset = (STARTING_SIZE * ELEMENT_SIZE); // each row is seperated by the number of elements in a row * size of elements
                
                // Create patch starting top left and navigating to the right, then go down 1 and all the way back over left
                for (patch_element = 0; patch_element < WINDOW_SIZE*WINDOW_SIZE; patch_element = patch_element + 1) begin

                    integer element_column = patch_element % 3; // the elements column
                    integer element_row = patch_element / 3; // the elements row
                    image_index = (STARTING_SIZE * STARTING_SIZE * ELEMENT_SIZE - 1) - (element_row * row_offset) - (element_column * ELEMENT_SIZE); // the upper bit location of this pixel
                    
                    window_patch_pixel = i_featuremap[image_index -: ELEMENT_SIZE]; // extracts the desired image pixel
                    kernel_pixel = kernel[((WINDOW_SIZE * WINDOW_SIZE - patch_element) * ELEMENT_SIZE - 1) -: ELEMENT_SIZE]; // extracts desired kernel pixel

                    patch_sum = patch_sum + (window_patch_pixel * kernel_pixel);
                end

            // assign the summation to the featuremap
            o_featuremap[(((STARTING_SIZE - WINDOW_SIZE + 1) * (STARTING_SIZE - WINDOW_SIZE + 1)) * ELEMENT_SIZE)-1 - (column_offset) - (row_offset) -: ELEMENT_SIZE] = patch_sum; 
            
            end // of a column
        end // of a row
    end
end

endmodule