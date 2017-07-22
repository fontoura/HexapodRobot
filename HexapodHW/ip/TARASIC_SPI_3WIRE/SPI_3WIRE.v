// clock polarity (CPOL) = 1 and clock phase (CPHA) = 1
// http://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus
// http://www.byteparadigm.com/kb/article/AA-00255/22/Introduction-to-SPI-and-IC-protocols.html
// http://read.pudn.com/downloads132/doc/561635/123.doc

module SPI_3WIRE(
	clk, 
	reset_n,
	
	//
	CMD_START,
	CMD_DONE,
	REG_ADDR,
	REG_RW,
	REG_RX_NUM,
	FIFO_CLEAR,
	FIFO_WRITE,
	FIFO_WRITEDATA,
	FIFO_READ_ACK,
	FIFO_READDATA,
	
	//
	SPI_CS_n,
	SPI_SCLK,
	SPI_SDIO
);

parameter DIVIDER = 10;
parameter CPOL = 1;

input					clk;
input					reset_n;

input					CMD_START;
output				CMD_DONE;
input		[5:0]		REG_ADDR;
input					REG_RW; // 1: read, 0:write
input		[3:0]		REG_RX_NUM; // 16 max, no = value+1
input					FIFO_CLEAR;
input		[7:0]		FIFO_WRITE;
input		[7:0]		FIFO_WRITEDATA;
input		[7:0]		FIFO_READ_ACK;
output	[7:0]		FIFO_READDATA;


output				SPI_CS_n;
output				SPI_SCLK;
inout					SPI_SDIO;


///////////////////////////////////
// generate spi clock
reg spi_clk;
reg [7:0] clk_cnt;
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		clk_cnt <= 0;
		spi_clk <= 1;
	end
	else 
	begin
		if (clk_cnt > DIVIDER)
			begin
			spi_clk <= ~spi_clk;
			clk_cnt <= 0;
			end
		else
			clk_cnt <= clk_cnt + 1;
	end
end


///////////////////////////////
// tx fifo
reg fifo_tx_rdreq;
wire [7:0]	fifo_tx_q;
wire fifo_tx_empty;
wire [7:0]	fifo_tx_wrusedw;

gsensor_fifo gsensor_fifo_tx(
	.aclr(FIFO_CLEAR),
	.data(FIFO_WRITEDATA),
	.rdclk(spi_clk),
	.rdreq(fifo_tx_rdreq),
	.wrclk(clk),
	.wrreq(FIFO_WRITE),
	.q(fifo_tx_q),
	.rdempty(fifo_tx_empty),
	.rdusedw(),
	.wrfull(),
	.wrusedw(fifo_tx_wrusedw)
	);


	
///////////////////////////////
// rx fifo
reg [7:0]	fifo_rx_data;
reg 			fifo_rx_wrreq;
gsensor_fifo gsensor_fifo_rx(
	.aclr(FIFO_CLEAR),
	.data(fifo_rx_data),
	.rdclk(clk),
	.rdreq(FIFO_READ_ACK),
	.wrclk(spi_clk),
	.wrreq(fifo_rx_wrreq),
	.q(FIFO_READDATA),
	.rdempty(),
	.rdusedw(),
	.wrfull(),
	.wrusedw()
	);
	
///////////////////////////////	

// detect START edge
reg pre_CMD_START;
always @ (posedge spi_clk or negedge reset_n)
begin
	if (~reset_n)
		pre_CMD_START <= 1'b1;
	else 
		pre_CMD_START <= CMD_START;
end

//////////////////////////////////
// state
`define ST_IDLE			3'd0
`define ST_START			3'd1
`define ST_RW_MB_ADDR	3'd2
`define ST_DATA			3'd3
`define ST_END				3'd4
`define ST_DONE			3'd5

reg	[2:0]	state;
reg  [2:0] state_at_falling;

reg			 reg_write;
reg	[5:0]  rw_reg_byte_num;
reg	[5:0]  byte_cnt;
reg	[2:0]  bit_index;


