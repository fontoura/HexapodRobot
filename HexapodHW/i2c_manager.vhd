library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity i2c_manager is	
	port(
		scl_pad_i : out std_logic;
		scl_pad_o : in std_logic;
		scl_padoen_oe : in std_logic;
		sda_pad_i : out std_logic;
		sda_pad_o : in std_logic;
		sda_padoen_oe : in std_logic;
		scl : inout std_logic;
		sda : inout std_logic);		
end i2c_manager;

architecture main_arch of i2c_manager is	
begin
	scl <= scl_pad_o when(scl_padoen_oe = '0') else 'Z';
	sda <= sda_pad_o when(sda_padoen_oe = '0') else 'Z';
	scl_pad_i <= scl;
	sda_pad_i <= sda;
end main_arch;