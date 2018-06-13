module clock(
input	reset_n,				//reset pin
input 	clk_1sec,				//1 sec clock
input 	clk_1ms,				//1 mili sec clock
input reg 	mil_time,			//mil time pin
output reg [7:0] segment_data, 			//output 7 segment data
output reg [2:0] digit_select			//digit select
);

logic [5:0]sec;					//seconds max is 59
logic [3:0]mins_1;				//mins max is 9
logic [2:0]mins_10;				//mins max is 5
logic [3:0]hrs_1;				//hrs max is 9 for mil_time
logic [1:0]hrs_10;				//hrs max is 2 for mil_time
logic [3:0]hrs12_1;				//max is 9 for regular time
logic hrs12_10;					//max is 1 for regular time
logic [4:0] temp;
logic ampm;					//indicate am -> 0 / pm ->1
logic [7:0]col;					//colon segment data is saved here
/**************************************************
*	Default time is military -> when mil_time = 0
***************************************************/
/**************************************************
*		24 to 12 Logic
***************************************************/
assign temp = 10*hrs_10 + hrs_1;

enum reg{
T_24 = 1'b0,
T_12 = 1'b1
}ps,ns;
always_ff @(posedge clk_1sec, negedge reset_n)begin

	if(!reset_n) ps <= T_24;
	
	else ps <= ns;

end

always_comb begin

	case(ps)
	
	T_24:
	
		if(mil_time) ns = T_12;
		else ns = T_24;
	
	T_12:
	
		if(mil_time) ns = T_12;
		else ns = T_24;
	
	endcase

end

always_comb begin

	if (mil_time)begin
	
		if(temp > 12)begin
		
			if(hrs_10 > 0) hrs12_10 = hrs_10 - 1; 
			else hrs12_10 = 0;
			if(hrs_1 < 2) hrs12_1 = 2 - hrs_1;
			else hrs12_1 = hrs_1 - 2;
			ampm = 1'b1;
			
		end
		
		else if(0 < temp < 12)begin
		
			hrs12_10 = hrs_10;
			hrs12_1 = hrs_1;
			ampm = 1'b0;
			
		end
		
		else if(temp == 0)begin

			hrs12_10 = 1;
			hrs12_1 = 2;
			ampm = 1'b1;				
		
		end		

		else if(temp == 12) ampm = 1'b1;


		
	end
	
	else ampm = 1'b0;
	
end


/******************************************************
*		Sec / mins_1
******************************************************/
always_ff @ (posedge clk_1sec, negedge reset_n)begin

	sec <= sec + 1;

	if(!reset_n)begin
		
		sec <= '0;
		mins_1 <= '0;
		mins_10 <= '0;
		hrs_1 <= '0;
		hrs_10 <= '0;
		
	end

	else if(sec == 59)begin
	
		mins_1 <= mins_1 + 1;
		sec <= '0;
		
	end
end

/******************************************************
*		mins_1 / mins_10 
******************************************************/
always_ff @ (posedge clk_1sec, negedge reset_n) begin

	if(!reset_n)begin
		
		sec <= '0;
		mins_1 <= '0;
		mins_10 <= '0;
		hrs_1 <= '0;
		hrs_10 <= '0;
		
	end

	else if(mins_1 == 10)begin
	
		mins_1 <= '0;
		mins_10 <= mins_10 + 1;
		
	end
	
	
end

/******************************************************
*		mins_10 / hrs_1
******************************************************/
always_ff @ (posedge clk_1sec, negedge reset_n) begin

	if(!reset_n)begin
		
		sec <= '0;
		mins_1 <= '0;
		mins_10 <= '0;
		hrs_1 <= '0;
		hrs_10 <= '0;
		
	end
	
	else if (mins_10 == 6)begin
		mins_10 <= '0;
		hrs_1 <= hrs_1 + 1;
	end
	
end
 
/******************************************************
*		mins_10 / hrs_10
******************************************************/
always_ff @ (posedge clk_1sec, negedge reset_n) begin

	if(!reset_n)begin
		
		sec <= '0;
		mins_1 <= '0;
		mins_10 <= '0;
		hrs_1 <= '0;
		hrs_10 <= '0;
		
	end
	
	else if(hrs_1 == 9) begin
		hrs_1 <= '0;
		hrs_10 <= hrs_10 + 1;		
	end
	
	else if(hrs_10 == 2 && hrs_1 == 4)begin
	
		hrs_1 <= '0;
		hrs_10 <= '0;
	end
	
end

