library ieee;

use ieee.std_logic_1164.all;

entity decoder1x4 is
	port(
		input : in std_logic_vector(1 downto 0);
		output_0 : out std_logic;
		output_1 : out std_logic;
		output_2 : out std_logic;
		output_3 : out std_logic);

end decoder1x4;

architecture test of decoder1x4 is
begin
	proc: process(input)
	begin
		if (input = "00") then
			output_0 <= '1';
			output_1 <= '0';
			output_2 <= '0';
			output_3 <= '0';
		elsif (input = "01") then			
			output_0 <= '0';
			output_1 <= '1';
			output_2 <= '0';
			output_3 <= '0';
		elsif (input = "10") then			
			output_0 <= '0';
			output_1 <= '0';
			output_2 <= '1';
			output_3 <= '0';
		elsif (input = "11") then
			output_0 <= '0';
			output_1 <= '0';
			output_2 <= '0';
			output_3 <= '1';
		end if;
	end process;
end test;