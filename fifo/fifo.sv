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
logic [7:0] word [7:0];	//8 elements with 8 bits long words. used like this word[i] 

//******************************************
// pointers point at the location on fifo
//*******************************************
logic [2:0] rd_ptr;	//read pointer
logic [2:0] wr_ptr;	//write pointer

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
//*********************************************
// Read Blocks
//*********************************************
always @(posedge rd_clk, negedge reset_n) begin

	if(!reset_n)begin
	//reset things
	rd_ptr <= 3'b000;
	wr_ptr <= 3'b000;
	toggle_rd <= 1'b0;
	toggle_wr <= 1'b0;
	end//if

	else if(rd) begin
	case(rd_ptr) 
	//cases here
	3'b000: data_out <= word[0];
	3'b001: data_out <= word[1];
	3'b010: data_out <= word[2];
	3'b011: data_out <= word[3];
	3'b100: data_out <= word[4];
	3'b101: data_out <= word[5];
	3'b110: data_out <= word[6];
	3'b111: data_out <= word[7];
		
	endcase
	end//else
end//always

always @(posedge rd_clk)begin

 	temp_emp = (toggle_rd == toggle_wr) && (rd_ptr == wr_ptr);

	if(rd)begin
	
	if(rd_ptr == 3'b111)begin	//if pointer points at 8th location
		toggle_rd <= 1'b1;
		rd_ptr <= 3'b000;
	end//inner if		
	
	else begin			//increment pointer
		//toggle_rd = 1'b0;
		rd_ptr <= rd_ptr + 1'b1;
	end//else
	
	end//outter if
end//always

//*********************************************
// Write Blocks
//*********************************************sim:/tb/fifo_0/empty

always @(posedge wr_clk, negedge reset_n) begin

	if(!reset_n)begin
	//reset things
	rd_ptr <= 3'b000;
	wr_ptr <= 3'b000;
	toggle_rd <= 1'b0;
	toggle_wr <= 1'b0;
	
	end//if

	else if(wr) begin
	case(wr_ptr) 
	//cases here	
	3'b000: word[0] <= data_in;
	3'b001: word[1] <= data_in;
	3'b010: word[2] <= data_in;
	3'b011: word[3] <= data_in;
	3'b100: word[4] <= data_in;
	3'b101: word[5] <= data_in;
	3'b110: word[6] <= data_in;
	3'b111: word[7] <= data_in;
		
	endcase
	end//else
end//always

always @(posedge wr_clk)begin

 	temp_full = (toggle_rd != toggle_wr) && (rd_ptr == wr_ptr);

	if(wr)begin
	
	if(wr_ptr == 3'b111)begin	//if pointer points at 8th location
		toggle_wr <= 1'b1;
		wr_ptr <= 3'b000;
	end//inner if		
	
	else begin			//increment pointer
		//toggle_wr = 1'b0;
		wr_ptr <= wr_ptr + 1'b1;
	end//else
	
	end//outter if
end//always

endmodule
