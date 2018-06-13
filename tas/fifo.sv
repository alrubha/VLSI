module fifo (
input wr_clk,	//write clock
input rd_clk,	//read clock
input reset_n,	//reset asyn active low
input wr,	//write enable
input rd, 	//read enable
input [7:0] data_in,	//data in
output reg [7:0] data_out,	//data out
output empty,	//empty flag 
output full	//full flag
);

//*****************************************
//wires for in/out
//*****************************************
logic [7:0] word [4:0];	//8 elements with 8 bits long words. used like this word[i] 

//******************************************
// pointers point at the location on fifo
//*******************************************
logic [1:0] rd_ptr;	//read pointer
logic [1:0] wr_ptr;	//write pointer

//*******************************************
//cases for ptrs 
//000		0
//001		1
//010		2
//011		3
//100		4
//101		5
//110		6
//111		7
//********************************************

//********************************************
// toggles, when ptr reach 7, toggle -> 1
// else toggle -> 0  
//******************************************** 
logic toggle_rd;	//toggle read
logic toggle_wr;	//toggle write

reg temp_emp;
reg temp_full;

assign empty = temp_emp;
assign full = temp_full;
assign temp_emp = (toggle_rd == toggle_wr) && (rd_ptr == wr_ptr);
assign temp_full = (toggle_rd != toggle_wr) && (rd_ptr == wr_ptr);

//*********************************************
// Read Blocks
//*********************************************
always_ff @(posedge rd_clk,negedge reset_n)begin

	//toggle_rd <= 1'b0;
	if(!reset_n)begin
	rd_ptr <= '0;
	toggle_rd <= '0;
	end//if
	
	else if(rd)begin
	
	if(rd_ptr == 2'b11)begin	//if pointer points at 8th location
		toggle_rd <= 1'b1;
		rd_ptr <= 2'b00;
	end//inner if		
	
	else begin			//increment pointer
		//toggle_rd = 1'b0;
		rd_ptr <= rd_ptr + 1;
	end//else
	
	end//outter if
end//always

always_comb begin

	data_out = 'x;

	if(rd) begin
	case(rd_ptr) 
	//cases here
	2'b00: data_out = word[0];
	2'b01: data_out = word[1];
	2'b10: data_out = word[2];
	2'b11: data_out = word[3];
	//3'b100: data_out <= word[4];
	//3'b101: data_out <= word[5];
	//3'b110: data_out <= word[6];
	//3'b111: data_out <= word[7];
		
	endcase
	end//else
end//always


//*********************************************
// Write Blocks
//*********************************************sim:/tb/fifo_0/empty
always_ff @(posedge wr_clk,negedge reset_n)begin


	if(!reset_n)begin
	wr_ptr <= '0;
	toggle_wr <= '0;
	end//if
	
	else if(wr)begin
	
		if(wr_ptr == 2'b11)begin	//if pointer points at 8th location
			toggle_wr <= 1'b1;
			wr_ptr <= 2'b00;
		end//inner if		
	
		else begin					//increment pointer
			wr_ptr <= wr_ptr + 1;
	end//else
	
	end//outter if
end//always

always_comb begin

	if(wr) begin
	case(wr_ptr) 
	//cases here	
	2'b00: word[0] = data_in;
	2'b01: word[1] = data_in;
	2'b10: word[2] = data_in;
	2'b11: word[3] = data_in;
	//3'b100: word[4] <= data_in;
	//3'b101: word[5] <= data_in;
	//3'b110: word[6] <= data_in;
	//3'b111: word[7] <= data_in;
		
	endcase
	end//else
end//always

endmodule
