library ieee;

use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;


entity PulseWidthToAngle is
	port(
		pulse : in integer range 0 to 1000;			
		--angle: out integer range 0 to 180
		angle: out integer range 0 to 18000;
		angle_debug : out integer range 0 to 180
		--pulse : in std_logic_vector(10 downto 0);
		--angle: out std_logic_vector(7 downto 0)
	);

end PulseWidthToAngle;

architecture Conversion of PulseWidthToAngle is
	signal angle_out : integer range 0 to 18000;
	signal pulse_read : integer range 0 to 1000;
begin
	--x = (y-60)/2.11
	--angle <= std_logic_vector((unsigned(pulse) - to_unsigned(60, 6))/);
	--angle <= std_logic_vector(10 + 10);
	proc : process(pulse)
	begin
		if(pulse > 500) then
			pulse_read <= 500;
		elsif(pulse < 80) then
			pulse_read <= 80;
		else
			pulse_read <= pulse;
		end if;		
		angle_out <= (pulse_read - 60)*47;
		angle <= angle_out;
		angle_debug <= integer(angle_out/100);
	end process;	
end Conversion;