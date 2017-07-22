library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity Generic_Vbuf is
	generic(
		io_width : integer := 2
	);
	port(
		input : in std_logic_vector(io_width-1 downto 0);
		rden : in std_logic := '0';
		output : out std_logic_vector(io_width-1 downto 0));

end Generic_Vbuf;

architecture test of Generic_Vbuf is
begin
	proc: process(rden)
		variable reg_input : std_logic_vector(io_width-1 downto 0);
	begin
		if (rden = '1') then
			reg_input := input;
			output <= reg_input;
		else
			output <= (io_width-1 downto 0 => 'Z');
		end if;
	end process;
end test;