`timescale 1ns/100ps

module CNN_tb();

//INPUTS
	
	CNN dut (	//INPUTS	
	);
	
	always #10 clk <= ~clk;
	
	initial begin
		
		#500 $finish;
	end	

endmodule
