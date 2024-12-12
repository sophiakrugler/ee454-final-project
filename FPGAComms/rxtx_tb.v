`timescale 1ns/100ps

module rxtx_tb();

    reg clk;
    reg rst;

	//rx
    wire [7:0] data_r;
	wire ready;
	
	//tx
	reg en;
    reg [7:0] data;
	wire TxD;
	
	tx tx_dut (	.clk (clk),
				.reset (rst),
				.transmit_en (en),
				.data (data),
				.TxD (TxD)
	);
	
	
	rx rx_dut (	.clk (clk),
				.reset (rst),
				.rx (TxD),
				.data (data_r),
				.ready (ready)
	);
	
	always #1 clk <= ~clk;
	
	initial begin
		clk <= 0;
		rst <= 1;
		en <= 0;
		data <= 8'b1111_1111;
		
		#5 rst <= 0;
		#5000
		en <= 1;
		#50000000
		$display("%d", data);
		#500 $finish;
	end	

endmodule
