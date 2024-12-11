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
    input wire [511:0] i_featuremap;  // Maximum number of bits for 8x8 image of 8-bit depth
    input wire [71:0] kernel;
    output wire [287:0] o_featuremap;  // Maximum size of resulting feature_map, 6x6 of 8-bit depth

); 

// input elements rows indices: [511:448], [447:384], [383:320], [319:256], [255:192], [191:128], [127:64], [63:0]

// input elements rows indices: [287:240], [239:192], [191:144], [143:96], [95:48], [47:0]

// patch row indicies: [71:48], [47:24], [23:0]

// register to act as an array
reg [287:0] feature_map;

// register to act as the window's array
reg [71:0] window_patch;

// counters used later
integer i, j, row_offset, column_offset;

reg [128:0] patch_sum;

always @(posedge clk or posedge rst) begin
    // implement rst logic
    // assume positive rst
    if (rst) begin
    // TODO: implement positive reset for the feature map
        
    end else begin
        // for each lateral window
        for (i = 0; i < STARTING_SIZE - WINDOW_SIZE + 1; i = i + 1) begin
            patch_sum = 128'b0; // reset the sum each time
            for (j = 0; j < STARTING_SIZE - WINDOW_SIZE + 1; j = j + 1) begin
                
                // ---------- PATCH CREATION ----------//
                row_offset    = (i*64); // each row is seperated by 64 bits
                column_offset = (j*ELEMENT_SIZE);  // each column is only 8 bits apart

                // Assuming starting top left and navigating to the right, then go down 1 and all the way back over left
                for (k = 0; k < WINDOW_SIZE*WINDOW_SIZE; k = k + 1) begin
                    window_patch[(71-ELEMENT_SIZE*k) -: 8] = i_featuremap[(511 - row_offset - column_offset - ELEMENT_SIZE*k) -: 8]; // each element

                    // ---------- PATCH * KERNEL ----------//
                    window_patch[(71-ELEMENT_SIZE*k) -: 8] = window_patch[(71-ELEMENT_SIZE*k) -: 8] * kernel[(71-ELEMENT_SIZE*k) -: 8]; // TODO: CHECK IF THIS CAN BE PLACED HERE

                    // ---------- SUM THE PATCH ----------//
                    patch_sum = patch_sum + window_patch;

                    // THE ABOVE IS EQUIVALENT TO THE BELOW

                    //window_patch[71:64] = i_featuremap[511-(row_offset)-(column_offset):504-(row_offset)-(column_offset)]; // top left
                    //window_patch[63:56] = i_featuremap[503-(row_offset)-(column_offset):496-(row_offset)-(column_offset)]; // top middle
                    //window_patch[55:48] = i_featuremap[495-(row_offset)-(column_offset):488-(row_offset)-(column_offset)]; // top right
                    //window_patch[47:40] = i_featuremap[447-(row_offset)-(column_offset):440-(row_offset)-(column_offset)]; // mid left
                    //window_patch[39:32] = i_featuremap[439-(row_offset)-(column_offset):432-(row_offset)-(column_offset)]; // mid mid
                    //window_patch[31:24] = i_featuremap[431-(row_offset)-(column_offset):424-(row_offset)-(column_offset)]; // mid right
                    //window_patch[23:16] = i_featuremap[383-(row_offset)-(column_offset):376-(row_offset)-(column_offset)]; // low left
                    //window_patch[15:8]  = i_featuremap[375-(row_offset)-(column_offset):368-(row_offset)-(column_offset)]; // low mid
                    //window_patch[7:0]   = i_featuremap[367-(row_offset)-(column_offset):360-(row_offset)-(column_offset)]; // low right



                    // Multiply Each window_patch element by the corresponding kernel element
                    //for (l = 0; l < WINDOW_SIZE*WINDOW_SIZE; l = l+1) begin
                    //    window_patch[(71-ELEMENT_SIZE*l) -: 8] = window_patch[(71-ELEMENT_SIZE*l) -: 8] * kernel[(71-ELEMENT_SIZE*l) -: 8];
                    //end

                    // OR

                    //window_patch[71:64] = window_patch[71 -: 8] * kernel[71 -: 8]; // top left
                    //window_patch[63:56] = window_patch[63 -: 8] * kernel[63 -: 8]; // top middle
                    //window_patch[55:48] = window_patch[55 -: 8] * kernel[55 -: 8]; // top right
                    //window_patch[47:40] = window_patch[47 -: 8] * kernel[47 -: 8]; // mid left
                    //window_patch[39:32] = window_patch[39 -: 8] * kernel[39 -: 8]; // mid mid
                    //window_patch[31:24] = window_patch[31 -: 8] * kernel[31 -: 8]; // mid right
                    //window_patch[23:16] = window_patch[23 -: 8] * kernel[23 -: 8]; // low left
                    //window_patch[15:8]  = window_patch[15 -: 8] * kernel[15 -: 8]; // low mid
                    //window_patch[7:0]   = window_patch[7 -: 8]  * kernel[7 -: 8];  // low right
                end

            // TODO: Assign the patch sum to an element of the feature map

            

            end // of a lateral movement
        end // how a vertical movement
    end
end




endmodule