`timescale 1ns / 1ps

module maxPool_tb;

reg clk, en;
reg [7:0] data_in[5:0][5:0];
wire [7:0] data_out[2:0][2:0];
reg [7:0] expected_data_out[2:0][2:0];
reg data_out_matches[2:0][2:0]; // Boolean for wether or not the data_out matches the expected_data_out
reg passes; // Boolean for wether or not the test passes
wire done;

maxPool6x6 uut(
    .clk(clk),
    .enable(en),  
    .input_array(data_in), 
    .output_max(data_out),
    .done(done)
); 

always #5 clk = ~clk; // Clock period of 10 time units

initial begin
    clk = 0;
    #2; // Wait for 2 time units
    en = 0;

    /************** TEST 1 **************************
    INPUT:
    1 2 3 4 5 6
    7 8 9 10 11 12
    13 14 15 16 17 18
    19 20 21 22 23 24
    25 26 27 28 29 30
    31 32 33 34 35 36

    OUTPUT:
    8 10 12
    20 22 24
    32 34 36
   **************************************************/
    data_in[0][0] = 8'd1; data_in[0][1] = 8'd2; data_in[0][2] = 8'd3; data_in[0][3] = 8'd4; data_in[0][4] = 8'd5; data_in[0][5] = 8'd6;
    data_in[1][0] = 8'd7; data_in[1][1] = 8'd8; data_in[1][2] = 8'd9; data_in[1][3] = 8'd10; data_in[1][4] = 8'd11; data_in[1][5] = 8'd12;
    data_in[2][0] = 8'd13; data_in[2][1] = 8'd14; data_in[2][2] = 8'd15; data_in[2][3] = 8'd16; data_in[2][4] = 8'd17; data_in[2][5] = 8'd18;
    data_in[3][0] = 8'd19; data_in[3][1] = 8'd20; data_in[3][2] = 8'd21; data_in[3][3] = 8'd22; data_in[3][4] = 8'd23; data_in[3][5] = 8'd24;
    data_in[4][0] = 8'd25; data_in[4][1] = 8'd26; data_in[4][2] = 8'd27; data_in[4][3] = 8'd28; data_in[4][4] = 8'd29; data_in[4][5] = 8'd30;
    data_in[5][0] = 8'd31; data_in[5][1] = 8'd32; data_in[5][2] = 8'd33; data_in[5][3] = 8'd34; data_in[5][4] = 8'd35; data_in[5][5] = 8'd36;

    expected_data_out[0][0] = 8'd8; expected_data_out[0][1] = 8'd10; expected_data_out[0][2] = 8'd12;
    expected_data_out[1][0] = 8'd20; expected_data_out[1][1] = 8'd22; expected_data_out[1][2] = 8'd24;
    expected_data_out[2][0] = 8'd32; expected_data_out[2][1] = 8'd34; expected_data_out[2][2] = 8'd36;
   
    #10 en = 1;
    #100; // Expect to be done after less than 10 cycles

    if(done) begin
        data_out_matches[0][0] = (data_out[0][0] == expected_data_out[0][0]);
        data_out_matches[0][1] = (data_out[0][1] == expected_data_out[0][1]);
        data_out_matches[0][2] = (data_out[0][2] == expected_data_out[0][2]);
        data_out_matches[1][0] = (data_out[1][0] == expected_data_out[1][0]);
        data_out_matches[1][1] = (data_out[1][1] == expected_data_out[1][1]);
        data_out_matches[1][2] = (data_out[1][2] == expected_data_out[1][2]);
        data_out_matches[2][0] = (data_out[2][0] == expected_data_out[2][0]);
        data_out_matches[2][1] = (data_out[2][1] == expected_data_out[2][1]);
        data_out_matches[2][2] = (data_out[2][2] == expected_data_out[2][2]);
        passes <= (data_out_matches[0][0] && data_out_matches[0][1] && data_out_matches[0][2] && 
                    data_out_matches[1][0] && data_out_matches[1][1] && data_out_matches[1][2] && 
                    data_out_matches[2][0] && data_out_matches[2][1] && data_out_matches[2][2]);
        $display("Test 1 data_out[0][0]: %d, expected_data_out[0][0]: %d", data_out[0][0], expected_data_out[0][0]);
        $display("Test 1 data_out[0][1]: %d, expected_data_out[0][1]: %d", data_out[0][1], expected_data_out[0][1]);
        $display("Test 1 data_out[0][2]: %d, expected_data_out[0][2]: %d", data_out[0][2], expected_data_out[0][2]);
        $display("Test 1 data_out[1][0]: %d, expected_data_out[1][0]: %d", data_out[1][0], expected_data_out[1][0]);
        $display("Test 1 data_out[1][1]: %d, expected_data_out[1][1]: %d", data_out[1][1], expected_data_out[1][1]);
        $display("Test 1 data_out[1][2]: %d, expected_data_out[1][2]: %d", data_out[1][2], expected_data_out[1][2]);
        $display("Test 1 data_out[2][0]: %d, expected_data_out[2][0]: %d", data_out[2][0], expected_data_out[2][0]);
        $display("Test 1 data_out[2][1]: %d, expected_data_out[2][1]: %d", data_out[2][1], expected_data_out[2][1]);
        $display("Test 1 data_out[2][2]: %d, expected_data_out[2][2]: %d", data_out[2][2], expected_data_out[2][2]);
        if(passes) begin
            $display("Test 1 passed");
        end else begin
            $display("Test 1 failed: Data out does not match expected data out");
        end
    end else begin
        $display("Test 1 failed: Not done after 10 cycles");
        passes <= 0;
    end 

    // TODO: add more tests

    $finish;
end


endmodule