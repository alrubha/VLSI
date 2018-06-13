module ctl_2(
input clk_2,
input reset_n,
input empty,
output reg fifo_rd,
output reg b1,			//indicate byte;
output reg ram_wr			//indicate when we can write to ram
);

/*****************************************
/		    FIFO read SM
/*****************************************
/send read or not read to fifo and averager
/*****************************************/
enum reg{
N_READ = 1'b0,
READ = 1'b1
}read_ps, read_ns;

always_ff @(posedge clk_2, negedge reset_n)begin

	if(!reset_n) read_ps <= N_READ;

	else read_ps <= read_ns;
	
end

always_comb begin

	fifo_rd = 1'b0;

	case(read_ps)
	
	N_READ: begin
	
		if(!empty) read_ns = READ;
		else read_ns = N_READ;
		
	end
	
	READ: begin
	
		fifo_rd = 1'b1;
		read_ns = N_READ;
	end
	endcase
	
end


/*****************************************
/		    AVERAGER SM
/*****************************************
/bytes counter
/*****************************************/
enum reg [1:0]{
ADD1 = 2'b00,
ADD2 = 2'b01,
ADD3 = 2'b10,
ADD4 = 2'b11
}cnt_ps, cnt_ns;

always_ff @(posedge clk_2, negedge reset_n)begin

	if(!reset_n) cnt_ps <= ADD1;	
	
	else cnt_ps <= cnt_ns;
end

always_comb begin

	case(cnt_ps)
	
	ADD1: begin
	
		if(fifo_rd) begin
			cnt_ns = ADD2;
		end		
		
		else cnt_ns = ADD1;
	
	end
	
	ADD2: begin
	
		if(fifo_rd) begin
			cnt_ns = ADD3;
			
		end		
		
		else cnt_ns = ADD2;
	
	end
	
	ADD3: begin
	
		if(fifo_rd) begin
			cnt_ns = ADD4;
			
		end

		else cnt_ns = ADD3;
	
	end
	
	ADD4: begin
	
		if(fifo_rd)begin 
			cnt_ns = ADD1;
		end
		
		else cnt_ns = ADD4;
	
	end
	
	endcase

end

assign ram_wr = !((cnt_ps == ADD4) && (read_ps));
/*****************************************
/		    determine byte 1 SM
/*****************************************
/byte 1 detector
/*****************************************/

enum reg {
n_b1 = 1'b0,
y_b1 = 1'b1
} b1_ps, b1_ns;
	
	always_ff @(posedge clk_2, negedge reset_n) begin
		if (!reset_n) begin
			b1_ps <= n_b1;
		end
		else begin
			b1_ps <= b1_ns;
		end
	end
		
	always_comb begin
	
		if (cnt_ns != ADD1) b1_ns = n_b1;
			else b1_ns = y_b1;
	
		case(b1_ps)
		
		y_b1: b1 = 1'b1;
		
		n_b1: b1 = 1'b0;
		
		endcase

	end
	
endmodule