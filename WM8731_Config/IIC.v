
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
 
reg [5:0]SD_CONTROL; 
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
			SD_CONTROL <= SD_CONTROL + 1; 
			if(SD_CONTROL == 31) FINISHED = 1;
			else FINISHED = 0;  
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
	
	6'd0 : begin SDA <= 1; SCL <= 1; end 
	
//start condtion 
	6'd1 : SDA <= 0; 
	6'd2 : SCL <= 0; 
	
// WM8731 MODE: 0 Adress: 0011010 
	6'd3 : SDA <= 0;   
	6'd4 : SDA <= 0;
	6'd5 : SDA <= 1;
	6'd6 : SDA <= 1;
	6'd7 : SDA <= 0;
	6'd8 : SDA <= 1;
	6'd9 : SDA <= 0;
	6'd10 : SDA <= 0; //set for write 
	6'd11 : SDA <= 1'bz;//Slave Ack1  
	
	//[15:9]Register address
	//[8] MSB of DATA  
	6'd12 : SDA <= DATA[15];   
	6'd13 : SDA <= DATA[14];
	6'd14 : SDA <= DATA[13];
	6'd15 : SDA <= DATA[12];
	6'd16 : SDA <= DATA[11];
	6'd17 : SDA <= DATA[10];
	6'd18 : SDA <= DATA[9];
	6'd19 : SDA <= DATA[8]; //Start of DATA 
	6'd20 : SDA <= 1'bz;//Slave A

	// DATA 
	6'd21 : SDA <= DATA[7];   
	6'd22 : SDA <= DATA[6];
	6'd23 : SDA <= DATA[5];
	6'd24 : SDA <= DATA[4];
	6'd25 : SDA <= DATA[3];
	6'd26 : SDA <= DATA[2];
	6'd27 : SDA <= DATA[1];
	6'd28 : SDA <= DATA[0];
	6'd29 : SDA <= 1'bz;//Slave A

	//STOP condtion 
	6'd30 : begin SDA <= 0; SCL <=1; end 
	6'd31 : begin SDA <= 1; end  

	endcase 
end//of always 

endmodule 