/******************************************************
*		Col Toggle
******************************************************/
always_ff @(posedge clk_1sec,negedge reset_n)begin

	if(!reset_n) col = 8'b00111111;
	col = ~col;

end
/******************************************************
*		Display logic
******************************************************/
enum reg [2:0]{
Minute_1 = 3'b000,
Minute_2 = 3'b001,
Col = 3'b010,
Hours_1 = 3'b011,
Hours_2 = 3'b100
}d_ps,d_ns;

always_ff @(posedge clk_1ms , negedge reset_n)begin

	if(!reset_n) d_ps <= Minute_1;

	else d_ps <= d_ns;

end

always_comb begin

	case(d_ps)
	
	Minute_1:begin
	
	digit_select = 3'b000;
	d_ns = Minute_2;
	
	case(mins_1)
	
	0:begin
	
	 if(ampm)segment_data = 8'b00000010;
	 else segment_data = 8'b11000000;
	
	end

	1:begin
	
	 if(ampm)segment_data = 8'b10011110;
	 else segment_data = 8'b11111001;
	
	end
	
	2:begin
	
	 if(ampm)segment_data = 8'b00100100;
	 else segment_data = 8'b10100100;
	
	end
	
	3:begin
	
	 if(ampm)segment_data = 8'b00001100;
	 else segment_data = 8'b10110000;
	
	end
	
	4:begin
	
	 if(ampm)segment_data = 8'b10011000;
	 else segment_data = 8'b10011001;
	
	end
	
	5:begin
	
	 if(ampm)segment_data = 8'b01001000;
	 else segment_data = 8'b10010010;
	
	end
	
	6:begin
	
	 if(ampm)segment_data = 8'b01000000;
	 else segment_data = 8'b10000010;
	
	end
	
	7:begin
	
	 if(ampm)segment_data = 8'b00011110;
	 else segment_data = 8'b11111000;
	
	end
	
	8:begin
	
	 if(ampm)segment_data = 8'b00000000;
	 else segment_data = 8'b10000000;
	
	end
	
	9:begin
	
	 if(ampm)segment_data = 8'b00001000;
	 else segment_data = 8'b10010000;
	
	end

	endcase//mins_1
	
	end//minute_1
	
	Minute_2:begin
	
	digit_select = 3'b001;
	d_ns = Col;
	
	case(mins_10)
	0: segment_data = 8'b11000000;
	1: segment_data = 8'b11111001;
	2: segment_data = 8'b10100100;
	3: segment_data = 8'b10110000;
	4: segment_data = 8'b10011001;
	5: segment_data = 8'b10010010;
	endcase//mins_10
	
	end//Minute_2
	
	Col:begin
	digit_select = 3'b010;
	d_ns = Hours_1;
	segment_data = col;
	end//Col
	
	Hours_1: begin
	
	digit_select = 3'b011;
	d_ns = Hours_2;
	
	case(mil_time)
	1'b0:begin
		case(hrs_1)
		0: segment_data = 8'b11000000;
		1: segment_data = 8'b11111001;
		2: segment_data = 8'b10100100;
		3: segment_data = 8'b10110000;
		4: segment_data = 8'b10011001;
		5: segment_data = 8'b10010010;
		6: segment_data = 8'b10000010;	
		7: segment_data = 8'b11111000;
		8: segment_data = 8'b10000000;
		9: segment_data = 8'b10010000;
		endcase//hrs_1
	end//1'b0
	
	1'b1:begin
		case(hrs12_1)
		0: segment_data = 8'b11000000;
		1: segment_data = 8'b11111001;
		2: segment_data = 8'b10100100;
		3: segment_data = 8'b10110000;
		4: segment_data = 8'b10011001;
		5: segment_data = 8'b10010010;
		6: segment_data = 8'b10000010;	
		7: segment_data = 8'b11111000;
		8: segment_data = 8'b10000000;
		9: segment_data = 8'b10010000;
		endcase//hrs12_1
	end//1'b1
	endcase//mil_time
	
	end//Hours_1
	
	Hours_2:begin
	
	digit_select = 3'b100;
	d_ns = Minute_1;
	
	case(mil_time)
	1'b0: begin
		case(hrs_10)
		0: segment_data = 8'b11000000;
		1: segment_data = 8'b11111001;
		2: segment_data = 8'b10100100;
		endcase//hrs_10
	end//1'b0
	
	
	1'b1: begin
		case(hrs12_10)
		0: segment_data = 8'b11000000;
		1: segment_data = 8'b11111001;
		endcase//hrs12_10
	end//1'b1
	endcase//mil_time
	
	end//Hours_2
	
	endcase//d_ps

end//always_comb

endmodule
