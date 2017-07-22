--Legal Notice: (C)2013 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity timer_sys is 
        port (
              -- inputs:
                 signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal chipselect : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal write_n : IN STD_LOGIC;
                 signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal irq : OUT STD_LOGIC;
                 signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity timer_sys;


architecture europa of timer_sys is
                signal clk_en :  STD_LOGIC;
                signal control_interrupt_enable :  STD_LOGIC;
                signal control_register :  STD_LOGIC;
                signal control_wr_strobe :  STD_LOGIC;
                signal counter_is_running :  STD_LOGIC;
                signal counter_is_zero :  STD_LOGIC;
                signal counter_load_value :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal delayed_unxcounter_is_zeroxx0 :  STD_LOGIC;
                signal do_start_counter :  STD_LOGIC;
                signal do_stop_counter :  STD_LOGIC;
                signal force_reload :  STD_LOGIC;
                signal internal_counter :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal period_h_wr_strobe :  STD_LOGIC;
                signal period_l_wr_strobe :  STD_LOGIC;
                signal read_mux_out :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal status_wr_strobe :  STD_LOGIC;
                signal timeout_event :  STD_LOGIC;
                signal timeout_occurred :  STD_LOGIC;

begin

  clk_en <= std_logic'('1');
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_counter <= std_logic_vector'("11110100001000111111");
    elsif clk'event and clk = '1' then
      if std_logic'((counter_is_running OR force_reload)) = '1' then 
        if std_logic'((counter_is_zero OR force_reload)) = '1' then 
          internal_counter <= counter_load_value;
        else
          internal_counter <= A_EXT (((std_logic_vector'("0000000000000") & (internal_counter)) - std_logic_vector'("000000000000000000000000000000001")), 20);
        end if;
      end if;
    end if;

  end process;

  counter_is_zero <= to_std_logic(((std_logic_vector'("000000000000") & (internal_counter)) = std_logic_vector'("00000000000000000000000000000000")));
  counter_load_value <= std_logic_vector'("11110100001000111111");
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      force_reload <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(clk_en) = '1' then 
        force_reload <= period_h_wr_strobe OR period_l_wr_strobe;
      end if;
    end if;

  end process;

  do_start_counter <= std_logic'('1');
  do_stop_counter <= std_logic'('0');
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      counter_is_running <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(clk_en) = '1' then 
        if std_logic'(do_start_counter) = '1' then 
          counter_is_running <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
        elsif std_logic'(do_stop_counter) = '1' then 
          counter_is_running <= std_logic'('0');
        end if;
      end if;
    end if;

  end process;

  --delayed_unxcounter_is_zeroxx0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      delayed_unxcounter_is_zeroxx0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(clk_en) = '1' then 
        delayed_unxcounter_is_zeroxx0 <= counter_is_zero;
      end if;
    end if;

  end process;

  timeout_event <= (counter_is_zero) AND NOT (delayed_unxcounter_is_zeroxx0);
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timeout_occurred <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(clk_en) = '1' then 
        if std_logic'(status_wr_strobe) = '1' then 
          timeout_occurred <= std_logic'('0');
        elsif std_logic'(timeout_event) = '1' then 
          timeout_occurred <= Vector_To_Std_Logic(-SIGNED(std_logic_vector'("00000000000000000000000000000001")));
        end if;
      end if;
    end if;

  end process;

  irq <= timeout_occurred AND control_interrupt_enable;
  --s1, which is an e_avalon_slave
  read_mux_out <= ((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (address)) = std_logic_vector'("00000000000000000000000000000001")))), 16) AND (std_logic_vector'("000000000000000") & (A_TOSTDLOGICVECTOR(control_register))))) OR ((A_REP(to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (address)) = std_logic_vector'("00000000000000000000000000000000")))), 16) AND (std_logic_vector'("00000000000000") & (Std_Logic_Vector'(A_ToStdLogicVector(counter_is_running) & A_ToStdLogicVector(timeout_occurred))))));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      readdata <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'(clk_en) = '1' then 
        readdata <= read_mux_out;
      end if;
    end if;

  end process;

  period_l_wr_strobe <= (chipselect AND NOT write_n) AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (address)) = std_logic_vector'("00000000000000000000000000000010"))));
  period_h_wr_strobe <= (chipselect AND NOT write_n) AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (address)) = std_logic_vector'("00000000000000000000000000000011"))));
  control_wr_strobe <= (chipselect AND NOT write_n) AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (address)) = std_logic_vector'("00000000000000000000000000000001"))));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      control_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(control_wr_strobe) = '1' then 
        control_register <= writedata(0);
      end if;
    end if;

  end process;

  control_interrupt_enable <= control_register;
  status_wr_strobe <= (chipselect AND NOT write_n) AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (address)) = std_logic_vector'("00000000000000000000000000000000"))));

end europa;

