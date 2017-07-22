library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity tristate_addr_driver is
	port(
		input_addr : in std_logic_vector(7 downto 0);
		output_addr : out std_logic_vector(7 downto 0) := (others => 'Z'));

end tristate_addr_driver;

architecture arch of tristate_addr_driver is
begin
	proc_output : process(input_addr)
	begin
		if to_integer(unsigned(input_addr)) > 100 then
			output_addr <= (others => 'Z');
		else
			output_addr <= input_addr;
		end if;
	end process;
end arch;