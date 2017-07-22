library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_control_pwm is	
	port(
		angle1 : in integer range 0 to 65535;
		angle2 : in integer range 0 to 65535;
		angle3 : in integer range 0 to 65535;
		sel : in std_logic_vector(2 downto 0);
		wr_coord : in std_logic;
		update_flag : in std_logic;
		clock : in std_logic;
		angle1_1 : out integer range 0 to 262143;
		angle1_2 : out integer range 0 to 262143;
		angle1_3 : out integer range 0 to 262143;
		angle2_1 : out integer range 0 to 262143;
		angle2_2 : out integer range 0 to 262143;
		angle2_3 : out integer range 0 to 262143;
		angle3_1 : out integer range 0 to 262143;
		angle3_2 : out integer range 0 to 262143;
		angle3_3 : out integer range 0 to 262143;
		angle4_1 : out integer range 0 to 262143;
		angle4_2 : out integer range 0 to 262143;
		angle4_3 : out integer range 0 to 262143;
		angle5_1 : out integer range 0 to 262143;
		angle5_2 : out integer range 0 to 262143;
		angle5_3 : out integer range 0 to 262143;
		angle6_1 : out integer range 0 to 262143;
		angle6_2 : out integer range 0 to 262143;
		angle6_3 : out integer range 0 to 262143;
		request_new_coord : out std_logic := '0');
		
end signal_control_pwm;

architecture main_arch of signal_control_pwm is
	signal reg_angle1_1 : integer range 0 to 262143;
	signal reg_angle1_2 : integer range 0 to 262143;
	signal reg_angle1_3 : integer range 0 to 262143;
	signal reg_angle2_1 : integer range 0 to 262143;
	signal reg_angle2_2 : integer range 0 to 262143;
	signal reg_angle2_3 : integer range 0 to 262143;
	signal reg_angle3_1 : integer range 0 to 262143;
	signal reg_angle3_2 : integer range 0 to 262143;
	signal reg_angle3_3 : integer range 0 to 262143;
	signal reg_angle4_1 : integer range 0 to 262143;
	signal reg_angle4_2 : integer range 0 to 262143;
	signal reg_angle4_3 : integer range 0 to 262143;
	signal reg_angle5_1 : integer range 0 to 262143;
	signal reg_angle5_2 : integer range 0 to 262143;
	signal reg_angle5_3 : integer range 0 to 262143;
	signal reg_angle6_1 : integer range 0 to 262143;
	signal reg_angle6_2 : integer range 0 to 262143;
	signal reg_angle6_3 : integer range 0 to 262143;
	--signal update_flag : std_logic := '0'; versao final
	
begin	
	store_signals : process(clock, wr_coord)--process(sel, wr_coord)
	begin
		if rising_edge(clock) then
			if wr_coord = '1' then
				if sel = "000" then
					reg_angle1_1 <= angle1;-- + 45;
					reg_angle1_2 <= angle2;-- - 45;
					reg_angle1_3 <= angle3;-- + 45;			
					--update_flag <= '0';
				elsif sel = "001" then
					reg_angle2_1 <= angle1;-- + 90;
					reg_angle2_2 <= angle2;-- - 45;
					reg_angle2_3 <= angle3;-- - 45;
				elsif sel = "010" then
					reg_angle3_1 <= angle1;-- + 135;
					reg_angle3_2 <= angle2;-- - 45;
					reg_angle3_3 <= angle3;-- + 45;
				elsif sel = "011" then
					reg_angle4_1 <= angle1;
					reg_angle4_2 <= angle2;
					reg_angle4_3 <= angle3;
				elsif sel = "100" then
					reg_angle5_1 <= angle1;
					reg_angle5_2 <= angle2;
					reg_angle5_3 <= angle3;
				elsif sel = "101" then
					reg_angle6_1 <= angle1;
					reg_angle6_2 <= angle2;
					reg_angle6_3 <= angle3;			
					--update_flag <= '1';
				end if;		
			end if;
		end if;
		--request_new_coord <= update_flag;
	end process;
	
	update_signals : process(clock, update_flag)
	begin
		if rising_edge(clock) then
			if update_flag = '1' then
			--if rising_edge(update_flag) then
				angle1_1 <= reg_angle1_1 * 100;
				angle1_2 <= reg_angle1_2 * 100;
				angle1_3 <= reg_angle1_3 * 100;
				angle2_1 <= reg_angle2_1 * 100;
				angle2_2 <= reg_angle2_2 * 100;
				angle2_3 <= reg_angle2_3 * 100;
				angle3_1 <= reg_angle3_1 * 100;
				angle3_2 <= reg_angle3_2 * 100;
				angle3_3 <= reg_angle3_3 * 100;
				angle4_1 <= reg_angle4_1 * 100;
				angle4_2 <= reg_angle4_2 * 100;
				angle4_3 <= reg_angle4_3 * 100;
				angle5_1 <= reg_angle5_1 * 100;
				angle5_2 <= reg_angle5_2 * 100;
				angle5_3 <= reg_angle5_3 * 100;
				angle6_1 <= reg_angle6_1 * 100;
				angle6_2 <= reg_angle6_2 * 100;
				angle6_3 <= reg_angle6_3 * 100;
			end if;
		end if;
	end process;
end main_arch;