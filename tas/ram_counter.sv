module ram_counter(
input clk_2,
input reset_n,				//reset signal
input ram_wr,				//indicate when we can write to ram
output reg [10:0] ram_addr	//ram address
);

always_ff @ (posedge clk_2, negedge reset_n)begin

	if(!reset_n) ram_addr <= 11'h800;

	else if (!ram_wr) ram_addr <= ram_addr - 1;
	
end

endmodule