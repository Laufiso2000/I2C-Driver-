

module I2S_Driver( BCLK, LRCLK, ADCDAT, rightBuff, leftBuff);

input BCLK, LRCLK, ADCDAT; 
output [15:0]rightBuff; 
output [15:0]leftBuff; 


reg [15:0]rightBuff;
reg [15:0]leftBuff; 

//reg ready; 


always @ (negedge BCLK) begin 

	// check for LRCLK 

	if (LRCLK) begin 

	rightBuff[0] = ADCDAT; 
	rightBuff << 1'b1; 

	end else begin 

	leftBuff[0] = ADCDAT; 
	leftBuff << 1'b1; 

end//of else 

end//of always  

