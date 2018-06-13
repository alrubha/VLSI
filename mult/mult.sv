module mult(
input reset,
input clk,
input [31:0] a_in,
input [31:0] b_in,
input start,
output logic [63:0] product,
output logic done);

//internal wires
logic [31:0] reg_a;
logic [31:0] prod_reg_high;
logic [31:0] prod_reg_low;
logic prod_reg_ld_high;
logic prod_reg_shift_rt;

assign product = {prod_reg_high,prod_reg_low};

always_ff @(posedge clk, posedge reset)begin

	unique if (reset)begin
		reg_a <= '0;
		prod_reg_low <= '0;
		prod_reg_high <= '0;
	end

	else if(start)begin
		reg_a <= a_in;
		prod_reg_low <= b_in;
		prod_reg_high <= '0;
	end

	else if (prod_reg_ld_high)
		prod_reg_high <= prod_reg_high + reg_a; 

	else if(prod_reg_shift_rt)begin
		prod_reg_low <= {prod_reg_high[0],prod_reg_low[31:1]};
		prod_reg_high <= {1'b0, prod_reg_high[31:1]};
	end
end

/******
Here goes mult_ctrl
******/
mult_ctl mult_ctl_0(
.reset (reset),
.clk (clk),
.start (start),
.multiplier_bit0 (prod_reg_low[0]),
.prod_reg_ld_high(prod_reg_ld_high),
.prod_reg_shift_rt (prod_reg_shift_rt),
.done (done));
endmodule
