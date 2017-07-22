library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity AngleToPWM is
	generic(
		widthOfPeriod : integer := 10
	);
	port(
		angle : in integer range -18000 to 18000;	
		period : out std_logic_vector(widthOfPeriod-1 downto 0) := std_logic_vector(to_unsigned(166, widthOfPeriod));	
		pwm: out integer range 0 to 166;
		pwm_debug: out integer range 0 to 166;
		direction : out std_logic
	);

end AngleToPWM;

architecture Conversion of AngleToPWM is
	--shared variable abs_angle : integer range 0 to 18000 := abs(angle);	
begin	
	--abs_angle := abs(angle);
	proc : process(angle)
	variable pwm_calc : integer range 0 to 16666666;
	begin
		if angle > 0 then
			direction <= '1';
		else
			direction <= '0';
		end if;
		--pwm <= angle * 922;
		pwm_calc := abs(angle) * 922;
		pwm <= integer(pwm_calc/100000);
		pwm_debug <= integer(pwm_calc/100000);
	end process;
end Conversion;