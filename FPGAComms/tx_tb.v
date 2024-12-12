`timescale 1ns/100ps

module tx_tb();

    reg clk;
    reg rst;  
    reg en;
    reg [7:0] data;
	wire TxD;
	
	tx dut (	.clk (clk),
				.reset (rst),
				.transmit_en (en),
				.data (data),
				.TxD (TxD)
	);
	
	always #1 clk <= ~clk;
	
	initial begin
		clk <= 0;
		rst <= 1;
		en <= 0;
		data <= 8'b0101_0101;
		
		#50 rst <= 0;
		#5000
		en <= 1;
		#5000
		$display("%d", data);
		#500 $finish;
	end	

endmodule
