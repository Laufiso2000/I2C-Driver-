

module Parallel_To_I2S(BCLK, LRCLK, dataIn, booger, dataOut);


localparam wordLength = 16;
localparam msb = wordLength -1; 

input BCLK; 
input LRCLK;

input [msb:0]dataIn; 

input [15:0]booger;

output dataOut; 

wire do;
wire dataOut; 

reg [4:0]bitCnt;
reg data; 
reg [15:0]dataI; 

initial begin 
data = 0; 
bitCnt = 0; 
dataI = 16'hAAAA; 
end 

assign dataOut = (LRCLK && bitCnt < 16)? data : 0; 

//reg ready; 
always @ (negedge BCLK) begin 

	
	if(LRCLK) bitCnt = bitCnt + 1;
		 			
	else bitCnt = 0; 
	
	 
		case(bitCnt) 
	
		5'd0: data = booger[15]; 
		5'd1: data = booger[14]; 
		5'd2: data = booger[13]; 
		5'd3: data = dataI[12]; 
		5'd4: data = dataI[11]; 
		5'd5: data = dataI[10]; 
		5'd6: data = dataI[9]; 
		5'd7: data = dataIn[8]; 
		5'd8: data = dataIn[7]; 
		5'd9: data = dataIn[6];
		5'd10: data = dataIn[5];
		5'd11: data = dataIn[4];
		5'd12: data = dataIn[3];
		5'd13: data = dataIn[2];
		5'd14: data = dataIn[1];
		5'd15: data = dataIn[0];
		endcase 

	
		
end//of always 





endmodule 