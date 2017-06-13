


module FUFU(
	input CLOCK_50,
	input [1:0] KEY,
	input AUD_BCLK,
	input AUD_ADCLRCK,
	input AUD_ADCDAT,
	
	output AUD_XCK, 
	output I2C_SCLK, 
	output [7:0]GPIO,
	output [1:0]LEDG,
	
	inout I2C_SDAT
	);



 

wire sclk; 

pll	audioCLK(
	.inclk0 ( CLOCK_50),
	.c0 (AUD_XCK),
	.c1 ( sclk ));



WM8731 i1(
	.MCLK(sclk),
	.RESET(KEY[0]),
	.END(LEDG[0]),
	.SCL(I2C_SCLK), 
	.SDA(I2C_SDAT));



I2S_Driver i2s( 
	.BCLK(AUD_BCLK), 
	.LRCLK(AUD_ADCLRCK), 
	.ADCDAT(AUD_ADCDAT), 
	//.rightBuff(), 
	//.leftBuff(),
	.debug(GPIO[3]), 
	.d_BCLK(GPIO[0]),
	.d_LRCLK(GPIO[1]), 
	.d_ADCDAT(GPIO[2]));





endmodule 