always @ (posedge spi_clk or negedge reset_n)
begin
	if (~reset_n)
		state <= `ST_IDLE;
	else if (~pre_CMD_START & CMD_START)
	begin
		state <= `ST_START;
		reg_write <= ~REG_RW;
		rw_reg_byte_num <= (REG_RW)?(REG_RX_NUM + 1):(fifo_tx_wrusedw); 
	end
	else
	begin
		case (state)
			`ST_START: 
					begin
						bit_index <= 7;
						state <= `ST_RW_MB_ADDR;					
					end
			`ST_RW_MB_ADDR: 
					begin
						if (bit_index == 0)
						begin
							state <= `ST_DATA;
							byte_cnt <= rw_reg_byte_num-1;
						end
						//
						bit_index <= bit_index - 1;
					end
			`ST_DATA: 
					begin
						if (bit_index == 0)
						begin
							if (byte_cnt == 0)
								state <= `ST_END;
							else
								byte_cnt <= byte_cnt - 1;
						end
						//
						bit_index <= bit_index - 1;	
					end
			`ST_END: 
					begin
						state <= `ST_DONE;
					end
			`ST_DONE: 
					begin
						state <= `ST_DONE;
					end
			default:
					state <= `ST_IDLE;
			
	   endcase
					
	end
	
end


//=========================
// get tx_byte from fifo
reg	[7:0]	 tx_byte;

wire read_fifo_first;
wire read_fifo_other;
wire mb_flag;
assign read_fifo_first = ((state == `ST_RW_MB_ADDR) && (bit_index == 0) && reg_write)?1'b1:1'b0;
//assign read_fifo_1 = ((state == `ST_DATA) && (bit_index == 0) && reg_write)?1'b1:1'b0;
assign read_fifo_other = ((state == `ST_DATA) && (bit_index == 0) && reg_write && (byte_cnt != 0))?1'b1:1'b0;

assign mb_flag = (rw_reg_byte_num == 1)?1'b0:1'b1;

always @ (posedge spi_clk or negedge reset_n)
begin
	if (~reset_n)
		fifo_tx_rdreq <= 1'b0;
	else if (state == `ST_START)
	begin
//		tx_byte <= {~reg_write, (reg_write)?((fifo_tx_wrusedw==1)?1'b0:1'b1):((REG_RX_NUM==0)?1'b0:1'b1), REG_ADDR};
		tx_byte <= {~reg_write, mb_flag, REG_ADDR};
		fifo_tx_rdreq <= 1'b0;
	end
	else if (read_fifo_first | read_fifo_other)
	begin
		tx_byte <= fifo_tx_q;
		fifo_tx_rdreq <= 1'b1;
	end
	else
		fifo_tx_rdreq <= 1'b0;

end 


////////////////////////////////
// serial tx data at falling edge
reg tx_bit;

always @ (negedge spi_clk)
begin
	tx_bit <= tx_byte[bit_index];
end

////////////////////////////////
// capture serail rx data at rising edge
reg	[7:0] rx_byte;


always @ (posedge spi_clk or negedge reset_n)
begin
	if (~reset_n)
		fifo_rx_wrreq <= 1'b0;
	else if (~data_out)
	begin
		if (bit_index == 0)
		begin
			fifo_rx_data <= {rx_byte[7:1], SPI_SDIO};
			rx_byte <= 0;
			fifo_rx_wrreq <= 1'b1;
		end
		else
		begin
			rx_byte[bit_index] <= SPI_SDIO;
			fifo_rx_wrreq <= 1'b0;
		end
		
	end
	else
		fifo_rx_wrreq <= 1'b0;
end

////////////////////////////////
// phase at falling edge


always @ (negedge spi_clk or negedge reset_n)
begin
	if (~reset_n)
		state_at_falling <= `ST_IDLE;
	else	
		state_at_falling <= state;
end


////////////////////////////////
// combiniation


wire data_out;
assign data_out = ((state_at_falling == `ST_RW_MB_ADDR) || (state_at_falling == `ST_DATA && reg_write))?1'b1:1'b0;


assign SPI_CS_n = (state_at_falling == `ST_IDLE || state_at_falling == `ST_DONE)?1'b1:1'b0;
assign SPI_SCLK = (~SPI_CS_n  && (state != `ST_START) && (state != `ST_END))?spi_clk:1'b1;
assign SPI_SDIO = (~SPI_CS_n & data_out)?(tx_bit?1'b1:1'b0):1'bz;
assign CMD_DONE = (state == `ST_DONE)?1'b1:1'b0;


///////////////////////////////
endmodule
