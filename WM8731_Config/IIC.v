
module IIC(MCLK, RESET, ENABLE, DATA, FINISHED, AUD_SCLK, AUD_SDAT);

input MCLK; //System clock 
input RESET; //ACTIVE LOW reset 
input ENABLE;	//1: Enable
input [15:0]DATA; //Data to be writen to the CODEC 

output AUD_SCLK;
 
output reg FINISHED; 

inout AUD_SDAT; 

//reg FINSIHED; //produce a signal when transfer completed.
reg ERROR; //assert if an NACK was received. 
 
reg [6:0]SD_CONTROL; 
reg SDA; 	//Data line 
reg SCL; 	//SCLK genneration 
reg [9:0]COUNT; //clock 

initial begin 
COUNT = 0; 
SD_CONTROL = 0;  
SDA = 1; 
SCL = 1; 
end 

assign AUD_SCLK = ((SD_CONTROL >= 4) & (SD_CONTROL < 31))? ~COUNT[9] : SCL; 
assign AUD_SDAT = SDA; 

always@(posedge MCLK) COUNT = COUNT + 1; 

//I2C control 
always @ (posedge COUNT[9] or negedge RESET) begin 

	if(!RESET) begin 
		SD_CONTROL <= 0; 
		FINISHED <= 0;
	end//of (!RESET) 
	else begin 
		if(!ENABLE) SD_CONTROL <= 0;  
		else begin 
			
			if (SD_CONTROL < 40)SD_CONTROL <= SD_CONTROL + 1;
			else SD_CONTROL <= 0; 
			
			if(SD_CONTROL == 32) FINISHED <= 1;
			else FINISHED <= 0;  
		end//end of else  
	end//end of else  

end//of always 

 
//I2C operation
always@(posedge COUNT[9] or negedge RESET) begin 

if (!RESET) begin 
	SCL <= 1; 
	SDA <= 1;
end//of if(!RESET)

else 
case (SD_CONTROL)
	
	7'd0 : begin SDA <= 1; SCL <= 1; end 
	
//start condtion 
	7'd1 : SDA <= 0; 
	7'd2 : SCL <= 0; 
	
// WM8731 MODE: 0 Adress: 0011010 
	7'd3 : SDA <= 0;   
	7'd4 : SDA <= 0;
	7'd5 : SDA <= 1;
	7'd6 : SDA <= 1;
	7'd7 : SDA <= 0;
	7'd8 : SDA <= 1;
	7'd9 : SDA <= 0;
	7'd10 : SDA <= 0; //set for write 
	7'd11 : SDA <= 1'bz;//Slave Ack1  
	
	//[15:9]Register address
	//[8] MSB of DATA  
	7'd12 : SDA <= DATA[15];   
	7'd13 : SDA <= DATA[14];
	7'd14 : SDA <= DATA[13];
	7'd15 : SDA <= DATA[12];
	7'd16 : SDA <= DATA[11];
	7'd17 : SDA <= DATA[10];
	7'd18 : SDA <= DATA[9];
	7'd19 : SDA <= DATA[8]; //Start of DATA 
	7'd20 : SDA <= 1'bz;//Slave A

	// DATA 
	7'd21 : SDA <= DATA[7];   
	7'd22 : SDA <= DATA[6];
	7'd23 : SDA <= DATA[5];
	7'd24 : SDA <= DATA[4];
	7'd25 : SDA <= DATA[3];
	7'd26 : SDA <= DATA[2];
	7'd27 : SDA <= DATA[1];
	7'd28 : SDA <= DATA[0];
	7'd29 : SDA <= 1'bz;//Slave A

	//STOP condtion 
	7'd30 : begin SDA <= 0; SCL <=1; end 
	7'd31 : begin SDA <= 1; end  

	endcase 
end//of always 

endmodule 

