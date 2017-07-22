// i2c.v

// This file was auto-generated as part of a generation operation.
// If you edit it your changes will probably be lost.

`timescale 1 ps / 1 ps
module i2c (
		input  wire [2:0] wb_adr_i,     //     avalon_slave.address
		input  wire [7:0] wb_dat_i,     //                 .writedata
		output wire [7:0] wb_dat_o,     //                 .readdata
		input  wire       wb_we_i,      //                 .write
		input  wire       wb_stb_i,     //                 .chipselect
		input  wire       wb_cyc_i,     //                 .chipselect
		output wire       wb_ack_o,     //                 .waitrequest_n
		output wire       scl_pad_o,    //                 .readdatavalid_n
		output wire       scl_padoen_o, //                 .readdatavalid_n
		input  wire       sda_pad_i,    //                 .beginbursttransfer_n
		output wire       sda_padoen_o, //                 .readdatavalid_n
		input  wire       scl_pad_i,    //                 .beginbursttransfer_n
		output wire       sda_pad_o,    //                 .readdatavalid_n
		input  wire       wb_clk_i,     //       clock_sink.clk
		input  wire       wb_rst_i,     // clock_sink_reset.reset
		input  wire       arst_i,       //      conduit_end.export
		output wire       wb_inta_o     //                 .export
	);

	i2c_master_top #(
		.ARST_LVL (2'b00)
	) i2c (
		.wb_adr_i     (wb_adr_i),  //     avalon_slave.address
		.wb_dat_i     (wb_dat_i),  //                 .writedata
		.wb_dat_o     (wb_dat_o),  //                 .readdata
		.wb_we_i      (wb_we_i),   //                 .write
		.wb_stb_i     (),          //                 .chipselect
		.wb_cyc_i     (),          //                 .chipselect
		.wb_ack_o     (wb_ack_o),  //                 .waitrequest_n
		.scl_pad_o    (),          //                 .readdatavalid_n
		.scl_padoen_o (),          //                 .readdatavalid_n
		.sda_pad_i    (),          //                 .beginbursttransfer_n
		.sda_padoen_o (),          //                 .readdatavalid_n
		.scl_pad_i    (),          //                 .beginbursttransfer_n
		.sda_pad_o    (),          //                 .readdatavalid_n
		.wb_clk_i     (wb_clk_i),  //       clock_sink.clk
		.wb_rst_i     (wb_rst_i),  // clock_sink_reset.reset
		.arst_i       (arst_i),    //      conduit_end.export
		.wb_inta_o    (wb_inta_o)  //                 .export
	);

endmodule
