library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity Rom_access is
	port(
		clock : in std_logic;
		start_counter : in std_logic;
		reset : in std_logic;
		addr : out std_logic_vector(7 downto 0) := (others => 'Z');
		end_counter : buffer std_logic := '1');

end Rom_access;

architecture arch of Rom_access is
	signal counter : integer range 0 to 255;
	signal state : std_logic := '0';
	signal end_check : std_logic;
begin
	proc_state : process(start_counter, reset, end_counter)
	begin
		--state 0 = IDLE
		--state 1 = RUNNING
		
		if rising_edge(start_counter) and end_counter = '1' then
			state <= '1';
		end if;
		
		if reset = '1' then
			state <= '0';
		end if;
	end process;
	
	proc_clock : process(clock, state)
	begin
		if state = '1' then
			if rising_edge(clock) then				
				if counter >= 100 then
					counter <= 0;
					end_counter <= '1';
				else
					counter <= counter + 1;
					end_counter <= '0';
				end if;				
			end if;
		else 
			counter <= 0;			
			end_counter <= '0';
		end if;
	end process;
	
	proc: process(counter)
	--std_logic_vector(to_unsigned(natural_number, nb_bits));
	begin		
		if counter = 0 then			
			addr <= (others => 'Z');
		else		
			addr <= std_logic_vector(to_unsigned(counter, 8));
		end if;
	end process;
end arch;