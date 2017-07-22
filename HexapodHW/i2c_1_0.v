// i2c_1_0.v

// This file was auto-generated as part of a generation operation.
// If you edit it your changes will probably be lost.

`timescale 1 ps / 1 ps
module i2c_1_0 (
		input  wire [2:0] wb_adr_i,     //     avalon_slave.address
		input  wire [7:0] wb_dat_i,     //                 .writedata
		output wire [7:0] wb_dat_o,     //                 .readdata
		input  wire       wb_we_i,      //                 .write
		input  wire       wb_stb_i,     //                 .chipselect
		output wire       wb_ack_o,     //                 .waitrequest_n
		input  wire       wb_clk_i,     //       clock_sink.clk
		input  wire       wb_rst_i,     // clock_sink_reset.reset
		input  wire       arst_i,       //      conduit_end.export
		output wire       wb_inta_o,    //                 .export
		output wire       scl_padoen_o, //                 .export
		input  wire       sda_pad_i,    //                 .export
		output wire       sda_padoen_o, //                 .export
		input  wire       scl_pad_i,    //                 .export
		output wire       scl_pad_o,    //                 .export
		output wire       sda_pad_o     //                 .export
	);

	i2c_master_wrapper i2c_1_0 (
		.wb_adr_i     (wb_adr_i),     //     avalon_slave.address
		.wb_dat_i     (wb_dat_i),     //                 .writedata
		.wb_dat_o     (wb_dat_o),     //                 .readdata
		.wb_we_i      (wb_we_i),      //                 .write
		.wb_stb_i     (wb_stb_i),     //                 .chipselect
		.wb_ack_o     (wb_ack_o),     //                 .waitrequest_n
		.wb_clk_i     (wb_clk_i),     //       clock_sink.clk
		.wb_rst_i     (wb_rst_i),     // clock_sink_reset.reset
		.arst_i       (arst_i),       //      conduit_end.export
		.wb_inta_o    (wb_inta_o),    //                 .export
		.scl_padoen_o (scl_padoen_o), //                 .export
		.sda_pad_i    (sda_pad_i),    //                 .export
		.sda_padoen_o (sda_padoen_o), //                 .export
		.scl_pad_i    (scl_pad_i),    //                 .export
		.scl_pad_o    (scl_pad_o),    //                 .export
		.sda_pad_o    (sda_pad_o)     //                 .export
	);

endmodule
