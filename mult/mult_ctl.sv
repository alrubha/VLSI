module mult_ctl(
input reset,
input clk,
input start,
input multiplier_bit0,
output logic prod_reg_ld_high,
output logic prod_reg_shift_rt,
output logic done);

logic [4:0] counter;	//counter

enum logic [1:0]{
IDLE = 2'b00,
TEST = 2'b01,
ADD = 2'b10,
SHIFT = 2'b11
} ps,ns;	//previous state, next state 

always_ff @(posedge clk,posedge reset) begin
	if(reset)
		ps <= IDLE;
	else	
		ps <= ns;
end

always_comb begin

	prod_reg_ld_high = 1'b0;
	prod_reg_shift_rt = 1'b0;
	done = 1'b0;
	
	if(reset) 
	counter = 5'b0;
	
unique case(ps)
IDLE:
begin
	if(start) begin
	prod_reg_ld_high = 1'b1;
 	ns = TEST;
	end
	else ns = IDLE;
end

TEST:
begin
	prod_reg_ld_high = 1'b0;
	if(multiplier_bit0)
	ns = ADD;
	else
	ns = SHIFT;
end

ADD:	
begin
	prod_reg_ld_high = 1'b1;
	prod_reg_shift_rt = 1'b0;
	ns = SHIFT;
end

SHIFT:
begin
	prod_reg_ld_high = 1'b0;
	prod_reg_shift_rt = 1'b1;
	if(counter == 31) begin
	done = 1'b1;
	ns = IDLE;
	end 
	else begin
	counter = counter + 1'b1;
	ns = TEST;
	end
end
endcase
end	//always

endmodule
