module tb;
//system verilog testbench for tas

reg serial_data, data_ena, reset_n, clk_50, clk_2;
reg ram_wr_n; 
reg  [7:0] ram_data; 
reg [10:0] ram_addr;
integer i;
integer output_file;

parameter CYCLE_50 = 20;  //50mhz cycle
parameter CYCLE_2  = 500; //2mhz clock

//clock generation for the clocks
initial begin
  clk_50 <= 0;
  forever #(CYCLE_50/2) clk_50 = ~clk_50;
end

initial begin
  clk_2 <= 0;
  forever #(CYCLE_2/2) clk_2 = ~clk_2;
end

//release of reset_n relative to two clocks
initial begin
  serial_data='x;
  data_ena='0;
  reset_n <= 0;
  #((CYCLE_2 * 1.5) + 5) reset_n = 1'b1; //reset for 1.5, 2 mhz clock cycles
end

//setup output file generation
initial begin
  output_file = $fopen("vectors/output_data", "wb");
  if (output_file==0) $display("ERROR : Cannot open file output_data");
end

tas tas_0(.*);  //instantiate tas module

task send_byte; 
  input [7:0] in_byte;
  $display ("sending: %h", in_byte);
  begin
    for(i=0; i<=7; i++) begin
      if(in_byte[i] == 1'b1) serial_data=1'b1;
      else                serial_data=1'b0;
      #(CYCLE_50);
    end
    serial_data=1'bx;
  end
endtask

//sample the output data
    always@(posedge ram_wr_n) 
      if(reset_n == 1'b1) begin
        $fwrite(output_file,"ram_addr: %h   ram_data: %d \n",ram_addr, ram_data);
        $display ("write to RAM:: address: %h  data: %d \n",ram_addr, ram_data);
      end


initial begin
  #(CYCLE_2 * 1.5);  //wait till reset goes away
  @(negedge clk_50);  //allows 2ns data setup to tas  
  #((CYCLE_50/2)-2)   //make minus 10 for 10ns setup time
 
  data_pat0();     //simple test pattern
  temp25_fast();   //bursted input
  ltdk0();         //double packet test, dark side burst
  ltdk1();         //double packet test, dark side burst
  temp7f();        //max data size test
  ltdk2();         //double packet test, dark side burst
  tn_ltdk0();      //double packet test, 2nd packet is non-temp
  tn_ltdk1();      //double packet test, 1nd packet is non-temp
  non_fast0();     //max speed non-temp packet
  tn_ltdk2();      //double packet test, 2nd packet is non-temp
  non_slow0();     //min speed non-temp packet
end

//initial begin
//  //capture data written
//  if(ram_wr_n == 1'b0)
//  #((CYCLE_2) - 1);  //sample just before 2mhz clock edge
//  $display("data:%d  address:%h", ram_data, ram_addr);
//end


task data_pat0;
//All sent on light side. Tests data sensitivity, thus input data is in hex.
//Temperature written should be 67. (0x43)
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50); //header first byte in hex
  data_ena = 1'b1; send_byte(8'h3A); data_ena = 1'b0; #(CYCLE_50*4);
  data_ena = 1'b1; send_byte(8'h55); data_ena = 1'b0; #(CYCLE_50*4);
  data_ena = 1'b1; send_byte(8'h43); data_ena = 1'b0; #(CYCLE_50*4);
  data_ena = 1'b1; send_byte(8'h3C); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task temp25_fast;
//Entire packet queued on dark side, bursted upon entering light side.  
//Temperature written should be 25. (0x19)
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);  //header first byte in hex
  data_ena = 1'b1; send_byte(8'd10); data_ena = 1'b0; #(CYCLE_50);  //remaining in decimal
  data_ena = 1'b1; send_byte(8'd20); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd30); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd40); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task ltdk0;
