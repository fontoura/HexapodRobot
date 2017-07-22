library ieee;

use ieee.std_logic_1164.all;

package array_types is
	type generic_array is array(0 to 3) of std_logic_vector(output_width-1 downto 0);
end package;


library ieee;
library work;

use ieee.std_logic_1164.all;
use work.array_types.all;

entity Demux1x4 is
	generic(
		input_width : integer := 1;
		output_width : integer := 1
	);
	port(
		input : in std_logic_vector(input_width-1 downto 0);
		output_select : in std_logic_vector(1 downto 0) := '0';
		output : out generic_array);

end Demux1x4;

architecture test of Demux1x4 is
begin
	proc: process(input, output_select)
	begin
		if (output_select = "00") then
			output(0) <= input;
			output(1) <= (others => '0');
			output(2) <= (others => '0');
			output(3) <= (others => '0');
		elsif (output_select = "01") then
			output(1) <= input;
			output(0) <= (others => '0');
			output(2) <= (others => '0');
			output(3) <= (others => '0');
		elsif (output_select = "10") then
			output(2) <= input;
			output(0) <= (others => '0');
			output(1) <= (others => '0');
			output(3) <= (others => '0');
		elsif (output_select = "11") then
			output(3) <= input;
			output(0) <= (others => '0');
			output(1) <= (others => '0');
			output(2) <= (others => '0');
		end if;
	end process;
end test;