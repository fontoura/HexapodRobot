library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debug_pwm is	
	port(
		x : in integer range -32768 to 32767;
		y : in integer range -32768 to 32767;
		z : in integer range -32768 to 32767;
		clock : in std_logic;
		reset : in std_logic;
		angle1 : out integer range 0 to 255;
		angle2 : out integer range 0 to 255;
		angle3 : out integer range 0 to 255);
		
end debug_pwm;

architecture main_arch of debug_pwm is
	--signal update_flag : std_logic := '0'; versao final
	
begin	
	proc : process(clock)
	begin
		angle1 <= x;
		angle2 <= y;
		angle3 <= z;
	end process;
end main_arch;