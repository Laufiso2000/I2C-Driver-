
// Author: Jared Laufiso
// Description: This is an module to configure the WM8731 CODEC. See details
// for detailed information on registers values. 
// uses an I2C module also writen by the author to transfer data to device. 
module WM8731(MCLK,RESET,GO,END,SCL, SDA, SUB_ADD, DONE );

input MCLK;		//system clock(50 MHz)
input RESET;	//System Reset 
input GO;		//this will be a key button on FPGA board to start things off. 

output END;	//Configuration completed succesfully.  
output SCL;	//I2C clock signal connects to AUD_SCLK pin
inout  SDA;	//I2C data signal connects to AUD_SDAT pin 

// outputs for signal tap 2 testing.  

output SUB_ADD; 
output DONE; 
//---------------------------------------------------------------------------
//									Paratameters 
//---------------------------------------------------------------------------

//Default volume (0dB), disable mute, disable simultaneous loading 
parameter LEFT_LINE_IN 					= 9'b000010111;		//addr (00h)
parameter RIGHT_LINE_IN 				= 9'b000010111; 		//addr (01h)

//Default volume (0dB), No zero cross detection, disable simultaneous loading 
parameter LEFT_HEAD_OUT 				= 9'b001111001;		//addr (02h)
parameter RIGHT_HEAD_OUT 				= 9'b001111001;		//addr (03h)

// analog audio path control 
// bit 0: micboost disabled 
// bit 1: mute mic disabled 
// bit 2: INSEL (1: Mic in 0: Line in) line in selected.
// bit 3: BYPASS disabled 
// bit 4: DACSEL (1: select, 0: Dont select)
// bit 5: SIDETONE disabled 
// bit [7:6] sidetone antenuation 00    	
parameter ANALOGUE_AUDIO_PATH_CONTROL 	= 9'b000010000;		//addr (04h)

// digital audio path control 
// bit 0: ADC High Pass Filter Enable (1: disable 0: enable)
// bit[2:1]: De-emphasis Control 
// 		11 = 48kHz
// 		10 = 44.1 kHz
// 		01 = 32kHz
// 		00 = Disable
// bit3: DAC soft mute (1: enable, 0: disable)
// bit4: Store dc offset when High pass Filter disabled (1: store, 0: clear offset) 
parameter DIGITAL_AUDIO_PATH_CONTROL 	= 9'b000000001;		//addr (05h)

// all power saving features are turned off. 
parameter POWER_DOWN_CONTROL 			= 9'b000000000;		//addr (06h)

// digital audio interface format
// bit[1:0] DSP mode 11
// bit[3:2] data length select 
//		11 = 32 bits 
//		10 = 24 bits
//		01 = 20 bits
//		00 = 16 bits   
// bit [4] select DSP mode A/B 
// 		1: MSB on 2nd BCLK rising edge after DACLRC rising edge
//		0: MSB on 1st "  "
// bit [5] Left Right Swap (1:enable 0: disable)
// bit [6] Master/Slave (1:master, 0:slave) 
// bit [7] BCLK invert	(1: invert, 0: don't)
parameter DIGITAL_AUDIO_INTERFACE		= 9'b001010011;		//addr (07h)

// Normal mode 256fs No clock dividing 
parameter SAMPLING_CONTROL 				= 9'b000000000;		//addr (08h)

//bit [0]: activate interface (1: active, 0: inactive)
parameter ACTIVE_CONTROL 				= 9'b000000001;		//addr (09h)

//currently unused. writing all zeros resets the device. 
//parameter RESET_ZEROS							= 9'b000000000;		//addr (0Fh)

//---------------------------------------------------------------------------
//									Wires and Registers 
//---------------------------------------------------------------------------

wire DONE; 	//finished signal from IIC module. 
//wire SCL;	//connect to AUD_SCLK of the DE2-115
//wire SDA; 	//Connect to AUD_SDAT pin of DE2-115

wire [15:0]DATA_OUT;  //data to be sent to CODEC 

reg [6:0]SUB_ADD; 	//address of register, will increment by 1 each cycle. 
reg [8:0]DATA; 		// Register Data 
reg END; 			// Signal configuration completion 
reg EN_TRANSFER;	// enable data transfer


initial begin 
SUB_ADD = 0; 
DATA = LEFT_LINE_IN; 
EN_TRANSFER = 1;
END = 0; 
end

//---------------------------------------------------------------------------
//									Sub module declarations 
//---------------------------------------------------------------------------
IIC i1(	.MCLK(MCLK), 
	.RESET(RESET), 
	.ENABLE(EN_TRANSFER), 
	.DATA(DATA_OUT), 
	.FINISHED(DONE), 
	.AUD_SCLK(SCL), 
	.AUD_SDAT(SDA));

	
//---------------------------------------------------------------------------
//									structural 
//---------------------------------------------------------------------------
	
//set Data out to addres of register and the Data value. 
assign DATA_OUT = {SUB_ADD,DATA}; 


//---------------------------------------------------------------------------
//									sequential 
//---------------------------------------------------------------------------
//CONTROL 
always @ (posedge DONE or negedge RESET)begin 
	 if(!RESET) begin 
		SUB_ADD = 0;  
		END = 0; 
		EN_TRANSFER = 1; 
	 end//of (!RESET)
	//else if(!GO) SUB_ADD = 0; //potential bug with key value. 
	else begin 
		if (SUB_ADD < 10)
			SUB_ADD = SUB_ADD + 7'b1; 
		else begin 
			END = 1;
			EN_TRANSFER = 0; 
		end//of else 
	end//of else 
end//of always

// Data 
// set the data value for each register depending on reg address. 
always@(posedge DONE) begin 
case (SUB_ADD) 
 	0 : DATA <= LEFT_LINE_IN;	 
 	1 : DATA <= RIGHT_LINE_IN; 
 	2 : DATA <= LEFT_HEAD_OUT;
 	3 : DATA <= RIGHT_HEAD_OUT;
 	4 : DATA <= ANALOGUE_AUDIO_PATH_CONTROL;
 	5 : DATA <= DIGITAL_AUDIO_PATH_CONTROL;
 	6 : DATA <= POWER_DOWN_CONTROL;
 	7 : DATA <= DIGITAL_AUDIO_INTERFACE;
 	8 : DATA <= SAMPLING_CONTROL;
 	9 : DATA <= ACTIVE_CONTROL;   
endcase 

end//of always

endmodule 
