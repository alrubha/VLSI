//
//-------------------------------------------------------------------
//This module creates a testbench for the 4 x 8 byte fifo 
//R. Traylor 4.29.2014
//-------------------------------------------------------------------
//
`timescale 1ns/1ns

module tb; //testbench module for the fifo

integer input_file, output_file, in, out;

integer i;

parameter WR_CYCLE = 20;
parameter RD_CYCLE = 30; 

reg rd_clk, wr_clk, reset_n;
reg wr, rd;
reg full, empty;
reg [7:0] data_in; 
reg [7:0] data_out;

//initial begin
  //input_file  = $fopen("input_data", "rb");
  //if (input_file== 0) begin 
    //$display("ERROR : CAN NOT OPEN input_file"); 
  //end
  //output_file = $fopen("output_data", "wb");
  //if (output_file== 0) begin 
    //$display("ERROR : CAN NOT OPEN output_file"); 
  //end
//end

initial begin
  initalize;
  #(WR_CYCLE*4.5);    //wait for 4 cycles
  wrstim(8);   //write data to fifo
  rdstim(8);   //read data from fifo
  #(WR_CYCLE); //wait 
  wrstim(7);   //write data to fifo
  rdstim(7);   //read data from fifo
  #(WR_CYCLE); //wait for things to settle
  wrstim(6);   //write data to fifo
  rdstim(6);   //read data from fifo
  #(WR_CYCLE); //wait for things to settle
  wrstim(5);   //write data to fifo
  rdstim(5);   //read data from fifo
  #(WR_CYCLE); //wait for things to settle
  wrstim(4);   //write data to fifo
  rdstim(4);   //read data from fifo
  $fclose(input_file);
  $fclose(output_file);
  $finish;
end

//clock generation for write clock
initial begin
  wr_clk <= 0; rd_clk <= 0;
  forever #(WR_CYCLE/2) wr_clk = ~wr_clk;
end

//clock generation for read clock
initial begin
  rd_clk <= 0;
  forever #(RD_CYCLE/2) rd_clk = ~rd_clk;
end

//reset generation
//potential problem: release of reset_n relative to two clocks
initial begin
    reset_n <= 0;
    #(WR_CYCLE * 1.5) reset_n = 1'b1; //reset for 1.5 clock cycles
  end

fifo fifo_0(.*); //instantiate the fifo

task initalize;
  begin
    wr=0;
    rd=0;
    data_in='x;
    input_file  = $fopen("input_data", "rb");
    if (input_file==0) begin 
      $display("ERROR : CAN NOT OPEN input_file"); 
    end
    output_file = $fopen("output_data", "wb");
    if (output_file==0) begin 
      $display("ERROR : CAN NOT OPEN output_file"); 
    end
  end
endtask

task wrstim (input [7:0] rep);  //write stimulus for block using file i/o
  begin
    for(i=0;i<rep;i++) begin
      @(negedge wr_clk);
      $fscanf(input_file,"%h",data_in);
      wr<=1'b1;
      $display("=====================");
      $display ("wrote: %h", data_in);
      @(negedge wr_clk);
      $display ("empty=%b, full=%b", empty, full);
      $display("=====================");
      wr<=1'b0;
      data_in=8'bx;
  end
end
endtask

task rdstim(input [7:0] rep);  //read stimulus for block
  begin
    for(i=0;i<rep;i++) begin
      @(negedge rd_clk);
      rd=1'b1;
      $display("=====================");
      $display ("read: %h", data_out,);
      $fwrite(output_file,"%h\n",data_out);
      @(negedge rd_clk);
      $display ("empty=%b full=%b", empty, full);
      rd=1'b0;
    end
  end
endtask

endmodule 
