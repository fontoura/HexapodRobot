library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity Generic_reset is
	generic(
		max_counter : integer := 50
	);
	port(
		clock : in std_logic;
		reset : buffer std_logic := '0');

end Generic_reset;

architecture test of Generic_reset is
	signal counter : integer range 0 to max_counter;
begin
	proc: process(clock)
	begin
		if clock'event and clock = '1' then
			if(counter >= (max_counter/2 - 1)) then
				counter <= 0;
				reset <= not reset;
			else				
				counter <= counter + 1;
			end if;			
		end if;
	end process;
end test;