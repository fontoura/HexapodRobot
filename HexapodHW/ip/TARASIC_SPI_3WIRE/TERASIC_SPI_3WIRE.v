module TERASIC_SPI_3WIRE(
	clk,
	reset_n,
	
	//
	s_chipselect,
	s_address,
	s_write,
	s_writedata,
	s_read,
	s_readdata,
	
	// condui
	SPI_CS_n,
	SPI_SCLK,
	SPI_SDIO
);


input						clk;
input						reset_n;

// avalon slave
input						s_chipselect;
input	[3:0]				s_address;
input						s_write;
input		[7:0]			s_writedata;
input						s_read;
output reg	[7:0]		s_readdata;

output					SPI_CS_n;
output					SPI_SCLK;
inout 					SPI_SDIO;

//////////////////////////////////////
`define REG_DATA				0  // r/w
`define REG_CTRL_STATUS		1  // r/w
`define REG_INDEX				2	// w
`define REG_READ_NUM			3	// w


/////////////////////////////////////
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		CMD_START <= 1'b0;
		FIFO_CLEAR <= 1'b0;
	end
	else if (s_chipselect & s_read)
	begin
		if (s_address == `REG_DATA)
			s_readdata <= FIFO_READDATA;
		else if (s_address == `REG_CTRL_STATUS)
			s_readdata <= {7'h00, CMD_DONE};
	end
	else if (s_chipselect & s_write)
	begin
		if (s_address == `REG_DATA)
			FIFO_WRITEDATA <= s_writedata;
		else if (s_address == `REG_CTRL_STATUS)
			{FIFO_CLEAR, REG_RW, CMD_START} <= s_writedata[2:0];
		else if (s_address == `REG_INDEX)
			REG_ADDR <= s_writedata;
		else if (s_address == `REG_READ_NUM)
			REG_RX_NUM <= s_writedata;
	end
end

always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		FIFO_WRITE <= 1'b0;
	else if (s_chipselect && s_write && (s_address == `REG_DATA))
		FIFO_WRITE <= 1'b1;
	else
		FIFO_WRITE <= 1'b0;
end




/////////////////////////////////////
reg	CMD_START;
wire	CMD_DONE;
reg	[7:0]	REG_ADDR;
reg	[7:0]	REG_RX_NUM;
reg			REG_RW;
reg			FIFO_CLEAR;
reg			FIFO_WRITE;
reg	[7:0]	FIFO_WRITEDATA;
wire			FIFO_READ_ACK;
wire	[7:0]	FIFO_READDATA;


assign FIFO_READ_ACK = (s_chipselect && s_read && (s_address == `REG_DATA))?1'b1:1'b0;
//assign FIFO_WRITE = (s_chipselect && s_write && (s_address == `REG_DATA))?1'b1:1'b0;

SPI_3WIRE SPI_3WIRE_inst(
	.clk(clk), 
	.reset_n(reset_n),
	
	//
	.CMD_START(CMD_START),
	.CMD_DONE(CMD_DONE),
	.REG_ADDR(REG_ADDR),
	.REG_RW(REG_RW),
	.REG_RX_NUM(REG_RX_NUM),
	.FIFO_CLEAR(FIFO_CLEAR),
	.FIFO_WRITE(FIFO_WRITE),
	.FIFO_WRITEDATA(FIFO_WRITEDATA),
	.FIFO_READ_ACK(FIFO_READ_ACK),
	.FIFO_READDATA(FIFO_READDATA),
	
	//
	.SPI_CS_n(SPI_CS_n),
	.SPI_SCLK(SPI_SCLK),
	.SPI_SDIO(SPI_SDIO)
);



endmodule

