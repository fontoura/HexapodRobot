library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_control is	
	port(
		angle1 : in integer range 0 to 180;
		angle2 : in integer range 0 to 180;
		angle3 : in integer range 0 to 180;
		sel : in std_logic_vector(2 downto 0);
		wr_coord : in std_logic;
		update_flag : in std_logic;
		clock : in std_logic;
		angle1_1 : out integer range 0 to 180;
		angle1_2 : out integer range 0 to 180;
		angle1_3 : out integer range 0 to 180;
		angle2_1 : out integer range 0 to 180;
		angle2_2 : out integer range 0 to 180;
		angle2_3 : out integer range 0 to 180;
		angle3_1 : out integer range 0 to 180;
		angle3_2 : out integer range 0 to 180;
		angle3_3 : out integer range 0 to 180;
		angle4_1 : out integer range 0 to 180;
		angle4_2 : out integer range 0 to 180;
		angle4_3 : out integer range 0 to 180;
		angle5_1 : out integer range 0 to 180;
		angle5_2 : out integer range 0 to 180;
		angle5_3 : out integer range 0 to 180;
		angle6_1 : out integer range 0 to 180;
		angle6_2 : out integer range 0 to 180;
		angle6_3 : out integer range 0 to 180;
		request_new_coord : out std_logic := '0');
		
end signal_control;

architecture main_arch of signal_control is
	signal reg_angle1_1 : integer range 0 to 180;
	signal reg_angle1_2 : integer range 0 to 180;
	signal reg_angle1_3 : integer range 0 to 180;
	signal reg_angle2_1 : integer range 0 to 180;
	signal reg_angle2_2 : integer range 0 to 180;
	signal reg_angle2_3 : integer range 0 to 180;
	signal reg_angle3_1 : integer range 0 to 180;
	signal reg_angle3_2 : integer range 0 to 180;
	signal reg_angle3_3 : integer range 0 to 180;
	signal reg_angle4_1 : integer range 0 to 180;
	signal reg_angle4_2 : integer range 0 to 180;
	signal reg_angle4_3 : integer range 0 to 180;
	signal reg_angle5_1 : integer range 0 to 180;
	signal reg_angle5_2 : integer range 0 to 180;
	signal reg_angle5_3 : integer range 0 to 180;
	signal reg_angle6_1 : integer range 0 to 180;
	signal reg_angle6_2 : integer range 0 to 180;
	signal reg_angle6_3 : integer range 0 to 180;
	--signal update_flag : std_logic := '0'; versao final
	
begin	
	store_signals : process(clock, wr_coord)--process(sel, wr_coord)
	begin
		if rising_edge(clock) then
			if wr_coord = '1' then
				if sel = "000" then
					reg_angle1_1 <= angle1 - 45;-- + 45;
					reg_angle1_2 <= angle2 - 90 - 45;-- - 45;
					reg_angle1_3 <= 90 - angle3 + 45;-- + 45;			
					--update_flag <= '0';
				elsif sel = "001" then
					reg_angle2_1 <= angle1;-- + 90;
					reg_angle2_2 <= angle2 - 90 - 45;-- - 45;
					reg_angle2_3 <= 90 - angle3 + 45;-- - 45;
				elsif sel = "010" then
					reg_angle3_1 <= angle1 + 45;-- + 135;
					reg_angle3_2 <= angle2 - 90 - 45;-- - 45;
					reg_angle3_3 <= 90 - angle3 + 45;-- + 45;
				elsif sel = "011" then
					reg_angle4_1 <= angle1 - 45;
					reg_angle4_2 <= 180 - (angle2 - 90 - 45);
					reg_angle4_3 <= 180 - (90 - angle3 + 45);		
				elsif sel = "100" then
					reg_angle5_1 <= angle1;
					reg_angle5_2 <= 180 - (angle2 - 90 - 45);
					reg_angle5_3 <= 180 - (90 - angle3 + 45);		
				elsif sel = "101" then
					reg_angle6_1 <= angle1 + 45;--180 - (angle1 - 45);
					reg_angle6_2 <= 180 - (angle2 - 90 - 45);
					reg_angle6_3 <= 180 - (90 - angle3 + 45);			
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
				angle1_1 <= reg_angle1_1;
				angle1_2 <= reg_angle1_2;
				angle1_3 <= reg_angle1_3;
				angle2_1 <= reg_angle2_1;
				angle2_2 <= reg_angle2_2;
				angle2_3 <= reg_angle2_3;
				angle3_1 <= reg_angle3_1;
				angle3_2 <= reg_angle3_2;
				angle3_3 <= reg_angle3_3;
				angle4_1 <= reg_angle4_1;
				angle4_2 <= reg_angle4_2;
				angle4_3 <= reg_angle4_3;
				angle5_1 <= reg_angle5_1;
				angle5_2 <= reg_angle5_2;
				angle5_3 <= reg_angle5_3;
				angle6_1 <= reg_angle6_1;
				angle6_2 <= reg_angle6_2;
				angle6_3 <= reg_angle6_3;
			end if;
		end if;
	end process;
end main_arch;