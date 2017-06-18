module I2S_To_Parallel( BCLK, LRCLK, ADCDAT, rightBuff, leftBuff,dataReady);

parameter wordLength = 16;
localparam msb = wordLength -1; 

input BCLK, LRCLK, ADCDAT; 
output [msb:0]rightBuff; 
output [msb:0]leftBuff; 
output dataReady; 



reg [msb:0]rightBuff;
reg [msb:0]leftBuff; 

reg dataReady; 



reg [4:0]bitCnt; 

initial begin 

rightBuff = 0; 
leftBuff = 0;
bitCnt = 0; 
dataReady = 0; 
end 







//reg ready; 
always @ (negedge BCLK) begin 

	
	if(LRCLK) begin 
	
		bitCnt = bitCnt + 1;
		 
			if(bitCnt == wordLength) begin 
				dataReady = 1; 
			end else begin 
				dataReady = 0; 
			end// end of bitCnt == wordLength  
			
		end else begin 
		bitCnt = 0; 
		end 
		
end//of always 



//Serial to parallel. 
always @ (posedge BCLK ) begin 

	if(LRCLK && bitCnt < wordLength) begin 
	
			rightBuff[msb:0] <= {rightBuff[msb-1:0],ADCDAT};  
		
	end//of if LRCLK

end//of always 




endmodule 