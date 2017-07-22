// TERASIC_SPI_3WIRE_0.v

// This file was auto-generated as part of a generation operation.
// If you edit it your changes will probably be lost.

`timescale 1 ps / 1 ps
module TERASIC_SPI_3WIRE_0 (
		input  wire       clk,          //       clock_reset.clk
		input  wire       reset_n,      // clock_reset_reset.reset_n
		input  wire       s_chipselect, //             slave.chipselect
		input  wire [3:0] s_address,    //                  .address
		input  wire       s_write,      //                  .write
		input  wire [7:0] s_writedata,  //                  .writedata
		input  wire       s_read,       //                  .read
		output wire [7:0] s_readdata,   //                  .readdata
		inout  wire       SPI_SDIO,     //       conduit_end.export
		output wire       SPI_SCLK,     //                  .export
		output wire       SPI_CS_n      //                  .export
	);

	TERASIC_SPI_3WIRE terasic_spi_3wire_0 (
		.clk          (clk),          //       clock_reset.clk
		.reset_n      (reset_n),      // clock_reset_reset.reset_n
		.s_chipselect (s_chipselect), //             slave.chipselect
		.s_address    (s_address),    //                  .address
		.s_write      (s_write),      //                  .write
		.s_writedata  (s_writedata),  //                  .writedata
		.s_read       (s_read),       //                  .read
		.s_readdata   (s_readdata),   //                  .readdata
		.SPI_SDIO     (SPI_SDIO),     //       conduit_end.export
		.SPI_SCLK     (SPI_SCLK),     //                  .export
		.SPI_CS_n     (SPI_CS_n)      //                  .export
	);

endmodule
