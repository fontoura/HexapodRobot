library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Controller is
	generic (
		-- largura do barramento com o per�odo
		period: integer := 10
	);
	port(
		clock : in std_logic;		
		--pwmIn_target: in std_logic_vector(WidthOfPeriod - 1 downto 0);
		angIn_real: in integer range 0 to 18000;
		angIn_target: in integer range 0 to 18000;-- := 9000;
		angOut: out integer range -18000 to 18000;
		error_debug : out integer range 0 to 180;
		angOut_debug : out integer range 0 to 180
		--pwmIn_real: in std_logic_vector(WidthOfPeriod - 1 downto 0);
		--pwmOut: out std_logic_vector(WidthOfPeriod - 1 downto 0)
	);

end Controller;

architecture Control of Controller is
	signal P : integer range 0 to 1000 := 2;
	signal I : integer range 0 to 1000 := 1;
	signal D : integer range 0 to 1000 := 1;
	signal P_out : integer range -18000 to 18000;
	signal I_out : integer range -18000 to 18000;	
	signal D_out : integer range -18000 to 18000;
begin
	proc: process(clock)
	variable prev_I_out : integer range 0 to 1000;	
	variable error : integer range -9000 to 9000;
	variable prev_error : integer range -9000 to 9000;
	begin
		if rising_edge(clock) then
			error := (angIn_target - angIn_real);
			error_debug <= integer(abs(error)/100);
			
			P_out <= P * error;
			I_out <= prev_I_out + (P*period/integer(I)) * (integer((error+prev_error)/2));
			
			--angOut <= P_out + I_out;
			angOut <= P_out;
			--angOut_debug <= integer(abs(P_out)/100);
			
			prev_error := error;
			prev_I_out := I_out;
		end if;
	end process;
end Control;