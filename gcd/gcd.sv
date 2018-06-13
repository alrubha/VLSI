module gcd(
input [31:0] a_in,			//operand a
input [31:0] b_in,			//operand b
input start,				//validate the input data
input reset_n,				//reset
input clk,					//clock
output reg [31:0] result,	//output of GCD engine
output reg done				//validate output value
);

/***************************************
* Internal Wires
***************************************/
logic [31:0] reg_a;			//hold the value of a 
logic [31:0] reg_b;			//hold the value of b 
logic [31:0] temp_reg;		//used to swap a and b_in

enum reg [2:0]{
IDLE =  3'b000,
LOAD = 3'b001,
CHECK = 3'b010,
SWAP = 3'b011,
SUB = 3'b100,
DONE = 3'b101
} ps, ns;

always_ff @ (posedge clk, negedge reset_n) begin
	
	if(!reset_n) begin
		ps <= IDLE;
	end
	
	else 
		ps <= ns;
	
end//always_ff

//always_ff @ (posedge clk, negedge reset_n) begin

	//if(start) begin

	//reg_a <= a_in;
	//reg_b <= b_in;

	//end

//end//always_ff

always_comb begin

	case (ps) 
	
	IDLE: begin
		
		if(start)
			ns = LOAD;
			//ns = CHECK;

		else 
			ns = IDLE;
			
	done = 1'b0;
		
	end //IDLE
	
	LOAD: begin
	
		reg_a = a_in;
		reg_b = b_in;
		ns = CHECK;
	
	end
	
	CHECK: begin
	
		if(reg_a > reg_b)
			ns = SUB;
	
		else if (reg_b > reg_a)
			ns = SWAP;
			
	end //CHECK
	
	SWAP: begin
		
		temp_reg = reg_a;
		reg_a = reg_b;
		reg_b = temp_reg;
		ns = SUB;
	
	end //SWAP
	
	SUB: begin 
	
		reg_a = reg_a - reg_b;
		
		if(reg_a == reg_b)
			ns = DONE;
			
		else if(reg_a != reg_b)
			ns = CHECK;
	
	end //SUB
	
	DONE: begin
	
		result = reg_a;
		done = 1'b1;
		ns = IDLE;
		
	end //DONE
	
	endcase 

end//always_comb

endmodule
