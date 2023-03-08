module ALSU_tb ();
///////// signal declaration ////////////////
 //generated inputs 
 reg clk,rst_tb, cin_tb, serial_in_tb,red_op_A_tb, red_op_B_tb, bypass_A_tb, bypass_B_tb, direction_tb;
 reg [2:0] A_tb, B_tb, opcode_tb;
 //outputs
 wire [15:0] leds_dut;
 //reg  [15:0] leds_exp;
 wire [5:0] out_dut;
// reg  [5:0] out_exp;

////////////////// instantiation /////////////
//NOTE: This testbench should be run 4 times to test all different combinations of the two parameters INPUT_PRIORITY and FULL_ADDER.
ALSU #(.INPUT_PRIORITY("A"),.FULL_ADDER("ON" )) dut(.clk(clk), .rst(rst_tb), .cin(cin_tb), .serial_in(serial_in_tb), .red_op_A(red_op_A_tb), .red_op_B(red_op_B_tb), .bypass_A(bypass_A_tb), .bypass_B(bypass_B_tb), .direction(direction_tb), .A(A_tb), .B(B_tb), .opcode(opcode_tb), .leds(leds_dut), .out(out_dut));
//ALSU #(.INPUT_PRIORITY(A),.FULL_ADDER("OFF")) dut(clk, rst_tb, cin_tb, serial_in_tb, red_op_A_tb, red_op_B_tb, bypass_A_tb, bypass_B_tb, direction_tb, A_tb, B_tb, opcode_tb, leds_dut, out_dut);
//ALSU #(.INPUT_PRIORITY(B),.FULL_ADDER("ON" )) dut(clk, rst_tb, cin_tb, serial_in_tb, red_op_A_tb, red_op_B_tb, bypass_A_tb, bypass_B_tb, direction_tb, A_tb, B_tb, opcode_tb, leds_dut, out_dut);
//ALSU #(.INPUT_PRIORITY(B),.FULL_ADDER("OFF")) dut(clk, rst_tb, cin_tb, serial_in_tb, red_op_A_tb, red_op_B_tb, bypass_A_tb, bypass_B_tb, direction_tb, A_tb, B_tb, opcode_tb, leds_dut, out_dut);

/////////////// clk generation ////////////////// 
initial begin 
clk=0;
forever 
#1 clk=~clk;
end 

////////////// stimulus generation //////////////// 
integer i,j,k;
initial begin
	//reset
	rst_tb=1;
	#50
	rst_tb=0;
	#100;
///////////////////////////////////// TESTING RESET /////////////////////////////////////////////
rst_tb=1;
for (i=0; i<128; i=i+1) begin
    @(negedge clk);
	{cin_tb, serial_in_tb,red_op_A_tb, red_op_B_tb, bypass_A_tb, bypass_B_tb, direction_tb}=i;
	A_tb=$random;
	B_tb=$random;
	opcode_tb=i; //not random, just to insure all opcode possible values are tested
end
@(negedge clk);
rst_tb=0;
///////////////////////////////////// TESTING BYPASS ////////////////////////////////////////////

// ONE: both =1 .. EXPECTED: out= INPUT_PRIORITY
  bypass_A_tb=1;
  bypass_B_tb=1;
  //to avoid invalid condition
  red_op_A_tb=0;
  red_op_B_tb=0;
  opcode_tb=0;
  for (i=0; i<32; i=i+1) begin
    @(negedge clk);
  	{cin_tb,serial_in_tb,direction_tb}=i;
  	A_tb=$random;
  	B_tb=$random;
	//to avoid invalid op codes
	if(i%8!=6 && i%8!=7)
  	opcode_tb=i;
  end 

// TWO: bypassing A .. EXPECTED: out= A
  bypass_A_tb=1;
  bypass_B_tb=0;
  for (i=0; i<32; i=i+1) begin
    @(negedge clk);
  	{cin_tb,serial_in_tb,direction_tb}=i;
  	A_tb=$random;
  	B_tb=$random;
	//to avoid invalid op codes 
	if(i%8!=6 && i%8!=7)
  	opcode_tb=i;
  end 

// THREE: bypassing B .. EXPECTED: out= B
  bypass_A_tb=0;
  bypass_B_tb=1;
  for (i=0; i<32; i=i+1) begin
    @(negedge clk);
  	{cin_tb,serial_in_tb,direction_tb}=i;
  	A_tb=$random;
  	B_tb=$random;
	//to avoid invalid op codes
	if(i%8!=6 && i%8!=7)
  	opcode_tb=i;
  end 

