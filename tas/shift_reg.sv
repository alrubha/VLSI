/************************************************************
* This module takes serial input and produce parallel output
*************************************************************/
module shift_reg(
input clk_50,					//50Mhz clock input 
input reset_n, 				//reset async active low
input serial_data,				//serial data input
input data_ena,					//data enable input
output reg [7:0] parallel_out	//parallel data output
);


always_ff @ (posedge clk_50, negedge reset_n) begin

	if(!reset_n)begin

	parallel_out <= 'b0;
	
	end

	else if(data_ena)begin
	
	parallel_out <= {serial_data,parallel_out[7:1]};
	
	end
	
end

endmodule