library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity servo_tester is
	generic(
		width_min : integer := 150000;
		width_max : integer := 190000
	);
	port(
		clock : in std_logic;
		width_out : buffer integer range 0 to 260000 := width_min);

end servo_tester;

architecture main of servo_tester is
	signal direction : std_logic := '0';
begin
	proc: process(clock)
	begin
		if clock'event and clock = '1' then
			if direction = '0' then
				if(width_out >= width_max) then
					--width_out <= width_min;
					direction <= '1';
				else				
					width_out <= width_out + 5000;
				end if;			
			else 
				if(width_out <= width_min) then
					--width_out <= width_min;
					direction <= '0';
				else				
					width_out <= width_out - 5000;
				end if;			
			end if;
		end if;
	end process;
end main;