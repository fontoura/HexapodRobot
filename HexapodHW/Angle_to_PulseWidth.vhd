library ieee;

use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;


entity Angle_to_PulseWidth is
	generic(
		angle_min : integer := 45;
		angle_max : integer := 135;
		pulse_min : integer := 1000;
		pulse_max : integer := 1875
	);
	port(
		angle : in integer range 0 to 180;
		pulse : out integer range 0 to 260000);
		--pulse : out integer range 90 to 210);

end Angle_to_PulseWidth;

architecture test of Angle_to_PulseWidth is
begin
	proc : process(angle)
		variable angle_limited : integer range angle_min to angle_max;
	begin
		--y = 1000 + (100*x)/18 
		angle_limited := angle;
		if(angle < angle_min) then
			angle_limited := angle_min;
		end if;
		
		if(angle > angle_max) then
			angle_limited := angle_max;
		end if;
		
		pulse <= 100*(pulse_min + ((pulse_max-pulse_min)*(angle_limited-angle_min))/(angle_max-angle_min));
		--pulse <= 10*angle;
		
		--pulse <= 100*((100*angle_limited)/18 + pulse_min);
		--pulse <= 100*((100*angle_limited)/9 + 500);
	end process;
end test;
