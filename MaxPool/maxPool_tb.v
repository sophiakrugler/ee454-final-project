`timescale 1ns / 1ps

module maxPool_tb;

reg clk, en;
reg [10:0] in[5:0][5:0];
wire [10:0] out[2:0][2:0];
reg [10:0] expected_data_out[2:0][2:0];
reg data_out_matches[2:0][2:0]; // Boolean for wether or not the data_out matches the expected_data_out
reg passes; // Boolean for wether or not the test passes
wire done;

maxPool6x6 uut(
    .clk(clk),
    .enable(en),  
    .in_0_0(in[0][0]), .in_0_1(in[0][1]), .in_0_2(in[0][2]), .in_0_3(in[0][3]), .in_0_4(in[0][4]), .in_0_5(in[0][5]),
    .in_1_0(in[1][0]), .in_1_1(in[1][1]), .in_1_2(in[1][2]), .in_1_3(in[1][3]), .in_1_4(in[1][4]), .in_1_5(in[1][5]),
    .in_2_0(in[2][0]), .in_2_1(in[2][1]), .in_2_2(in[2][2]), .in_2_3(in[2][3]), .in_2_4(in[2][4]), .in_2_5(in[2][5]),
    .in_3_0(in[3][0]), .in_3_1(in[3][1]), .in_3_2(in[3][2]), .in_3_3(in[3][3]), .in_3_4(in[3][4]), .in_3_5(in[3][5]),
    .in_4_0(in[4][0]), .in_4_1(in[4][1]), .in_4_2(in[4][2]), .in_4_3(in[4][3]), .in_4_4(in[4][4]), .in_4_5(in[4][5]),
    .in_5_0(in[5][0]), .in_5_1(in[5][1]), .in_5_2(in[5][2]), .in_5_3(in[5][3]), .in_5_4(in[5][4]), .in_5_5(in[5][5]),
    .out_0_0(out[0][0]), .out_0_1(out[0][1]), .out_0_2(out[0][2]),
    .out_1_0(out[1][0]), .out_1_1(out[1][1]), .out_1_2(out[1][2]),
    .out_2_0(out[2][0]), .out_2_1(out[2][1]), .out_2_2(out[2][2]),
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
    in[0][0] = 8'd1; in[0][1] = 8'd2; in[0][2] = 8'd3; in[0][3] = 8'd4; in[0][4] = 8'd5; in[0][5] = 8'd6;
    in[1][0] = 8'd7; in[1][1] = 8'd8; in[1][2] = 8'd9; in[1][3] = 8'd10; in[1][4] = 8'd11; in[1][5] = 8'd12;
    in[2][0] = 8'd13; in[2][1] = 8'd14; in[2][2] = 8'd15; in[2][3] = 8'd16; in[2][4] = 8'd17; in[2][5] = 8'd18;
    in[3][0] = 8'd19; in[3][1] = 8'd20; in[3][2] = 8'd21; in[3][3] = 8'd22; in[3][4] = 8'd23; in[3][5] = 8'd24;
    in[4][0] = 8'd25; in[4][1] = 8'd26; in[4][2] = 8'd27; in[4][3] = 8'd28; in[4][4] = 8'd29; in[4][5] = 8'd30;
    in[5][0] = 8'd31; in[5][1] = 8'd32; in[5][2] = 8'd33; in[5][3] = 8'd34; in[5][4] = 8'd35; in[5][5] = 8'd36;

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
        $display("Test 1 out[0][0]: %d, expected_data_out[0][0]: %d", out[0][0], expected_data_out[0][0]);
        $display("Test 1 out[0][1]: %d, expected_data_out[0][1]: %d", out[0][1], expected_data_out[0][1]);
        $display("Test 1 out[0][2]: %d, expected_data_out[0][2]: %d", out[0][2], expected_data_out[0][2]);
        $display("Test 1 out[1][0]: %d, expected_data_out[1][0]: %d", out[1][0], expected_data_out[1][0]);
        $display("Test 1 out[1][1]: %d, expected_data_out[1][1]: %d", out[1][1], expected_data_out[1][1]);
        $display("Test 1 out[1][2]: %d, expected_data_out[1][2]: %d", out[1][2], expected_data_out[1][2]);
        $display("Test 1 out[2][0]: %d, expected_data_out[2][0]: %d", out[2][0], expected_data_out[2][0]);
        $display("Test 1 out[2][1]: %d, expected_data_out[2][1]: %d", out[2][1], expected_data_out[2][1]);
        $display("Test 1 out[2][2]: %d, expected_data_out[2][2]: %d", out[2][2], expected_data_out[2][2]);
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