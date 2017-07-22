library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity invkin_calc_2roms is
	generic(
		L1 : integer := 100;
		L2 : integer := 100);
	
	port(
		x : in integer range -32768 to 32767;
		y : in integer range -32768 to 32767;
		z : in integer range -32768 to 32767;
		acos_data_rom1 : in integer range 0 to 255;
		acos_data_rom2 : in integer range 0 to 255;
		atan_data_rom1 : in integer range 0 to 255;
		atan_data_rom2 : in integer range 0 to 255;
		clock : in std_logic;
		reset : in std_logic;
		theta1 : out integer range 0 to 180;
		theta2 : out integer range 0 to 180;
		theta3 : out integer range 0 to 180;
		acos_addr_rom1 : out integer range 0 to 999;
		acos_addr_rom2 : out integer range 0 to 999;
		atan_addr_rom1 : out integer range 0 to 999;
		atan_addr_rom2 : out integer range 0 to 999;
		rom_clken : out std_logic;
		end_calc : out std_logic := '1');		
end invkin_calc_2roms;

architecture main_arch of invkin_calc_2roms is
	--type state_type is (start_state, theta1_calc, theta1_wr, theta2_calc, theta2_wr, theta3_calc, theta3_wr, end_state);
	type state_type is (set_rom_addr, read_rom_data, end_state);
	signal state : state_type := set_rom_addr;
	signal x_reg : integer range -32768 to 32767;
	signal y_reg : integer range -32768 to 32767;
	signal z_reg : integer range -32768 to 32767;
	
	--codigo vindo de http://vhdlguru.blogspot.com.br/2010/03/vhdl-function-for-finding-square-root.html, modificado para usar integer
	function  sqrt  ( d : integer ) return integer is
		variable a : unsigned(31 downto 0):= to_unsigned(d, 32);  --original input.
		variable q : unsigned(15 downto 0):=(others => '0');  --result.
		variable left,right,r : unsigned(17 downto 0):=(others => '0');  --input to adder/sub.r-remainder.
		variable i : integer:=0;
	begin
		for i in 0 to 15 loop
			right(0):='1';
			right(1):=r(17);
			right(17 downto 2):=q;
			left(1 downto 0):=a(31 downto 30);
			left(17 downto 2):=r(15 downto 0);
			a(31 downto 2):=a(29 downto 0);  --shifting by 2 bit.
			if ( r(17) = '1') then
			r := left + right;
			else
			r := left - right;
			end if;
			q(15 downto 1) := q(14 downto 0);
			q(0) := not r(17);
			end loop; 
		return to_integer(q);
	end sqrt;
	
--	impure function acos (param : integer) return integer is
--		variable addr : integer range 0 to 999;
--		variable data : integer range 0 to 180;
--	begin
--		addr := 500 + param*5;			
--		acos_addr <= addr;
--		data := acos_data;	
--		return data;
--	end acos;
--	
--	impure function atan (param : integer) return integer is
--		variable addr : integer range 0 to 999;
--		variable data : integer range 0 to 180;
--	begin
--		addr := 500 + param/3;			
--		atan_addr <= addr;
--		data := atan_data;	
--		return data;
--	end atan;
	
begin
	state_process : process(clock, reset)
	begin
		if(reset = '1') then
			state <= set_rom_addr;
			rom_clken <= '1';
			x_reg <= x;
			y_reg <= y;
			z_reg <= z;
		else
			if rising_edge(clock) then
				if state = set_rom_addr then
					end_calc <= '0';
					--rom_clken <= '1';
					state <= read_rom_data;
				elsif state = read_rom_data then
					state <= end_state;
				else
					rom_clken <= '0';
					state <= end_state;
					end_calc <= '1';
				end if;
			end if;
		end if;
	end process;
	
	main : process(state)
		variable r : integer range 0 to 255;
		variable d : integer range 0 to 255;
		variable addr : integer range 0 to 999;
		variable data : integer range 0 to 180;
	begin
--		float theta1 = atan2(y, x);
--		float theta2 = acos((pow(L1, 2) - pow(L2, 2) + pow(d, 2))/(2*L1*d)) + atan2(r, z);
--		float theta3 = acos((pow(L1, 2) + pow(L2, 2) - pow(d, 2))/(2*L1*L2));
		
--		theta1 <= atan((25*y)/x);
--		theta2 <= acos((100*(L1*L1 - L2*L2 + d*d))/(2*L1*d));-- + atan((25*r)/z);
--		theta3 <= acos((100*(L1*L1 + L2*L2 - d*d))/(2*L1*L2));
		
--		if state = theta1_calc then
--			atan_addr <= 500 + ((25*y_reg)/x_reg)/3;			
--		elsif state = theta1_wr then
--			data := atan_data;
--			theta1 <= data;
--		elsif state = theta2_calc then
--			r := sqrt(x_reg*x_reg + y_reg*y_reg);
--			d := sqrt(x_reg*x_reg + y_reg*y_reg + z_reg*z_reg);
--			atan_addr <= 500 + ((25*r)/z_reg)/3;
--			acos_addr <= 500 + ((100*(L1*L1 - L2*L2 + d*d))/(2*L1*d))*5;			
--		elsif state = theta2_wr then
--			theta2 <= acos_data + atan_data;
--		elsif state = theta3_calc then
--			r := sqrt(x_reg*x_reg + y_reg*y_reg);
--			d := sqrt(x_reg*x_reg + y_reg*y_reg + z_reg*z_reg);	
--			acos_addr <= 500 + ((100*(L1*L1 + L2*L2 - d*d))/(2*L1*L2))*5;
--		elsif state = theta3_wr then
--			data := acos_data;
--			theta3 <= data;
--		end if;

		if state = set_rom_addr then
			r := sqrt(x_reg*x_reg + y_reg*y_reg);
			d := sqrt(x_reg*x_reg + y_reg*y_reg + z_reg*z_reg);
			
			if x_reg = 0 then
				atan_addr_rom1 <= 999;
			else
--				if (y_reg < 0 and x_reg < 0) or (y_reg > 0 and x_reg < 0) then				
--					atan_addr_rom1 <= 500 - ((25*y_reg)/x_reg)/3;
--				else
					atan_addr_rom1 <= 500 + ((25*y_reg)/x_reg)/3;
--				end if;
				--atan_addr_rom1 <= 500 + ((25*x_reg)/y_reg)/3;
			end if;
			
			if z_reg = 0 then
				atan_addr_rom2 <= 999;	
			else
				atan_addr_rom2 <= 500 + ((25*r)/z_reg)/3;	
				--atan_addr_rom2 <= 500 + ((25*z_reg)/r)/3;	
			end if;
			
			acos_addr_rom1 <= 500 + ((100*(L1*L1 - L2*L2 + d*d))/(2*L1*d))*5;	
			acos_addr_rom2 <= 500 + ((100*(L1*L1 + L2*L2 - d*d))/(2*L1*L2))*5;
		elsif state = read_rom_data then
			theta1 <= atan_data_rom1;--90 - (atan_data_rom1 - 90);-- + 45;			
			theta2 <= acos_data_rom1 + atan_data_rom2;-- - 90;-- - 45;
			theta3 <= acos_data_rom2;--90 - acos_data_rom2;-- - 45;
		end if;
	end process;
end main_arch;