// no bypassing
@(negedge clk);
bypass_A_tb=0;
bypass_B_tb=0;

////////////////////////////////// TESTING REDUCTION /////////////////////////////////////////////////

// ONE: both =1 .. EXPECTED: out= reduction of INPUT_PRIORITY 
  red_op_A_tb=1;
  red_op_B_tb=1;
  opcode_tb=3'b000;
  for (i=0; i<16; i=i+1) begin
    @(negedge clk);
    if (i<8) 
    opcode_tb=3'b000; //AND
    else 
    opcode_tb=3'b001; //XOR

  	{cin_tb,serial_in_tb,direction_tb}=i;
  	A_tb=$random;
  	B_tb=$random;
  end 

// TWO: A .. EXPECTED: out= reduction of A 
  red_op_A_tb=1;
  red_op_B_tb=0;
  for (i=0; i<16; i=i+1) begin
    @(negedge clk);
    if (i<8) 
    opcode_tb=3'b000; //AND
    else 
    opcode_tb=3'b001; //XOR

  	{cin_tb,serial_in_tb,direction_tb}=i;
  	A_tb=$random;
  	B_tb=$random;
  end 

// THREE: B .. EXPECTED: out= reduction of B
  red_op_A_tb=0;
  red_op_B_tb=1;
  for (i=0; i<16; i=i+1) begin
    @(negedge clk);
    if (i<8) 
    opcode_tb=3'b000; //AND
    else 
    opcode_tb=3'b001; //XOR

  	{cin_tb,serial_in_tb,direction_tb}=i;
  	A_tb=$random;
  	B_tb=$random;
  end 

////////////// TESTING INVALID CASE: REDUCTION WHEN OPCODE IS NEITHER "AND" NOR "XOR" ////////////////////
 for (i=2; i<6; i=i+1) begin //to leave out AND , XOR and invalid cases
 	@(negedge clk);
    opcode_tb=i;
    {red_op_A_tb, red_op_B_tb}=5-i; //this generates 3 "2'b11" , 2 "2'10" , 1 "2'b01" and 0 , ignore the 0 case.

    for (j=0; j<8; j=j+1) begin
    	@(negedge clk);
        {cin_tb,serial_in_tb,direction_tb}=j;
  	    A_tb=$random;
  	    B_tb=$random;
    end
    //EXPECTED: leds blink and out is low
    //NOTE: no need to turn off reduction signals as they'd already be zero at the end of this for loop LINE 137
 end

////////////////////////////// TESTING INVALID CASES: OPCODE= 110 OR 111 /////////////////////////////////
@(negedge clk);
opcode_tb=3'b110;
for (i=0; i<16; i=i+1) begin
    @(negedge clk);
    if (i>8) 
    opcode_tb=3'b111;
  	{cin_tb,serial_in_tb,direction_tb}=i;
  	A_tb=$random;
  	B_tb=$random;
end  

//wait until blinking stops
@(negedge clk);
opcode_tb=3'b010;
@(negedge leds_dut[15]);
///////////////////////////////  TESTING ADDITION & MULTIPLICATION  //////////////////////////////////////
@(negedge clk);
opcode_tb=3'b010; //1st 50 runs : addition
for (i=0; i<100; i=i+1) begin
	@(negedge clk);
	if (i>50)
	opcode_tb=3'b011; //other 50 runs : multiplication
    cin_tb=$random;
	A_tb=$random;
  	B_tb=$random;
  	serial_in_tb=$random;
  	direction_tb=$random;
end 

///////////////////////////////////  TESTING   /////////////////////////////////////////////
@(negedge clk);
opcode_tb=3'b011;
for (i=0; i<50; i=i+1) begin
	@(negedge clk);
    cin_tb=$random;
	A_tb=$random;
  	B_tb=$random;
  	serial_in_tb=$random;
  	direction_tb=$random;
end 

///////////////////////////////////  TESTING SHIFT & ROTATION /////////////////////////////////////////////
@(negedge clk);
opcode_tb=3'b011; //1st 100 runs: shift
direction_tb=1; //1st 50 runs of each: left
for (i=1; i<200; i=i+1) begin
	@(negedge clk);

	if (i>50) //other 50 runs: right
	direction_tb=0; //left
	else if (i>100) begin //other 100 runs: rotate
	opcode_tb=3'b011;
	direction_tb=1;
	end  
	else if (i>150) 
	direction_tb=0;

    cin_tb=$random;
	A_tb=$random;
  	B_tb=$random;
  	serial_in_tb=$random;
  	direction_tb=$random;
end

$stop;
end //initial
endmodule 
