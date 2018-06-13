module alu(
input		[7:0] in_a	,	//input a
input 		[7:0] in_b	,	//input b
input 		[3:0] opcode	,	//opcode input
output reg	[7:0] alu_out	,	//alu output
output reg	      alu_zero	,	//logic '1' when alu_output [7:0] is all zero	
output reg	      alu_carry		//indicates a carry out from ALU
);

 parameter c_add = 4'h1;
 parameter c_sub = 4'h2;
 parameter c_inc = 4'h3;
 parameter c_dec = 4'h4;
 parameter c_or	 = 4'h5;
 parameter c_and = 4'h6;
 parameter c_xor = 4'h7;
 parameter c_shr = 4'h8;
 parameter c_shl = 4'h9;
 parameter c_onescomp = 4'ha;
 parameter c_twoscomp = 4'hb;

always_comb begin

case (opcode)

c_add:					
	{alu_carry,alu_out} = in_a + in_b;
c_sub:
	{alu_carry,alu_out} = in_a - in_b;
c_inc:
	{alu_carry,alu_out} = in_a + 1;
c_dec:
	{alu_carry,alu_out} = in_a - 1;
c_or:
begin
	alu_carry = 1'b0;
	alu_out = in_a | in_b;
end
c_and:
begin
	alu_carry = 1'b0;
	alu_out = in_a & in_b;
end
c_xor:
begin
	alu_carry = 1'b0;
	alu_out = in_a ^ in_b;
end
c_shr:
begin
	alu_carry = 1'b0;
	alu_out = in_a >> 1;
end
c_shl:
	{alu_carry,alu_out} = in_a << 1;
c_onescomp:
begin
	alu_carry = 1'b0;
	alu_out = ~in_a;
end
c_twoscomp:
	{alu_carry,alu_out} = ~in_a + 1;
default:
begin
	alu_out = 8'bx;
	alu_carry = 1'b0;
end
endcase
		
case (alu_out)
8'b00000000:
	alu_zero = 1'b1;
8'b11111111:
	alu_zero = 1'b0;
default:	
	alu_zero = 1'bx;
endcase
end
endmodule
