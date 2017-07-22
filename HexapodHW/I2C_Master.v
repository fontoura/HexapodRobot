// I2C_Master.v

// This file was auto-generated as part of a generation operation.
// If you edit it your changes will probably be lost.

`timescale 1 ps / 1 ps
module I2C_Master (
		input  wire       wb_clk_i,   //            clock.clk
		input  wire       wb_rst_i,   //      clock_reset.reset
		inout  wire       scl_pad_io, //           export.export
		inout  wire       sda_pad_io, //                 .export
		output wire       wb_inta_o,  // interrupt_sender.irq
		input  wire [2:0] wb_adr_i,   //     avalon_slave.address
		input  wire [7:0] wb_dat_i,   //                 .writedata
		output wire [7:0] wb_dat_o,   //                 .readdata
		input  wire       wb_we_i,    //                 .write
		input  wire       wb_stb_i,   //                 .chipselect
		output wire       wb_ack_o    //                 .waitrequest_n
	);

	i2c_opencores i2c_master (
		.wb_clk_i   (wb_clk_i),   //            clock.clk
		.wb_rst_i   (wb_rst_i),   //      clock_reset.reset
		.scl_pad_io (scl_pad_io), //           export.export
		.sda_pad_io (sda_pad_io), //                 .export
		.wb_inta_o  (wb_inta_o),  // interrupt_sender.irq
		.wb_adr_i   (wb_adr_i),   //     avalon_slave.address
		.wb_dat_i   (wb_dat_i),   //                 .writedata
		.wb_dat_o   (wb_dat_o),   //                 .readdata
		.wb_we_i    (wb_we_i),    //                 .write
		.wb_stb_i   (wb_stb_i),   //                 .chipselect
		.wb_ack_o   (wb_ack_o)    //                 .waitrequest_n
	);

endmodule
