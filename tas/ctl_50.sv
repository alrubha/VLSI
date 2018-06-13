module ctl_50(
input clk_50,		//50Mhz input clock 
input reset_n,		//reset async active low
input data_ena,		//serial data enable
input a5c3,			//header check input
output reg fifo_wr		//fifo write enable
);

logic byte_assembled;	//saves the state if byte is assmebled 
//logic wr;
//assign fifo_wr = wr;
/*****************************************
/		    byte assembled SM
/*****************************************
/check if the byte is assembled or not
/*****************************************/
enum reg {
N_ALLOW = 1'b0,
ALLOW =  1'b1
} BA_ps, BA_ns;

always_ff @(posedge clk_50,negedge reset_n)begin

	if(!reset_n) BA_ps <= N_ALLOW;
			
	else BA_ps <= BA_ns;
	
end

always_comb begin

	case(BA_ps)
	
	N_ALLOW: 
	
		if(data_ena) BA_ns = ALLOW;
		else BA_ns = N_ALLOW;
	
	ALLOW:
	
		if(data_ena) BA_ns = ALLOW;
		else BA_ns = N_ALLOW;
	
	endcase

end

assign byte_assembled = (!data_ena) && (BA_ps);	//change to always comb if did not work


/*****************************************
/		    counter SM
/*****************************************
/After assembling the byte, traverse the
/we can traverse the bytes
/*****************************************/
enum reg [2:0]{
HEADER = 3'b000,
B0 = 3'b001,
B1 = 3'b010,
B2 = 3'b011,
B3 = 3'b100
} counter_ps, counter_ns;

always_ff @(posedge clk_50, negedge reset_n)begin

	if(!reset_n) counter_ps <= HEADER;
	
	else counter_ps <= counter_ns;

end

always_comb begin

	case(counter_ps)

	HEADER: begin

		//if(a5c3)
		if(byte_assembled) counter_ns = B0;
		
		else counter_ns = HEADER;
	
	end
	
	B0: begin
	
		if(byte_assembled) counter_ns = B1;
			
		else counter_ns = B0;
	
	end
	
	B1: begin
	
		if(byte_assembled) counter_ns = B2;
			
		else counter_ns = B1;
	
	end
	
	B2: begin
	
		if(byte_assembled) counter_ns = B3;
			
		else counter_ns = B2;
	
	end
	
	B3: begin
	
		if(byte_assembled) counter_ns = HEADER;
			
		else counter_ns = B3;
	
	end
	
	endcase


end

/*****************************************
/		    TEMP check SM
/*****************************************
/check if the byte is a header or TEMP
/a5c3 was determined in tas.sv
/*****************************************/
enum reg {
WAIT = 1'b0,
TEMP =  1'b1
} TEMP_ps, TEMP_ns;

always_ff @(posedge clk_50,negedge reset_n)begin

	if(!reset_n) TEMP_ps <= WAIT;
	
	else TEMP_ps <= TEMP_ns;
	
end

always_comb begin

	case(TEMP_ps)
	
	WAIT: begin
	
	if(a5c3 && counter_ns == B0) TEMP_ns = TEMP;		
	else TEMP_ns = WAIT;
	
	end
	
	TEMP: begin 
	
	if(counter_ns == HEADER) TEMP_ns = WAIT;	
	else TEMP_ns = TEMP;
	end

	endcase
	
end

/*****************************************
/		    FIFO read SM
/*****************************************
/check if byte is assembled and it is a
/TEMP to send high to wr signal to FIFO 
/*****************************************/
enum reg {
N_WRITE = 1'b0,
WRITE =  1'b1
} FIFO_ps, FIFO_ns;

always_ff @(posedge clk_50,negedge reset_n)begin

	if(!reset_n) FIFO_ps <= N_WRITE;
	
	else FIFO_ps <= FIFO_ns;
	
end

always_comb begin

	fifo_wr = 1'b0;

	case (FIFO_ps)
	
	N_WRITE: begin
	
	if(byte_assembled && TEMP_ps && counter_ps != HEADER) FIFO_ns = WRITE;		//it was temp_ns only, MIGHT NEED TO ADD == TEMP
	else FIFO_ns = N_WRITE;
	
	end
	
	WRITE: begin
	
	fifo_wr = 1'b1;
	FIFO_ns = N_WRITE;
	
	end
	endcase
	
end

endmodule