//A double packet test
//Packet0 has h0,b0 and h0,b1 and h0,b2 sent on light side of moon.  
//Data for h0,b3; h1,b0; h1,b1; and h1,b2 was queued on dark side.  
//Upon entering light side, dark side data is bursted. This is followed 
//much later by h1,b3. 
//Averages written: Packet 0, 5. Packet 1, 13.
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);     //header byte in hex
  data_ena = 1'b1; send_byte(8'd2);  data_ena = 1'b0; #(CYCLE_50*200);  
  data_ena = 1'b1; send_byte(8'd4);  data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd6);  data_ena = 1'b0; 
  //going behind moon now
  #(CYCLE_50*200);
  //emerging into light side
  data_ena = 1'b1; send_byte(8'd8); data_ena = 1'b0; #(CYCLE_50);
  //start reception of second packet with C3 header
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50);  //header first byte in hex
  data_ena = 1'b1; send_byte(8'd10); data_ena = 1'b0; #(CYCLE_50);  //remaining in decimal
  data_ena = 1'b1; send_byte(8'd12); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd14); data_ena = 1'b0; 
  //done with queued data burst and waiting for next temp reading
  #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd16); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task temp7f;
//Single packet test
//All sent on light side, all temperatures are 127.
//Temperature written to ram should be 127. (0x7f)
begin
  data_ena = 1'b1; send_byte(8'hA5);  data_ena = 1'b0; #(CYCLE_50);    //header first byte in hex
  data_ena = 1'b1; send_byte(8'd127); data_ena = 1'b0; #(CYCLE_50*10); //remaining in decimal
  data_ena = 1'b1; send_byte(8'd127); data_ena = 1'b0; #(CYCLE_50*10);
  data_ena = 1'b1; send_byte(8'd127); data_ena = 1'b0; #(CYCLE_50*10);
  data_ena = 1'b1; send_byte(8'd127); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task non_slow0;
//Single packet test
//Entire packet is no a temperature packet.  Has imbedded header codes.
//Should not write anything to ram.  Comes in spurts.
begin
  data_ena = 1'b1; send_byte(8'hC2); data_ena = 1'b0; #(CYCLE_50);    //bogus header 
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50*200); //imbedded headers as data
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task ltdk1;
//A double packet test
//Packet0 that has h0,b0 and h0,b1 sent on light side of moon.  Data for 
//h0,b2; h0,b3; h1,b0; and h1,b1 was queued on dark side. Upon entering light 
//side, dark side data is bursted. This is followed later in time by h1,b2 
//and h1,b3.
//Averages written: Packet 0, 21. Packet 1, 28. 
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);     //header byte in hex
  data_ena = 1'b1; send_byte(8'd18); data_ena = 1'b0; #(CYCLE_50*200);  
  data_ena = 1'b1; send_byte(8'd20); data_ena = 1'b0; 
  //going behind moon now
  #(CYCLE_50*200);
  //emerging into light side
  data_ena = 1'b1; send_byte(8'd22); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd24); data_ena = 1'b0; #(CYCLE_50);
  //start reception of second packet with C3 header
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50);  //header first byte in hex
  data_ena = 1'b1; send_byte(8'd26); data_ena = 1'b0; #(CYCLE_50);  //remaining in decimal
  data_ena = 1'b1; send_byte(8'd28); data_ena = 1'b0; 
  //done with queued data burst and waiting for next temp reading
  #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd30); data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd31); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task ltdk2;
//A double packet test
//Packet0 that has h0,b0 only sent on light side of moon. Data for h0,b1; 
//h0,b2; h0,b3; and h1,b0 was queued on dark side. Upon entering light side
//dark side data is bursted. This is followed later in time by h1,b1; h1,b2; and h1,b3.
//Averages written: packet 0: 37, packet 1 45 
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);     //header byte in hex
  data_ena = 1'b1; send_byte(8'd34); data_ena = 1'b0; 
  //going behind moon now
  #(CYCLE_50*200);  
  //emerging into light side
  data_ena = 1'b1; send_byte(8'd36); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd38); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd40); data_ena = 1'b0; #(CYCLE_50);
  //start reception of second packet with C3 header
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50);  //header first byte in hex
  data_ena = 1'b1; send_byte(8'd42); data_ena = 1'b0;               //remaining in decimal
  //done with queued data burst and waiting for next temp reading
  #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd44); data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd46); data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd48); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task tn_ltdk0;
