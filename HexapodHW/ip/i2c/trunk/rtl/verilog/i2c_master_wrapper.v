module i2c_master_wrapper(
	wb_clk_i, wb_rst_i, arst_i, wb_adr_i, wb_dat_i, wb_dat_o,
	wb_we_i, wb_stb_i, //wb_cyc_i,
	wb_ack_o, wb_inta_o,
	scl_pad_i, scl_pad_o, scl_padoen_o, sda_pad_i, sda_pad_o, sda_padoen_o//, byteenable
);

// wishbone signals
	input        wb_clk_i;     // master clock input
	input        wb_rst_i;     // synchronous active high reset
	input        arst_i;       // asynchronous reset
	input  [2:0] wb_adr_i;     // lower address bits
	input  [7:0] wb_dat_i;     // databus input
	output [7:0] wb_dat_o;     // databus output
	input        wb_we_i;      // write enable input
	input        wb_stb_i;     // stobe/core select signal
	//input        wb_cyc_i;     // valid bus cycle input
	output       wb_ack_o;     // bus cycle acknowledge output
	output       wb_inta_o;    // interrupt request signal output
	
	//input [3:0] byteenable;
	

	//reg [7:0] wb_dat_o;
	//reg wb_ack_o;
	//reg wb_inta_o;

	// I2C signals
	// i2c clock line
	input  scl_pad_i;       // SCL-line input
	output scl_pad_o;       // SCL-line output (always 1'b0)
	output scl_padoen_o;    // SCL-line output enable (active low)

	// i2c data line
	input  sda_pad_i;       // SDA-line input
	output sda_pad_o;       // SDA-line output (always 1'b0)
	output sda_padoen_o;    // SDA-line output enable (active low)

	wire wb_cyc_i = wb_stb_i;
	//assign address_int; = {wb_adr_i[2], byteenable};
	
	//wire wb_rst_i = 1'b0;
	
	reg[2:0] address_int;
	
	/*always @(posedge wb_clk_i)
	begin
		case(byteenable)
			4'b0001: address_int = {wb_adr_i[2], 2'b00};
			4'b0010: address_int = {wb_adr_i[2], 2'b01};
			4'b0100: address_int = {wb_adr_i[2], 2'b10};
			4'b1000: address_int = {wb_adr_i[2], 2'b11};
			default: address_int = {wb_adr_i[2], 2'b00};
		endcase
	end*/

	
	i2c_master_top top (
		wb_clk_i,
		1'b0, //wb_rst_i,
		arst_i,
		wb_adr_i,
		wb_dat_i,
		wb_dat_o,
		wb_we_i,
		wb_stb_i, //recebe chipselect na conversao
		wb_cyc_i,	//também recebe chipselect
		wb_ack_o,
		wb_inta_o,
		scl_pad_i,
		scl_pad_o,
		scl_padoen_o,
		sda_pad_i,
		sda_pad_o,
		sda_padoen_o
	);

endmodule 