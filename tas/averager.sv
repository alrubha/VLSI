module averager(
input [7:0] data_in,	//fifo output
input clk_2,			//clock input
input reset_n,			//reset input
input rd_fifo,			//read fifo siganl, from ctl_2
input b1,				//indicate first element in fifo
output [7:0] data_out	//output data_in
);

logic [9:0] data;


assign data_out = data >> 2;		//divide by four by shifting 2 places

 
always_ff @(posedge clk_2, negedge reset_n)begin

	if(!reset_n) data <= '0;
	
	else if(rd_fifo)begin
	
		case(b1)
			1'b0: data <= data +  data_in;
			
			1'b1: data <= data_in;
	endcase
	
	end
end


endmodule