//double packet
//Packet0 that has h0,b0 and h0,b1 and h0,b2 sent on light side of moon.  Data for h0,b3; 
//h1,b0; h1,b1; h1,b2; was queued on dark side. Upon entering light side dark side data is 
//bursted. This is followed much later by h1,b3.  Packet h1 is a non-temperature packet with 
//imbedded valid temperature headers which should be ignored.
//Packet 0 average written is 5.
//Packet 1 is a non-temperature packet.
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);     //header byte in hex
  data_ena = 1'b1; send_byte(8'd2);  data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd4);  data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd6);  data_ena = 1'b0; 
  //going behind moon now
  #(CYCLE_50*200);
  //emerging into light side
  data_ena = 1'b1; send_byte(8'd8);  data_ena = 1'b0; #(CYCLE_50);
  //start reception of second packet with non temperature 83 header
  data_ena = 1'b1; send_byte(8'h83); data_ena = 1'b0; #(CYCLE_50);  //non temperature header
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);  //bogus imbedded header 
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50);  //bogus imbedded header
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0;
  //done with queued data burst and waiting for next temp reading
  #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task tn_ltdk1;
//double packet
//simulates packet0 that has h0,b0 and h0,b1 sent on light side of moon.  Data for h0,b2; h0,b3; 
//h1,b0 and h1,b1 was queued on dark side.  Upon entering light side dark side data is bursted. 
//This is followed much later in time by h1,b2 and h1,b3.
//Packet h1 is a non temperature packet
//Packet 0 average written is 21. 
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);     //header byte in hex
  data_ena = 1'b1; send_byte(8'd18); data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'd20); data_ena = 1'b0; 
  //going behind moon now
  #(CYCLE_50*200);
  //emerging into light side
  data_ena = 1'b1; send_byte(8'd22);  data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd24);  data_ena = 1'b0; #(CYCLE_50);
  //start reception of second packet with non-temperature C1 header
  data_ena = 1'b1; send_byte(8'hC1); data_ena = 1'b0; #(CYCLE_50);  //non temperature header
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);  //bogus imbedded header 
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0;               //bogus imbedded header
  //done with queued data burst and waiting for next temp reading
  #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask

task tn_ltdk2;
//double packet
//Packet0 that has h0,b0 only sent on light side of moon. Data for h0,b1; h0,b2; h0,b3; 
//and h1,b0 was queued on dark side.  Upon entering light side dark side data is bursted. 
//This is followed later in time by h1,b1; h1,b2; and h1,b3.
//Packet 0 average written: 37; Packet 1 is a non-temperature packet
begin
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);     //header byte in hex
  data_ena = 1'b1; send_byte(8'd34); data_ena = 1'b0; 
  //going behind moon now
  #(CYCLE_50*200);
  //emerging into light side
  data_ena = 1'b1; send_byte(8'd36); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd38); data_ena = 1'b0; #(CYCLE_50);
  data_ena = 1'b1; send_byte(8'd40); data_ena = 1'b0; #(CYCLE_50);
  //start reception of second packet with non-temperature C1 header
  data_ena = 1'b1; send_byte(8'hC6); data_ena = 1'b0; #(CYCLE_50);  //non temperature header
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0;               //bogus imbedded header 
  //done with queued data burst and waiting for next temp reading
  #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50*200); //bogus imbedded header
  data_ena = 1'b1; send_byte(8'h46); data_ena = 1'b0; #(CYCLE_50*200);
  data_ena = 1'b1; send_byte(8'h48); data_ena = 1'b0; #(CYCLE_50*200);
end
endtask


task non_fast0;  
//Single packet, bursted in at maximum rate
//Entire packet is not a temperature packet and has data fields with imbedded headers 
begin
  data_ena = 1'b1; send_byte(8'hA1); data_ena = 1'b0; #(CYCLE_50);  //bogus header 
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50);  //imbedded headercimal
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50)   //imbedded header
  data_ena = 1'b1; send_byte(8'hC3); data_ena = 1'b0; #(CYCLE_50)   //imbedded header
  data_ena = 1'b1; send_byte(8'hA5); data_ena = 1'b0; #(CYCLE_50*200);  //imbedded header
end
endtask


endmodule
