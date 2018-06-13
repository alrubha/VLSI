module tas(
input clk_50,		//50Mhz input clock 
input clk_2,		//2Mhz input clock 
input reset_n,		//reset async active low
input serial_data,	//serial input data
input data_ena,		//serial data enable
output ram_wr_n,	//write strobe to ram
output [7:0] ram_data,	//ram data
output [10:0] ram_addr	//ram address
);

logic [7:0] parallel_data;			//shift register output
logic a5c3;							//a3 or c5 signal
logic wr;							//write to fifo
logic rd;							//read from fifo
logic empty;						//fifo is empty
logic b1;							//first element in fifo
logic [7:0] fifo_data_out;			//fifo output

/*************************************
/			0xA5 or 0xC3
*************************************/
always_comb begin

	a5c3 = 'x;

	if ( parallel_data == 8'hA5 || parallel_data == 8'hC3 )begin
	
	a5c3 = 1'b1;
	
	end
	
	else begin
	
	a5c3 = 1'b0;
	
	end

end

/**************************************
/			 Shift_register
/**************************************/
shift_reg shift_reg_0(
.clk_50(clk_50),
.reset_n(reset_n),
.serial_data(serial_data),
.data_ena(data_ena),
.parallel_out(parallel_data)
);

/**************************************
/				ctl_50
/**************************************/
ctl_50 ctl_50_0(
.clk_50 (clk_50),		
.reset_n (reset_n),		
.data_ena (data_ena),		
.a5c3 (a5c3),
.fifo_wr(wr)					
);

/**************************************
/				ctl_2
/**************************************/
ctl_2 ctl_2_0(
.clk_2 (clk_2),
.reset_n (reset_n),
.empty (empty),					
.fifo_rd (rd),				
.b1 (b1),								
.ram_wr (ram_wr_n)			
);

/**************************************
/				 fifo
/**************************************/
fifo fifo_0(
.wr_clk(clk_50),
.rd_clk(clk_2),
.reset_n(reset_n),
.wr(wr),						
.rd(rd),						
.data_in(parallel_data),
.data_out(fifo_data_out),					
.full(),						//tbd
.empty(empty)						
);		

/**************************************
/				 averager
/**************************************/
averager averager_0(
.data_in (fifo_data_out),					
.clk_2 (clk_2),			
.reset_n (reset_n),			
.rd_fifo (rd),						
.b1 (b1),							
.data_out (ram_data)				
);

/**************************************
/				 RAM counter
/**************************************/
ram_counter ram_counter0(
.clk_2 (clk_2),
.reset_n (reset_n),				
.ram_wr (ram_wr_n),				
.ram_addr (ram_addr)				
);

endmodule 

