library ieee;

use ieee.std_logic_1164.all;

entity demux1x6 is
	port(
		input : in std_logic_vector(1 downto 0);
		output_select : in std_logic_vector(2 downto 0) := "000";
		output_0 : out std_logic_vector(1 downto 0);
		output_1 : out std_logic_vector(1 downto 0);
		output_2 : out std_logic_vector(1 downto 0);
		output_3 : out std_logic_vector(1 downto 0);
		output_4 : out std_logic_vector(1 downto 0);
		output_5 : out std_logic_vector(1 downto 0));

end demux1x6;

architecture test of demux1x6 is
begin
	proc: process(input, output_select)
	begin
		if (output_select = "000") then
			output_0 <= input;
			output_1 <= "11";
			output_2 <= "11";
			output_3 <= "11";
			output_4 <= "11";
			output_5 <= "11";
		elsif (output_select = "001") then			
			output_0 <= "11";
			output_1 <= input;
			output_2 <= "11";
			output_3 <= "11";
			output_4 <= "11";
			output_5 <= "11";
		elsif (output_select = "010") then			
			output_0 <= "11";
			output_1 <= "11";
			output_2 <= input;
			output_3 <= "11";
			output_4 <= "11";
			output_5 <= "11";
		elsif (output_select = "011") then			
			output_0 <= "11";
			output_1 <= "11";
			output_2 <= "11";
			output_3 <= input;
			output_4 <= "11";
			output_5 <= "11";
		elsif (output_select = "100") then			
			output_0 <= "11";
			output_1 <= "11";
			output_2 <= "11";
			output_3 <= "11";
			output_4 <= input;
			output_5 <= "11";
		elsif (output_select = "101") then			
			output_0 <= "11";
			output_1 <= "11";
			output_2 <= "11";
			output_3 <= "11";
			output_4 <= "11";
			output_5 <= input;
		end if;
	end process;
end test;