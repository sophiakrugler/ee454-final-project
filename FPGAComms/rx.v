//based on https://cmosedu.com/jbaker/students/gerardo/Documents/UARTonFPGA.pdf
//also: https://github.com/HirunaVishwamith/UART_with_FPGA/blob/main/receiver.v
//sends a byte at a time when transmit_en is 1

module rx(input clk, reset,
	input rx, //our recieving line (feed in output of transmitter)
	output reg [7:0] data, //what u received
	output reg ready
	);
	
reg[4:0] bitCounter; // counts the number of bits that have been received

reg[31:0] slow_counter; // counts the number of clock ticks, used to divide the internal clock buad rate /24
reg[31:0] sample_counter; //baud rate

parameter RX_IDLE = 2'b00;
parameter RX_START = 2'b01;
parameter RX_DATA = 2'b10;
parameter RX_END = 2'b11;

reg [1:0] state; 

reg[7:0] temp_data; // register used to hold the value that is currently being received

reg rx_sync; //flip flop to synchronize our input 
reg slow_clock; // clock at 24 times faster than the buad rate 


always @(posedge clk or posedge reset)begin //simple clock divider for reciever... runs at 1/24 of buad rate for sampling
	if (reset) begin
		slow_clock <= 0;
		slow_counter <= 0;
	end else begin
		if (slow_counter == 217) begin // 5208 / 217 = 24
			slow_clock <= ~slow_clock;
			slow_counter <= 0;
		end else begin
			slow_counter <= slow_counter +1;
		end
	end
end

always @(posedge slow_clock or posedge reset) begin
		if (reset) begin
			bitCounter <= 0;
			sample_counter <= 0;
			temp_data <= 8'b0000_0000;
			ready <= 0;
			state <= RX_IDLE;
		end else begin 
			rx_sync <= rx;  // Synchronize the input signal using a flip-flop
			
			case (state)
			RX_IDLE : begin
				if (rx_sync == 0) begin
					data <= 8'b0000_0000;
					state <= RX_START;
					sample_counter <= 0;
				end
			end
			RX_START: begin
				data <= 8'b0000_0001;
				if (sample_counter == 11) begin // 1.5 of a transfer tick 35 (-1 because 0 inclusive)
					state <= RX_DATA;
					sample_counter <= 0;
				end else
					sample_counter <= sample_counter + 1;
			end
			RX_DATA : begin
				data <= 8'b0000_0010;
				if (sample_counter == 11) begin
					sample_counter <= 0;
					temp_data[bitCounter] <= rx_sync;
					if (bitCounter == 7) begin
						state <= RX_END;
						bitCounter <= 0;
					end else bitCounter <= bitCounter + 1;
				end else sample_counter <= sample_counter + 1;
			end
			RX_END : begin
					data <= temp_data;
					ready <= 1'b1;
					state <= RX_IDLE;
					sample_counter <= 0;
			end
			default: state <= RX_IDLE;
			endcase
		end
	end

endmodule