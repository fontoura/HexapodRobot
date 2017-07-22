--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


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

entity I2C_Master_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal I2C_Master_avalon_slave_irq : IN STD_LOGIC;
                 signal I2C_Master_avalon_slave_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal I2C_Master_avalon_slave_waitrequest_n : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal I2C_Master_avalon_slave_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal I2C_Master_avalon_slave_chipselect : OUT STD_LOGIC;
                 signal I2C_Master_avalon_slave_irq_from_sa : OUT STD_LOGIC;
                 signal I2C_Master_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal I2C_Master_avalon_slave_reset : OUT STD_LOGIC;
                 signal I2C_Master_avalon_slave_waitrequest_n_from_sa : OUT STD_LOGIC;
                 signal I2C_Master_avalon_slave_write : OUT STD_LOGIC;
                 signal I2C_Master_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_data_master_granted_I2C_Master_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_I2C_Master_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_I2C_Master_avalon_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_I2C_Master_avalon_slave : OUT STD_LOGIC;
                 signal d1_I2C_Master_avalon_slave_end_xfer : OUT STD_LOGIC
              );
end entity I2C_Master_avalon_slave_arbitrator;


architecture europa of I2C_Master_avalon_slave_arbitrator is
                signal I2C_Master_avalon_slave_allgrants :  STD_LOGIC;
                signal I2C_Master_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal I2C_Master_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal I2C_Master_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal I2C_Master_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal I2C_Master_avalon_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal I2C_Master_avalon_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal I2C_Master_avalon_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal I2C_Master_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal I2C_Master_avalon_slave_begins_xfer :  STD_LOGIC;
                signal I2C_Master_avalon_slave_end_xfer :  STD_LOGIC;
                signal I2C_Master_avalon_slave_firsttransfer :  STD_LOGIC;
                signal I2C_Master_avalon_slave_grant_vector :  STD_LOGIC;
                signal I2C_Master_avalon_slave_in_a_read_cycle :  STD_LOGIC;
                signal I2C_Master_avalon_slave_in_a_write_cycle :  STD_LOGIC;
                signal I2C_Master_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal I2C_Master_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal I2C_Master_avalon_slave_pretend_byte_enable :  STD_LOGIC;
                signal I2C_Master_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal I2C_Master_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal I2C_Master_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal I2C_Master_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal I2C_Master_avalon_slave_waits_for_read :  STD_LOGIC;
                signal I2C_Master_avalon_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_I2C_Master_avalon_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_I2C_Master_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_I2C_Master_avalon_slave_waitrequest_n_from_sa :  STD_LOGIC;
                signal internal_cpu_data_master_granted_I2C_Master_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_I2C_Master_avalon_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_I2C_Master_avalon_slave :  STD_LOGIC;
                signal shifted_address_to_I2C_Master_avalon_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_I2C_Master_avalon_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT I2C_Master_avalon_slave_end_xfer;
    end if;

  end process;

  I2C_Master_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_I2C_Master_avalon_slave);
  --assign I2C_Master_avalon_slave_readdata_from_sa = I2C_Master_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  I2C_Master_avalon_slave_readdata_from_sa <= I2C_Master_avalon_slave_readdata;
  internal_cpu_data_master_requests_I2C_Master_avalon_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("100000000000001000011000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign I2C_Master_avalon_slave_waitrequest_n_from_sa = I2C_Master_avalon_slave_waitrequest_n so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_I2C_Master_avalon_slave_waitrequest_n_from_sa <= I2C_Master_avalon_slave_waitrequest_n;
  --I2C_Master_avalon_slave_arb_share_counter set values, which is an e_mux
  I2C_Master_avalon_slave_arb_share_set_values <= std_logic_vector'("01");
  --I2C_Master_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  I2C_Master_avalon_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_I2C_Master_avalon_slave;
  --I2C_Master_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  I2C_Master_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --I2C_Master_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  I2C_Master_avalon_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(I2C_Master_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (I2C_Master_avalon_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(I2C_Master_avalon_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (I2C_Master_avalon_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --I2C_Master_avalon_slave_allgrants all slave grants, which is an e_mux
  I2C_Master_avalon_slave_allgrants <= I2C_Master_avalon_slave_grant_vector;
  --I2C_Master_avalon_slave_end_xfer assignment, which is an e_assign
  I2C_Master_avalon_slave_end_xfer <= NOT ((I2C_Master_avalon_slave_waits_for_read OR I2C_Master_avalon_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_I2C_Master_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_I2C_Master_avalon_slave <= I2C_Master_avalon_slave_end_xfer AND (((NOT I2C_Master_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --I2C_Master_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  I2C_Master_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_I2C_Master_avalon_slave AND I2C_Master_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_I2C_Master_avalon_slave AND NOT I2C_Master_avalon_slave_non_bursting_master_requests));
  --I2C_Master_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      I2C_Master_avalon_slave_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(I2C_Master_avalon_slave_arb_counter_enable) = '1' then 
        I2C_Master_avalon_slave_arb_share_counter <= I2C_Master_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --I2C_Master_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      I2C_Master_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((I2C_Master_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_I2C_Master_avalon_slave)) OR ((end_xfer_arb_share_counter_term_I2C_Master_avalon_slave AND NOT I2C_Master_avalon_slave_non_bursting_master_requests)))) = '1' then 
        I2C_Master_avalon_slave_slavearbiterlockenable <= or_reduce(I2C_Master_avalon_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master I2C_Master/avalon_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= I2C_Master_avalon_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --I2C_Master_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  I2C_Master_avalon_slave_slavearbiterlockenable2 <= or_reduce(I2C_Master_avalon_slave_arb_share_counter_next_value);
  --cpu/data_master I2C_Master/avalon_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= I2C_Master_avalon_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --I2C_Master_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  I2C_Master_avalon_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_I2C_Master_avalon_slave <= internal_cpu_data_master_requests_I2C_Master_avalon_slave AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --I2C_Master_avalon_slave_writedata mux, which is an e_mux
  I2C_Master_avalon_slave_writedata <= cpu_data_master_writedata (7 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_I2C_Master_avalon_slave <= internal_cpu_data_master_qualified_request_I2C_Master_avalon_slave;
  --cpu/data_master saved-grant I2C_Master/avalon_slave, which is an e_assign
  cpu_data_master_saved_grant_I2C_Master_avalon_slave <= internal_cpu_data_master_requests_I2C_Master_avalon_slave;
  --allow new arb cycle for I2C_Master/avalon_slave, which is an e_assign
  I2C_Master_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  I2C_Master_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  I2C_Master_avalon_slave_master_qreq_vector <= std_logic'('1');
  --~I2C_Master_avalon_slave_reset assignment, which is an e_assign
  I2C_Master_avalon_slave_reset <= NOT reset_n;
  I2C_Master_avalon_slave_chipselect <= internal_cpu_data_master_granted_I2C_Master_avalon_slave;
  --I2C_Master_avalon_slave_firsttransfer first transaction, which is an e_assign
  I2C_Master_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(I2C_Master_avalon_slave_begins_xfer) = '1'), I2C_Master_avalon_slave_unreg_firsttransfer, I2C_Master_avalon_slave_reg_firsttransfer);
  --I2C_Master_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  I2C_Master_avalon_slave_unreg_firsttransfer <= NOT ((I2C_Master_avalon_slave_slavearbiterlockenable AND I2C_Master_avalon_slave_any_continuerequest));
  --I2C_Master_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      I2C_Master_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(I2C_Master_avalon_slave_begins_xfer) = '1' then 
        I2C_Master_avalon_slave_reg_firsttransfer <= I2C_Master_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --I2C_Master_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  I2C_Master_avalon_slave_beginbursttransfer_internal <= I2C_Master_avalon_slave_begins_xfer;
  --I2C_Master_avalon_slave_write assignment, which is an e_mux
  I2C_Master_avalon_slave_write <= ((internal_cpu_data_master_granted_I2C_Master_avalon_slave AND cpu_data_master_write)) AND I2C_Master_avalon_slave_pretend_byte_enable;
  shifted_address_to_I2C_Master_avalon_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --I2C_Master_avalon_slave_address mux, which is an e_mux
  I2C_Master_avalon_slave_address <= A_EXT (A_SRL(shifted_address_to_I2C_Master_avalon_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_I2C_Master_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_I2C_Master_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_I2C_Master_avalon_slave_end_xfer <= I2C_Master_avalon_slave_end_xfer;
    end if;

  end process;

  --I2C_Master_avalon_slave_waits_for_read in a cycle, which is an e_mux
  I2C_Master_avalon_slave_waits_for_read <= I2C_Master_avalon_slave_in_a_read_cycle AND NOT internal_I2C_Master_avalon_slave_waitrequest_n_from_sa;
  --I2C_Master_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  I2C_Master_avalon_slave_in_a_read_cycle <= internal_cpu_data_master_granted_I2C_Master_avalon_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= I2C_Master_avalon_slave_in_a_read_cycle;
  --I2C_Master_avalon_slave_waits_for_write in a cycle, which is an e_mux
  I2C_Master_avalon_slave_waits_for_write <= I2C_Master_avalon_slave_in_a_write_cycle AND NOT internal_I2C_Master_avalon_slave_waitrequest_n_from_sa;
  --I2C_Master_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  I2C_Master_avalon_slave_in_a_write_cycle <= internal_cpu_data_master_granted_I2C_Master_avalon_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= I2C_Master_avalon_slave_in_a_write_cycle;
  wait_for_I2C_Master_avalon_slave_counter <= std_logic'('0');
  --I2C_Master_avalon_slave_pretend_byte_enable byte enable port mux, which is an e_mux
  I2C_Master_avalon_slave_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_I2C_Master_avalon_slave)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --assign I2C_Master_avalon_slave_irq_from_sa = I2C_Master_avalon_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  I2C_Master_avalon_slave_irq_from_sa <= I2C_Master_avalon_slave_irq;
  --vhdl renameroo for output signals
  I2C_Master_avalon_slave_waitrequest_n_from_sa <= internal_I2C_Master_avalon_slave_waitrequest_n_from_sa;
  --vhdl renameroo for output signals
  cpu_data_master_granted_I2C_Master_avalon_slave <= internal_cpu_data_master_granted_I2C_Master_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_I2C_Master_avalon_slave <= internal_cpu_data_master_qualified_request_I2C_Master_avalon_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_I2C_Master_avalon_slave <= internal_cpu_data_master_requests_I2C_Master_avalon_slave;
--synthesis translate_off
    --I2C_Master/avalon_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity TERASIC_SPI_3WIRE_0_slave_arbitrator is 
        port (
              -- inputs:
                 signal TERASIC_SPI_3WIRE_0_slave_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal TERASIC_SPI_3WIRE_0_slave_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal TERASIC_SPI_3WIRE_0_slave_chipselect : OUT STD_LOGIC;
                 signal TERASIC_SPI_3WIRE_0_slave_read : OUT STD_LOGIC;
                 signal TERASIC_SPI_3WIRE_0_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal TERASIC_SPI_3WIRE_0_slave_reset_n : OUT STD_LOGIC;
                 signal TERASIC_SPI_3WIRE_0_slave_write : OUT STD_LOGIC;
                 signal TERASIC_SPI_3WIRE_0_slave_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                 signal d1_TERASIC_SPI_3WIRE_0_slave_end_xfer : OUT STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC
              );
end entity TERASIC_SPI_3WIRE_0_slave_arbitrator;


architecture europa of TERASIC_SPI_3WIRE_0_slave_arbitrator is
                signal TERASIC_SPI_3WIRE_0_slave_allgrants :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_any_continuerequest :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_arb_counter_enable :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal TERASIC_SPI_3WIRE_0_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal TERASIC_SPI_3WIRE_0_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal TERASIC_SPI_3WIRE_0_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_begins_xfer :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_end_xfer :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_firsttransfer :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_grant_vector :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_in_a_read_cycle :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_in_a_write_cycle :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_master_qreq_vector :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_non_bursting_master_requests :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_pretend_byte_enable :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_reg_firsttransfer :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_unreg_firsttransfer :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_waits_for_read :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register :  STD_LOGIC;
                signal shifted_address_to_TERASIC_SPI_3WIRE_0_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_TERASIC_SPI_3WIRE_0_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT TERASIC_SPI_3WIRE_0_slave_end_xfer;
    end if;

  end process;

  TERASIC_SPI_3WIRE_0_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave);
  --assign TERASIC_SPI_3WIRE_0_slave_readdata_from_sa = TERASIC_SPI_3WIRE_0_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_readdata_from_sa <= TERASIC_SPI_3WIRE_0_slave_readdata;
  internal_cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 6) & std_logic_vector'("000000")) = std_logic_vector'("100000000000001000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave <= cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register_in;
  --TERASIC_SPI_3WIRE_0_slave_arb_share_counter set values, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_arb_share_set_values <= std_logic_vector'("01");
  --TERASIC_SPI_3WIRE_0_slave_non_bursting_master_requests mux, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave;
  --TERASIC_SPI_3WIRE_0_slave_any_bursting_master_saved_grant mux, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --TERASIC_SPI_3WIRE_0_slave_arb_share_counter_next_value assignment, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(TERASIC_SPI_3WIRE_0_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (TERASIC_SPI_3WIRE_0_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(TERASIC_SPI_3WIRE_0_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (TERASIC_SPI_3WIRE_0_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --TERASIC_SPI_3WIRE_0_slave_allgrants all slave grants, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_allgrants <= TERASIC_SPI_3WIRE_0_slave_grant_vector;
  --TERASIC_SPI_3WIRE_0_slave_end_xfer assignment, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_end_xfer <= NOT ((TERASIC_SPI_3WIRE_0_slave_waits_for_read OR TERASIC_SPI_3WIRE_0_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_TERASIC_SPI_3WIRE_0_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_TERASIC_SPI_3WIRE_0_slave <= TERASIC_SPI_3WIRE_0_slave_end_xfer AND (((NOT TERASIC_SPI_3WIRE_0_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --TERASIC_SPI_3WIRE_0_slave_arb_share_counter arbitration counter enable, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_TERASIC_SPI_3WIRE_0_slave AND TERASIC_SPI_3WIRE_0_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_TERASIC_SPI_3WIRE_0_slave AND NOT TERASIC_SPI_3WIRE_0_slave_non_bursting_master_requests));
  --TERASIC_SPI_3WIRE_0_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TERASIC_SPI_3WIRE_0_slave_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(TERASIC_SPI_3WIRE_0_slave_arb_counter_enable) = '1' then 
        TERASIC_SPI_3WIRE_0_slave_arb_share_counter <= TERASIC_SPI_3WIRE_0_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((TERASIC_SPI_3WIRE_0_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_TERASIC_SPI_3WIRE_0_slave)) OR ((end_xfer_arb_share_counter_term_TERASIC_SPI_3WIRE_0_slave AND NOT TERASIC_SPI_3WIRE_0_slave_non_bursting_master_requests)))) = '1' then 
        TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable <= or_reduce(TERASIC_SPI_3WIRE_0_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master TERASIC_SPI_3WIRE_0/slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable2 <= or_reduce(TERASIC_SPI_3WIRE_0_slave_arb_share_counter_next_value);
  --cpu/data_master TERASIC_SPI_3WIRE_0/slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --TERASIC_SPI_3WIRE_0_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave <= internal_cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave AND NOT ((((cpu_data_master_read AND (cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register_in <= ((internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave AND cpu_data_master_read) AND NOT TERASIC_SPI_3WIRE_0_slave_waits_for_read) AND NOT (cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register_in)));
  --cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register <= p1_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave, which is an e_mux
  cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave <= cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave_shift_register;
  --TERASIC_SPI_3WIRE_0_slave_writedata mux, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_writedata <= cpu_data_master_writedata (7 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave <= internal_cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave;
  --cpu/data_master saved-grant TERASIC_SPI_3WIRE_0/slave, which is an e_assign
  cpu_data_master_saved_grant_TERASIC_SPI_3WIRE_0_slave <= internal_cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave;
  --allow new arb cycle for TERASIC_SPI_3WIRE_0/slave, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  TERASIC_SPI_3WIRE_0_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  TERASIC_SPI_3WIRE_0_slave_master_qreq_vector <= std_logic'('1');
  --TERASIC_SPI_3WIRE_0_slave_reset_n assignment, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_reset_n <= reset_n;
  TERASIC_SPI_3WIRE_0_slave_chipselect <= internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave;
  --TERASIC_SPI_3WIRE_0_slave_firsttransfer first transaction, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_firsttransfer <= A_WE_StdLogic((std_logic'(TERASIC_SPI_3WIRE_0_slave_begins_xfer) = '1'), TERASIC_SPI_3WIRE_0_slave_unreg_firsttransfer, TERASIC_SPI_3WIRE_0_slave_reg_firsttransfer);
  --TERASIC_SPI_3WIRE_0_slave_unreg_firsttransfer first transaction, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_unreg_firsttransfer <= NOT ((TERASIC_SPI_3WIRE_0_slave_slavearbiterlockenable AND TERASIC_SPI_3WIRE_0_slave_any_continuerequest));
  --TERASIC_SPI_3WIRE_0_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      TERASIC_SPI_3WIRE_0_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(TERASIC_SPI_3WIRE_0_slave_begins_xfer) = '1' then 
        TERASIC_SPI_3WIRE_0_slave_reg_firsttransfer <= TERASIC_SPI_3WIRE_0_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --TERASIC_SPI_3WIRE_0_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_beginbursttransfer_internal <= TERASIC_SPI_3WIRE_0_slave_begins_xfer;
  --TERASIC_SPI_3WIRE_0_slave_read assignment, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_read <= internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave AND cpu_data_master_read;
  --TERASIC_SPI_3WIRE_0_slave_write assignment, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_write <= ((internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave AND cpu_data_master_write)) AND TERASIC_SPI_3WIRE_0_slave_pretend_byte_enable;
  shifted_address_to_TERASIC_SPI_3WIRE_0_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --TERASIC_SPI_3WIRE_0_slave_address mux, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_address <= A_EXT (A_SRL(shifted_address_to_TERASIC_SPI_3WIRE_0_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 4);
  --d1_TERASIC_SPI_3WIRE_0_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_TERASIC_SPI_3WIRE_0_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_TERASIC_SPI_3WIRE_0_slave_end_xfer <= TERASIC_SPI_3WIRE_0_slave_end_xfer;
    end if;

  end process;

  --TERASIC_SPI_3WIRE_0_slave_waits_for_read in a cycle, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TERASIC_SPI_3WIRE_0_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TERASIC_SPI_3WIRE_0_slave_in_a_read_cycle assignment, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_in_a_read_cycle <= internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= TERASIC_SPI_3WIRE_0_slave_in_a_read_cycle;
  --TERASIC_SPI_3WIRE_0_slave_waits_for_write in a cycle, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(TERASIC_SPI_3WIRE_0_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --TERASIC_SPI_3WIRE_0_slave_in_a_write_cycle assignment, which is an e_assign
  TERASIC_SPI_3WIRE_0_slave_in_a_write_cycle <= internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= TERASIC_SPI_3WIRE_0_slave_in_a_write_cycle;
  wait_for_TERASIC_SPI_3WIRE_0_slave_counter <= std_logic'('0');
  --TERASIC_SPI_3WIRE_0_slave_pretend_byte_enable byte enable port mux, which is an e_mux
  TERASIC_SPI_3WIRE_0_slave_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --vhdl renameroo for output signals
  cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave <= internal_cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave <= internal_cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave <= internal_cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave;
--synthesis translate_off
    --TERASIC_SPI_3WIRE_0/slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity Teste_SOPC_clock_0_in_arbitrator is 
        port (
              -- inputs:
                 signal Teste_SOPC_clock_0_in_endofpacket : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_0_in_waitrequest : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal Teste_SOPC_clock_0_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Teste_SOPC_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal Teste_SOPC_clock_0_in_read : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_0_in_reset_n : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_in_write : OUT STD_LOGIC;
                 signal cpu_instruction_master_granted_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                 signal d1_Teste_SOPC_clock_0_in_end_xfer : OUT STD_LOGIC
              );
end entity Teste_SOPC_clock_0_in_arbitrator;


architecture europa of Teste_SOPC_clock_0_in_arbitrator is
                signal Teste_SOPC_clock_0_in_allgrants :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_allow_new_arb_cycle :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_any_continuerequest :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_arb_counter_enable :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_beginbursttransfer_internal :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_begins_xfer :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_end_xfer :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_firsttransfer :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_grant_vector :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_in_a_read_cycle :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_in_a_write_cycle :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_master_qreq_vector :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_non_bursting_master_requests :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_reg_firsttransfer :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_slavearbiterlockenable :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_unreg_firsttransfer :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_waits_for_read :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_waits_for_write :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal wait_for_Teste_SOPC_clock_0_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT Teste_SOPC_clock_0_in_end_xfer;
    end if;

  end process;

  Teste_SOPC_clock_0_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in);
  --assign Teste_SOPC_clock_0_in_readdata_from_sa = Teste_SOPC_clock_0_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  Teste_SOPC_clock_0_in_readdata_from_sa <= Teste_SOPC_clock_0_in_readdata;
  internal_cpu_instruction_master_requests_Teste_SOPC_clock_0_in <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(26 DOWNTO 25) & std_logic_vector'("0000000000000000000000000")) = std_logic_vector'("010000000000000000000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --assign Teste_SOPC_clock_0_in_waitrequest_from_sa = Teste_SOPC_clock_0_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_Teste_SOPC_clock_0_in_waitrequest_from_sa <= Teste_SOPC_clock_0_in_waitrequest;
  --Teste_SOPC_clock_0_in_arb_share_counter set values, which is an e_mux
  Teste_SOPC_clock_0_in_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_instruction_master_granted_Teste_SOPC_clock_0_in)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000001")), 2);
  --Teste_SOPC_clock_0_in_non_bursting_master_requests mux, which is an e_mux
  Teste_SOPC_clock_0_in_non_bursting_master_requests <= internal_cpu_instruction_master_requests_Teste_SOPC_clock_0_in;
  --Teste_SOPC_clock_0_in_any_bursting_master_saved_grant mux, which is an e_mux
  Teste_SOPC_clock_0_in_any_bursting_master_saved_grant <= std_logic'('0');
  --Teste_SOPC_clock_0_in_arb_share_counter_next_value assignment, which is an e_assign
  Teste_SOPC_clock_0_in_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(Teste_SOPC_clock_0_in_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (Teste_SOPC_clock_0_in_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(Teste_SOPC_clock_0_in_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (Teste_SOPC_clock_0_in_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --Teste_SOPC_clock_0_in_allgrants all slave grants, which is an e_mux
  Teste_SOPC_clock_0_in_allgrants <= Teste_SOPC_clock_0_in_grant_vector;
  --Teste_SOPC_clock_0_in_end_xfer assignment, which is an e_assign
  Teste_SOPC_clock_0_in_end_xfer <= NOT ((Teste_SOPC_clock_0_in_waits_for_read OR Teste_SOPC_clock_0_in_waits_for_write));
  --end_xfer_arb_share_counter_term_Teste_SOPC_clock_0_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_Teste_SOPC_clock_0_in <= Teste_SOPC_clock_0_in_end_xfer AND (((NOT Teste_SOPC_clock_0_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --Teste_SOPC_clock_0_in_arb_share_counter arbitration counter enable, which is an e_assign
  Teste_SOPC_clock_0_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_Teste_SOPC_clock_0_in AND Teste_SOPC_clock_0_in_allgrants)) OR ((end_xfer_arb_share_counter_term_Teste_SOPC_clock_0_in AND NOT Teste_SOPC_clock_0_in_non_bursting_master_requests));
  --Teste_SOPC_clock_0_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Teste_SOPC_clock_0_in_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(Teste_SOPC_clock_0_in_arb_counter_enable) = '1' then 
        Teste_SOPC_clock_0_in_arb_share_counter <= Teste_SOPC_clock_0_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --Teste_SOPC_clock_0_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Teste_SOPC_clock_0_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((Teste_SOPC_clock_0_in_master_qreq_vector AND end_xfer_arb_share_counter_term_Teste_SOPC_clock_0_in)) OR ((end_xfer_arb_share_counter_term_Teste_SOPC_clock_0_in AND NOT Teste_SOPC_clock_0_in_non_bursting_master_requests)))) = '1' then 
        Teste_SOPC_clock_0_in_slavearbiterlockenable <= or_reduce(Teste_SOPC_clock_0_in_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/instruction_master Teste_SOPC_clock_0/in arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= Teste_SOPC_clock_0_in_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --Teste_SOPC_clock_0_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  Teste_SOPC_clock_0_in_slavearbiterlockenable2 <= or_reduce(Teste_SOPC_clock_0_in_arb_share_counter_next_value);
  --cpu/instruction_master Teste_SOPC_clock_0/in arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= Teste_SOPC_clock_0_in_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --Teste_SOPC_clock_0_in_any_continuerequest at least one master continues requesting, which is an e_assign
  Teste_SOPC_clock_0_in_any_continuerequest <= std_logic'('1');
  --cpu_instruction_master_continuerequest continued request, which is an e_assign
  cpu_instruction_master_continuerequest <= std_logic'('1');
  internal_cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in <= internal_cpu_instruction_master_requests_Teste_SOPC_clock_0_in;
  --assign Teste_SOPC_clock_0_in_endofpacket_from_sa = Teste_SOPC_clock_0_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  Teste_SOPC_clock_0_in_endofpacket_from_sa <= Teste_SOPC_clock_0_in_endofpacket;
  --master is always granted when requested
  internal_cpu_instruction_master_granted_Teste_SOPC_clock_0_in <= internal_cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in;
  --cpu/instruction_master saved-grant Teste_SOPC_clock_0/in, which is an e_assign
  cpu_instruction_master_saved_grant_Teste_SOPC_clock_0_in <= internal_cpu_instruction_master_requests_Teste_SOPC_clock_0_in;
  --allow new arb cycle for Teste_SOPC_clock_0/in, which is an e_assign
  Teste_SOPC_clock_0_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  Teste_SOPC_clock_0_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  Teste_SOPC_clock_0_in_master_qreq_vector <= std_logic'('1');
  --Teste_SOPC_clock_0_in_reset_n assignment, which is an e_assign
  Teste_SOPC_clock_0_in_reset_n <= reset_n;
  --Teste_SOPC_clock_0_in_firsttransfer first transaction, which is an e_assign
  Teste_SOPC_clock_0_in_firsttransfer <= A_WE_StdLogic((std_logic'(Teste_SOPC_clock_0_in_begins_xfer) = '1'), Teste_SOPC_clock_0_in_unreg_firsttransfer, Teste_SOPC_clock_0_in_reg_firsttransfer);
  --Teste_SOPC_clock_0_in_unreg_firsttransfer first transaction, which is an e_assign
  Teste_SOPC_clock_0_in_unreg_firsttransfer <= NOT ((Teste_SOPC_clock_0_in_slavearbiterlockenable AND Teste_SOPC_clock_0_in_any_continuerequest));
  --Teste_SOPC_clock_0_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Teste_SOPC_clock_0_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(Teste_SOPC_clock_0_in_begins_xfer) = '1' then 
        Teste_SOPC_clock_0_in_reg_firsttransfer <= Teste_SOPC_clock_0_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --Teste_SOPC_clock_0_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  Teste_SOPC_clock_0_in_beginbursttransfer_internal <= Teste_SOPC_clock_0_in_begins_xfer;
  --Teste_SOPC_clock_0_in_read assignment, which is an e_mux
  Teste_SOPC_clock_0_in_read <= internal_cpu_instruction_master_granted_Teste_SOPC_clock_0_in AND cpu_instruction_master_read;
  --Teste_SOPC_clock_0_in_write assignment, which is an e_mux
  Teste_SOPC_clock_0_in_write <= std_logic'('0');
  --Teste_SOPC_clock_0_in_address mux, which is an e_mux
  Teste_SOPC_clock_0_in_address <= A_EXT (Std_Logic_Vector'(A_SRL(cpu_instruction_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & A_ToStdLogicVector(cpu_instruction_master_dbs_address(1)) & A_ToStdLogicVector(std_logic'('0'))), 25);
  --slaveid Teste_SOPC_clock_0_in_nativeaddress nativeaddress mux, which is an e_mux
  Teste_SOPC_clock_0_in_nativeaddress <= A_EXT (A_SRL(cpu_instruction_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 24);
  --d1_Teste_SOPC_clock_0_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_Teste_SOPC_clock_0_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_Teste_SOPC_clock_0_in_end_xfer <= Teste_SOPC_clock_0_in_end_xfer;
    end if;

  end process;

  --Teste_SOPC_clock_0_in_waits_for_read in a cycle, which is an e_mux
  Teste_SOPC_clock_0_in_waits_for_read <= Teste_SOPC_clock_0_in_in_a_read_cycle AND internal_Teste_SOPC_clock_0_in_waitrequest_from_sa;
  --Teste_SOPC_clock_0_in_in_a_read_cycle assignment, which is an e_assign
  Teste_SOPC_clock_0_in_in_a_read_cycle <= internal_cpu_instruction_master_granted_Teste_SOPC_clock_0_in AND cpu_instruction_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= Teste_SOPC_clock_0_in_in_a_read_cycle;
  --Teste_SOPC_clock_0_in_waits_for_write in a cycle, which is an e_mux
  Teste_SOPC_clock_0_in_waits_for_write <= Teste_SOPC_clock_0_in_in_a_write_cycle AND internal_Teste_SOPC_clock_0_in_waitrequest_from_sa;
  --Teste_SOPC_clock_0_in_in_a_write_cycle assignment, which is an e_assign
  Teste_SOPC_clock_0_in_in_a_write_cycle <= std_logic'('0');
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= Teste_SOPC_clock_0_in_in_a_write_cycle;
  wait_for_Teste_SOPC_clock_0_in_counter <= std_logic'('0');
  --Teste_SOPC_clock_0_in_byteenable byte enable port mux, which is an e_mux
  Teste_SOPC_clock_0_in_byteenable <= A_EXT (-SIGNED(std_logic_vector'("00000000000000000000000000000001")), 2);
  --vhdl renameroo for output signals
  Teste_SOPC_clock_0_in_waitrequest_from_sa <= internal_Teste_SOPC_clock_0_in_waitrequest_from_sa;
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_Teste_SOPC_clock_0_in <= internal_cpu_instruction_master_granted_Teste_SOPC_clock_0_in;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in <= internal_cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_Teste_SOPC_clock_0_in <= internal_cpu_instruction_master_requests_Teste_SOPC_clock_0_in;
--synthesis translate_off
    --Teste_SOPC_clock_0/in enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

library std;
use std.textio.all;

entity Teste_SOPC_clock_0_out_arbitrator is 
        port (
              -- inputs:
                 signal Teste_SOPC_clock_0_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Teste_SOPC_clock_0_out_granted_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_qualified_request_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_read : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_requests_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_write : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_sdram_s1_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sdram_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal sdram_s1_waitrequest_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal Teste_SOPC_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_0_out_reset_n : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_waitrequest : OUT STD_LOGIC
              );
end entity Teste_SOPC_clock_0_out_arbitrator;


architecture europa of Teste_SOPC_clock_0_out_arbitrator is
                signal Teste_SOPC_clock_0_out_address_last_time :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_byteenable_last_time :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_read_last_time :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_run :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_write_last_time :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_writedata_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal internal_Teste_SOPC_clock_0_out_waitrequest :  STD_LOGIC;
                signal r_3 :  STD_LOGIC;

begin

  --r_3 master_run cascaded wait assignment, which is an e_assign
  r_3 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((Teste_SOPC_clock_0_out_qualified_request_sdram_s1 OR Teste_SOPC_clock_0_out_read_data_valid_sdram_s1) OR NOT Teste_SOPC_clock_0_out_requests_sdram_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((Teste_SOPC_clock_0_out_granted_sdram_s1 OR NOT Teste_SOPC_clock_0_out_qualified_request_sdram_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT Teste_SOPC_clock_0_out_qualified_request_sdram_s1 OR NOT Teste_SOPC_clock_0_out_read) OR ((Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 AND Teste_SOPC_clock_0_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT Teste_SOPC_clock_0_out_qualified_request_sdram_s1 OR NOT ((Teste_SOPC_clock_0_out_read OR Teste_SOPC_clock_0_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT sdram_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((Teste_SOPC_clock_0_out_read OR Teste_SOPC_clock_0_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  Teste_SOPC_clock_0_out_run <= r_3;
  --optimize select-logic by passing only those address bits which matter.
  internal_Teste_SOPC_clock_0_out_address_to_slave <= Teste_SOPC_clock_0_out_address;
  --Teste_SOPC_clock_0/out readdata mux, which is an e_mux
  Teste_SOPC_clock_0_out_readdata <= sdram_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_Teste_SOPC_clock_0_out_waitrequest <= NOT Teste_SOPC_clock_0_out_run;
  --Teste_SOPC_clock_0_out_reset_n assignment, which is an e_assign
  Teste_SOPC_clock_0_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_0_out_address_to_slave <= internal_Teste_SOPC_clock_0_out_address_to_slave;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_0_out_waitrequest <= internal_Teste_SOPC_clock_0_out_waitrequest;
--synthesis translate_off
    --Teste_SOPC_clock_0_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_0_out_address_last_time <= std_logic_vector'("0000000000000000000000000");
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_0_out_address_last_time <= Teste_SOPC_clock_0_out_address;
      end if;

    end process;

    --Teste_SOPC_clock_0/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_Teste_SOPC_clock_0_out_waitrequest AND ((Teste_SOPC_clock_0_out_read OR Teste_SOPC_clock_0_out_write));
      end if;

    end process;

    --Teste_SOPC_clock_0_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((Teste_SOPC_clock_0_out_address /= Teste_SOPC_clock_0_out_address_last_time))))) = '1' then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("Teste_SOPC_clock_0_out_address did not heed wait!!!"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_0_out_byteenable_last_time <= std_logic_vector'("00");
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_0_out_byteenable_last_time <= Teste_SOPC_clock_0_out_byteenable;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((Teste_SOPC_clock_0_out_byteenable /= Teste_SOPC_clock_0_out_byteenable_last_time))))) = '1' then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("Teste_SOPC_clock_0_out_byteenable did not heed wait!!!"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_0_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_0_out_read_last_time <= Teste_SOPC_clock_0_out_read;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(Teste_SOPC_clock_0_out_read) /= std_logic'(Teste_SOPC_clock_0_out_read_last_time)))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("Teste_SOPC_clock_0_out_read did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_0_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_0_out_write_last_time <= Teste_SOPC_clock_0_out_write;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(Teste_SOPC_clock_0_out_write) /= std_logic'(Teste_SOPC_clock_0_out_write_last_time)))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("Teste_SOPC_clock_0_out_write did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_0_out_writedata_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_0_out_writedata_last_time <= Teste_SOPC_clock_0_out_writedata;
      end if;

    end process;

    --Teste_SOPC_clock_0_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((Teste_SOPC_clock_0_out_writedata /= Teste_SOPC_clock_0_out_writedata_last_time)))) AND Teste_SOPC_clock_0_out_write)) = '1' then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("Teste_SOPC_clock_0_out_writedata did not heed wait!!!"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity Teste_SOPC_clock_1_in_arbitrator is 
        port (
              -- inputs:
                 signal Teste_SOPC_clock_1_in_endofpacket : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_1_in_waitrequest : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_data_master_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal Teste_SOPC_clock_1_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Teste_SOPC_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal Teste_SOPC_clock_1_in_read : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_1_in_reset_n : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_in_write : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_data_master_byteenable_Teste_SOPC_clock_1_in : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_data_master_granted_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                 signal cpu_data_master_requests_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                 signal d1_Teste_SOPC_clock_1_in_end_xfer : OUT STD_LOGIC
              );
end entity Teste_SOPC_clock_1_in_arbitrator;


architecture europa of Teste_SOPC_clock_1_in_arbitrator is
                signal Teste_SOPC_clock_1_in_allgrants :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_allow_new_arb_cycle :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_any_continuerequest :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_arb_counter_enable :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_beginbursttransfer_internal :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_begins_xfer :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_end_xfer :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_firsttransfer :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_grant_vector :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_in_a_read_cycle :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_in_a_write_cycle :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_master_qreq_vector :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_non_bursting_master_requests :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_reg_firsttransfer :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_slavearbiterlockenable :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_unreg_firsttransfer :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_waits_for_read :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_1 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal internal_cpu_data_master_byteenable_Teste_SOPC_clock_1_in :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_cpu_data_master_granted_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal internal_cpu_data_master_requests_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal wait_for_Teste_SOPC_clock_1_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT Teste_SOPC_clock_1_in_end_xfer;
    end if;

  end process;

  Teste_SOPC_clock_1_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_Teste_SOPC_clock_1_in);
  --assign Teste_SOPC_clock_1_in_readdata_from_sa = Teste_SOPC_clock_1_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  Teste_SOPC_clock_1_in_readdata_from_sa <= Teste_SOPC_clock_1_in_readdata;
  internal_cpu_data_master_requests_Teste_SOPC_clock_1_in <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 25) & std_logic_vector'("0000000000000000000000000")) = std_logic_vector'("010000000000000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign Teste_SOPC_clock_1_in_waitrequest_from_sa = Teste_SOPC_clock_1_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_Teste_SOPC_clock_1_in_waitrequest_from_sa <= Teste_SOPC_clock_1_in_waitrequest;
  --Teste_SOPC_clock_1_in_arb_share_counter set values, which is an e_mux
  Teste_SOPC_clock_1_in_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_Teste_SOPC_clock_1_in)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000001")), 2);
  --Teste_SOPC_clock_1_in_non_bursting_master_requests mux, which is an e_mux
  Teste_SOPC_clock_1_in_non_bursting_master_requests <= internal_cpu_data_master_requests_Teste_SOPC_clock_1_in;
  --Teste_SOPC_clock_1_in_any_bursting_master_saved_grant mux, which is an e_mux
  Teste_SOPC_clock_1_in_any_bursting_master_saved_grant <= std_logic'('0');
  --Teste_SOPC_clock_1_in_arb_share_counter_next_value assignment, which is an e_assign
  Teste_SOPC_clock_1_in_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(Teste_SOPC_clock_1_in_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (Teste_SOPC_clock_1_in_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(Teste_SOPC_clock_1_in_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (Teste_SOPC_clock_1_in_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --Teste_SOPC_clock_1_in_allgrants all slave grants, which is an e_mux
  Teste_SOPC_clock_1_in_allgrants <= Teste_SOPC_clock_1_in_grant_vector;
  --Teste_SOPC_clock_1_in_end_xfer assignment, which is an e_assign
  Teste_SOPC_clock_1_in_end_xfer <= NOT ((Teste_SOPC_clock_1_in_waits_for_read OR Teste_SOPC_clock_1_in_waits_for_write));
  --end_xfer_arb_share_counter_term_Teste_SOPC_clock_1_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_Teste_SOPC_clock_1_in <= Teste_SOPC_clock_1_in_end_xfer AND (((NOT Teste_SOPC_clock_1_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --Teste_SOPC_clock_1_in_arb_share_counter arbitration counter enable, which is an e_assign
  Teste_SOPC_clock_1_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_Teste_SOPC_clock_1_in AND Teste_SOPC_clock_1_in_allgrants)) OR ((end_xfer_arb_share_counter_term_Teste_SOPC_clock_1_in AND NOT Teste_SOPC_clock_1_in_non_bursting_master_requests));
  --Teste_SOPC_clock_1_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Teste_SOPC_clock_1_in_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(Teste_SOPC_clock_1_in_arb_counter_enable) = '1' then 
        Teste_SOPC_clock_1_in_arb_share_counter <= Teste_SOPC_clock_1_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --Teste_SOPC_clock_1_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Teste_SOPC_clock_1_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((Teste_SOPC_clock_1_in_master_qreq_vector AND end_xfer_arb_share_counter_term_Teste_SOPC_clock_1_in)) OR ((end_xfer_arb_share_counter_term_Teste_SOPC_clock_1_in AND NOT Teste_SOPC_clock_1_in_non_bursting_master_requests)))) = '1' then 
        Teste_SOPC_clock_1_in_slavearbiterlockenable <= or_reduce(Teste_SOPC_clock_1_in_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master Teste_SOPC_clock_1/in arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= Teste_SOPC_clock_1_in_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --Teste_SOPC_clock_1_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  Teste_SOPC_clock_1_in_slavearbiterlockenable2 <= or_reduce(Teste_SOPC_clock_1_in_arb_share_counter_next_value);
  --cpu/data_master Teste_SOPC_clock_1/in arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= Teste_SOPC_clock_1_in_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --Teste_SOPC_clock_1_in_any_continuerequest at least one master continues requesting, which is an e_assign
  Teste_SOPC_clock_1_in_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_Teste_SOPC_clock_1_in <= internal_cpu_data_master_requests_Teste_SOPC_clock_1_in AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((((NOT cpu_data_master_waitrequest OR cpu_data_master_no_byte_enables_and_last_term) OR NOT(or_reduce(internal_cpu_data_master_byteenable_Teste_SOPC_clock_1_in)))) AND cpu_data_master_write))));
  --Teste_SOPC_clock_1_in_writedata mux, which is an e_mux
  Teste_SOPC_clock_1_in_writedata <= cpu_data_master_dbs_write_16;
  --assign Teste_SOPC_clock_1_in_endofpacket_from_sa = Teste_SOPC_clock_1_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  Teste_SOPC_clock_1_in_endofpacket_from_sa <= Teste_SOPC_clock_1_in_endofpacket;
  --master is always granted when requested
  internal_cpu_data_master_granted_Teste_SOPC_clock_1_in <= internal_cpu_data_master_qualified_request_Teste_SOPC_clock_1_in;
  --cpu/data_master saved-grant Teste_SOPC_clock_1/in, which is an e_assign
  cpu_data_master_saved_grant_Teste_SOPC_clock_1_in <= internal_cpu_data_master_requests_Teste_SOPC_clock_1_in;
  --allow new arb cycle for Teste_SOPC_clock_1/in, which is an e_assign
  Teste_SOPC_clock_1_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  Teste_SOPC_clock_1_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  Teste_SOPC_clock_1_in_master_qreq_vector <= std_logic'('1');
  --Teste_SOPC_clock_1_in_reset_n assignment, which is an e_assign
  Teste_SOPC_clock_1_in_reset_n <= reset_n;
  --Teste_SOPC_clock_1_in_firsttransfer first transaction, which is an e_assign
  Teste_SOPC_clock_1_in_firsttransfer <= A_WE_StdLogic((std_logic'(Teste_SOPC_clock_1_in_begins_xfer) = '1'), Teste_SOPC_clock_1_in_unreg_firsttransfer, Teste_SOPC_clock_1_in_reg_firsttransfer);
  --Teste_SOPC_clock_1_in_unreg_firsttransfer first transaction, which is an e_assign
  Teste_SOPC_clock_1_in_unreg_firsttransfer <= NOT ((Teste_SOPC_clock_1_in_slavearbiterlockenable AND Teste_SOPC_clock_1_in_any_continuerequest));
  --Teste_SOPC_clock_1_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Teste_SOPC_clock_1_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(Teste_SOPC_clock_1_in_begins_xfer) = '1' then 
        Teste_SOPC_clock_1_in_reg_firsttransfer <= Teste_SOPC_clock_1_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --Teste_SOPC_clock_1_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  Teste_SOPC_clock_1_in_beginbursttransfer_internal <= Teste_SOPC_clock_1_in_begins_xfer;
  --Teste_SOPC_clock_1_in_read assignment, which is an e_mux
  Teste_SOPC_clock_1_in_read <= internal_cpu_data_master_granted_Teste_SOPC_clock_1_in AND cpu_data_master_read;
  --Teste_SOPC_clock_1_in_write assignment, which is an e_mux
  Teste_SOPC_clock_1_in_write <= internal_cpu_data_master_granted_Teste_SOPC_clock_1_in AND cpu_data_master_write;
  --Teste_SOPC_clock_1_in_address mux, which is an e_mux
  Teste_SOPC_clock_1_in_address <= A_EXT (Std_Logic_Vector'(A_SRL(cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & A_ToStdLogicVector(cpu_data_master_dbs_address(1)) & A_ToStdLogicVector(std_logic'('0'))), 25);
  --slaveid Teste_SOPC_clock_1_in_nativeaddress nativeaddress mux, which is an e_mux
  Teste_SOPC_clock_1_in_nativeaddress <= A_EXT (A_SRL(cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 24);
  --d1_Teste_SOPC_clock_1_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_Teste_SOPC_clock_1_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_Teste_SOPC_clock_1_in_end_xfer <= Teste_SOPC_clock_1_in_end_xfer;
    end if;

  end process;

  --Teste_SOPC_clock_1_in_waits_for_read in a cycle, which is an e_mux
  Teste_SOPC_clock_1_in_waits_for_read <= Teste_SOPC_clock_1_in_in_a_read_cycle AND internal_Teste_SOPC_clock_1_in_waitrequest_from_sa;
  --Teste_SOPC_clock_1_in_in_a_read_cycle assignment, which is an e_assign
  Teste_SOPC_clock_1_in_in_a_read_cycle <= internal_cpu_data_master_granted_Teste_SOPC_clock_1_in AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= Teste_SOPC_clock_1_in_in_a_read_cycle;
  --Teste_SOPC_clock_1_in_waits_for_write in a cycle, which is an e_mux
  Teste_SOPC_clock_1_in_waits_for_write <= Teste_SOPC_clock_1_in_in_a_write_cycle AND internal_Teste_SOPC_clock_1_in_waitrequest_from_sa;
  --Teste_SOPC_clock_1_in_in_a_write_cycle assignment, which is an e_assign
  Teste_SOPC_clock_1_in_in_a_write_cycle <= internal_cpu_data_master_granted_Teste_SOPC_clock_1_in AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= Teste_SOPC_clock_1_in_in_a_write_cycle;
  wait_for_Teste_SOPC_clock_1_in_counter <= std_logic'('0');
  --Teste_SOPC_clock_1_in_byteenable byte enable port mux, which is an e_mux
  Teste_SOPC_clock_1_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_Teste_SOPC_clock_1_in)) = '1'), (std_logic_vector'("000000000000000000000000000000") & (internal_cpu_data_master_byteenable_Teste_SOPC_clock_1_in)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 2);
  (cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_1(1), cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_1(0), cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_0(1), cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_0(0)) <= cpu_data_master_byteenable;
  internal_cpu_data_master_byteenable_Teste_SOPC_clock_1_in <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_dbs_address(1)))) = std_logic_vector'("00000000000000000000000000000000"))), cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_0, cpu_data_master_byteenable_Teste_SOPC_clock_1_in_segment_1);
  --vhdl renameroo for output signals
  Teste_SOPC_clock_1_in_waitrequest_from_sa <= internal_Teste_SOPC_clock_1_in_waitrequest_from_sa;
  --vhdl renameroo for output signals
  cpu_data_master_byteenable_Teste_SOPC_clock_1_in <= internal_cpu_data_master_byteenable_Teste_SOPC_clock_1_in;
  --vhdl renameroo for output signals
  cpu_data_master_granted_Teste_SOPC_clock_1_in <= internal_cpu_data_master_granted_Teste_SOPC_clock_1_in;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_Teste_SOPC_clock_1_in <= internal_cpu_data_master_qualified_request_Teste_SOPC_clock_1_in;
  --vhdl renameroo for output signals
  cpu_data_master_requests_Teste_SOPC_clock_1_in <= internal_cpu_data_master_requests_Teste_SOPC_clock_1_in;
--synthesis translate_off
    --Teste_SOPC_clock_1/in enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

library std;
use std.textio.all;

entity Teste_SOPC_clock_1_out_arbitrator is 
        port (
              -- inputs:
                 signal Teste_SOPC_clock_1_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Teste_SOPC_clock_1_out_granted_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_qualified_request_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_read : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_requests_sdram_s1 : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_write : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_sdram_s1_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sdram_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal sdram_s1_waitrequest_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal Teste_SOPC_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_1_out_reset_n : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_waitrequest : OUT STD_LOGIC
              );
end entity Teste_SOPC_clock_1_out_arbitrator;


architecture europa of Teste_SOPC_clock_1_out_arbitrator is
                signal Teste_SOPC_clock_1_out_address_last_time :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_byteenable_last_time :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_read_last_time :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_run :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_write_last_time :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_writedata_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal internal_Teste_SOPC_clock_1_out_waitrequest :  STD_LOGIC;
                signal r_3 :  STD_LOGIC;

begin

  --r_3 master_run cascaded wait assignment, which is an e_assign
  r_3 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((Teste_SOPC_clock_1_out_qualified_request_sdram_s1 OR Teste_SOPC_clock_1_out_read_data_valid_sdram_s1) OR NOT Teste_SOPC_clock_1_out_requests_sdram_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((Teste_SOPC_clock_1_out_granted_sdram_s1 OR NOT Teste_SOPC_clock_1_out_qualified_request_sdram_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT Teste_SOPC_clock_1_out_qualified_request_sdram_s1 OR NOT Teste_SOPC_clock_1_out_read) OR ((Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 AND Teste_SOPC_clock_1_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT Teste_SOPC_clock_1_out_qualified_request_sdram_s1 OR NOT ((Teste_SOPC_clock_1_out_read OR Teste_SOPC_clock_1_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT sdram_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((Teste_SOPC_clock_1_out_read OR Teste_SOPC_clock_1_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  Teste_SOPC_clock_1_out_run <= r_3;
  --optimize select-logic by passing only those address bits which matter.
  internal_Teste_SOPC_clock_1_out_address_to_slave <= Teste_SOPC_clock_1_out_address;
  --Teste_SOPC_clock_1/out readdata mux, which is an e_mux
  Teste_SOPC_clock_1_out_readdata <= sdram_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_Teste_SOPC_clock_1_out_waitrequest <= NOT Teste_SOPC_clock_1_out_run;
  --Teste_SOPC_clock_1_out_reset_n assignment, which is an e_assign
  Teste_SOPC_clock_1_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_1_out_address_to_slave <= internal_Teste_SOPC_clock_1_out_address_to_slave;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_1_out_waitrequest <= internal_Teste_SOPC_clock_1_out_waitrequest;
--synthesis translate_off
    --Teste_SOPC_clock_1_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_1_out_address_last_time <= std_logic_vector'("0000000000000000000000000");
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_1_out_address_last_time <= Teste_SOPC_clock_1_out_address;
      end if;

    end process;

    --Teste_SOPC_clock_1/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_Teste_SOPC_clock_1_out_waitrequest AND ((Teste_SOPC_clock_1_out_read OR Teste_SOPC_clock_1_out_write));
      end if;

    end process;

    --Teste_SOPC_clock_1_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((Teste_SOPC_clock_1_out_address /= Teste_SOPC_clock_1_out_address_last_time))))) = '1' then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("Teste_SOPC_clock_1_out_address did not heed wait!!!"));
          write(output, write_line5.all);
          deallocate (write_line5);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_1_out_byteenable_last_time <= std_logic_vector'("00");
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_1_out_byteenable_last_time <= Teste_SOPC_clock_1_out_byteenable;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((Teste_SOPC_clock_1_out_byteenable /= Teste_SOPC_clock_1_out_byteenable_last_time))))) = '1' then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("Teste_SOPC_clock_1_out_byteenable did not heed wait!!!"));
          write(output, write_line6.all);
          deallocate (write_line6);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_1_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_1_out_read_last_time <= Teste_SOPC_clock_1_out_read;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(Teste_SOPC_clock_1_out_read) /= std_logic'(Teste_SOPC_clock_1_out_read_last_time)))))) = '1' then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("Teste_SOPC_clock_1_out_read did not heed wait!!!"));
          write(output, write_line7.all);
          deallocate (write_line7);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_1_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_1_out_write_last_time <= Teste_SOPC_clock_1_out_write;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(Teste_SOPC_clock_1_out_write) /= std_logic'(Teste_SOPC_clock_1_out_write_last_time)))))) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("Teste_SOPC_clock_1_out_write did not heed wait!!!"));
          write(output, write_line8.all);
          deallocate (write_line8);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        Teste_SOPC_clock_1_out_writedata_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        Teste_SOPC_clock_1_out_writedata_last_time <= Teste_SOPC_clock_1_out_writedata;
      end if;

    end process;

    --Teste_SOPC_clock_1_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((Teste_SOPC_clock_1_out_writedata /= Teste_SOPC_clock_1_out_writedata_last_time)))) AND Teste_SOPC_clock_1_out_write)) = '1' then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("Teste_SOPC_clock_1_out_writedata did not heed wait!!!"));
          write(output, write_line9.all);
          deallocate (write_line9);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity altpll_sdram_pll_slave_arbitrator is 
        port (
              -- inputs:
                 signal altpll_sdram_pll_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal altpll_sdram_pll_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal altpll_sdram_pll_slave_read : OUT STD_LOGIC;
                 signal altpll_sdram_pll_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal altpll_sdram_pll_slave_reset : OUT STD_LOGIC;
                 signal altpll_sdram_pll_slave_write : OUT STD_LOGIC;
                 signal altpll_sdram_pll_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_granted_altpll_sdram_pll_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_altpll_sdram_pll_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_altpll_sdram_pll_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_altpll_sdram_pll_slave : OUT STD_LOGIC;
                 signal d1_altpll_sdram_pll_slave_end_xfer : OUT STD_LOGIC
              );
end entity altpll_sdram_pll_slave_arbitrator;


architecture europa of altpll_sdram_pll_slave_arbitrator is
                signal altpll_sdram_pll_slave_allgrants :  STD_LOGIC;
                signal altpll_sdram_pll_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal altpll_sdram_pll_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal altpll_sdram_pll_slave_any_continuerequest :  STD_LOGIC;
                signal altpll_sdram_pll_slave_arb_counter_enable :  STD_LOGIC;
                signal altpll_sdram_pll_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altpll_sdram_pll_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altpll_sdram_pll_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altpll_sdram_pll_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal altpll_sdram_pll_slave_begins_xfer :  STD_LOGIC;
                signal altpll_sdram_pll_slave_end_xfer :  STD_LOGIC;
                signal altpll_sdram_pll_slave_firsttransfer :  STD_LOGIC;
                signal altpll_sdram_pll_slave_grant_vector :  STD_LOGIC;
                signal altpll_sdram_pll_slave_in_a_read_cycle :  STD_LOGIC;
                signal altpll_sdram_pll_slave_in_a_write_cycle :  STD_LOGIC;
                signal altpll_sdram_pll_slave_master_qreq_vector :  STD_LOGIC;
                signal altpll_sdram_pll_slave_non_bursting_master_requests :  STD_LOGIC;
                signal altpll_sdram_pll_slave_reg_firsttransfer :  STD_LOGIC;
                signal altpll_sdram_pll_slave_slavearbiterlockenable :  STD_LOGIC;
                signal altpll_sdram_pll_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal altpll_sdram_pll_slave_unreg_firsttransfer :  STD_LOGIC;
                signal altpll_sdram_pll_slave_waits_for_read :  STD_LOGIC;
                signal altpll_sdram_pll_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_altpll_sdram_pll_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_altpll_sdram_pll_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_altpll_sdram_pll_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_altpll_sdram_pll_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_altpll_sdram_pll_slave :  STD_LOGIC;
                signal shifted_address_to_altpll_sdram_pll_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_altpll_sdram_pll_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT altpll_sdram_pll_slave_end_xfer;
    end if;

  end process;

  altpll_sdram_pll_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_altpll_sdram_pll_slave);
  --assign altpll_sdram_pll_slave_readdata_from_sa = altpll_sdram_pll_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  altpll_sdram_pll_slave_readdata_from_sa <= altpll_sdram_pll_slave_readdata;
  internal_cpu_data_master_requests_altpll_sdram_pll_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000011110000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --altpll_sdram_pll_slave_arb_share_counter set values, which is an e_mux
  altpll_sdram_pll_slave_arb_share_set_values <= std_logic_vector'("01");
  --altpll_sdram_pll_slave_non_bursting_master_requests mux, which is an e_mux
  altpll_sdram_pll_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_altpll_sdram_pll_slave;
  --altpll_sdram_pll_slave_any_bursting_master_saved_grant mux, which is an e_mux
  altpll_sdram_pll_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --altpll_sdram_pll_slave_arb_share_counter_next_value assignment, which is an e_assign
  altpll_sdram_pll_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(altpll_sdram_pll_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (altpll_sdram_pll_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(altpll_sdram_pll_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (altpll_sdram_pll_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --altpll_sdram_pll_slave_allgrants all slave grants, which is an e_mux
  altpll_sdram_pll_slave_allgrants <= altpll_sdram_pll_slave_grant_vector;
  --altpll_sdram_pll_slave_end_xfer assignment, which is an e_assign
  altpll_sdram_pll_slave_end_xfer <= NOT ((altpll_sdram_pll_slave_waits_for_read OR altpll_sdram_pll_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_altpll_sdram_pll_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_altpll_sdram_pll_slave <= altpll_sdram_pll_slave_end_xfer AND (((NOT altpll_sdram_pll_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --altpll_sdram_pll_slave_arb_share_counter arbitration counter enable, which is an e_assign
  altpll_sdram_pll_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_altpll_sdram_pll_slave AND altpll_sdram_pll_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_altpll_sdram_pll_slave AND NOT altpll_sdram_pll_slave_non_bursting_master_requests));
  --altpll_sdram_pll_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altpll_sdram_pll_slave_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(altpll_sdram_pll_slave_arb_counter_enable) = '1' then 
        altpll_sdram_pll_slave_arb_share_counter <= altpll_sdram_pll_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --altpll_sdram_pll_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altpll_sdram_pll_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((altpll_sdram_pll_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_altpll_sdram_pll_slave)) OR ((end_xfer_arb_share_counter_term_altpll_sdram_pll_slave AND NOT altpll_sdram_pll_slave_non_bursting_master_requests)))) = '1' then 
        altpll_sdram_pll_slave_slavearbiterlockenable <= or_reduce(altpll_sdram_pll_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master altpll_sdram/pll_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= altpll_sdram_pll_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --altpll_sdram_pll_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  altpll_sdram_pll_slave_slavearbiterlockenable2 <= or_reduce(altpll_sdram_pll_slave_arb_share_counter_next_value);
  --cpu/data_master altpll_sdram/pll_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= altpll_sdram_pll_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --altpll_sdram_pll_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  altpll_sdram_pll_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_altpll_sdram_pll_slave <= internal_cpu_data_master_requests_altpll_sdram_pll_slave AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --altpll_sdram_pll_slave_writedata mux, which is an e_mux
  altpll_sdram_pll_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_altpll_sdram_pll_slave <= internal_cpu_data_master_qualified_request_altpll_sdram_pll_slave;
  --cpu/data_master saved-grant altpll_sdram/pll_slave, which is an e_assign
  cpu_data_master_saved_grant_altpll_sdram_pll_slave <= internal_cpu_data_master_requests_altpll_sdram_pll_slave;
  --allow new arb cycle for altpll_sdram/pll_slave, which is an e_assign
  altpll_sdram_pll_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  altpll_sdram_pll_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  altpll_sdram_pll_slave_master_qreq_vector <= std_logic'('1');
  --~altpll_sdram_pll_slave_reset assignment, which is an e_assign
  altpll_sdram_pll_slave_reset <= NOT reset_n;
  --altpll_sdram_pll_slave_firsttransfer first transaction, which is an e_assign
  altpll_sdram_pll_slave_firsttransfer <= A_WE_StdLogic((std_logic'(altpll_sdram_pll_slave_begins_xfer) = '1'), altpll_sdram_pll_slave_unreg_firsttransfer, altpll_sdram_pll_slave_reg_firsttransfer);
  --altpll_sdram_pll_slave_unreg_firsttransfer first transaction, which is an e_assign
  altpll_sdram_pll_slave_unreg_firsttransfer <= NOT ((altpll_sdram_pll_slave_slavearbiterlockenable AND altpll_sdram_pll_slave_any_continuerequest));
  --altpll_sdram_pll_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altpll_sdram_pll_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(altpll_sdram_pll_slave_begins_xfer) = '1' then 
        altpll_sdram_pll_slave_reg_firsttransfer <= altpll_sdram_pll_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --altpll_sdram_pll_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  altpll_sdram_pll_slave_beginbursttransfer_internal <= altpll_sdram_pll_slave_begins_xfer;
  --altpll_sdram_pll_slave_read assignment, which is an e_mux
  altpll_sdram_pll_slave_read <= internal_cpu_data_master_granted_altpll_sdram_pll_slave AND cpu_data_master_read;
  --altpll_sdram_pll_slave_write assignment, which is an e_mux
  altpll_sdram_pll_slave_write <= internal_cpu_data_master_granted_altpll_sdram_pll_slave AND cpu_data_master_write;
  shifted_address_to_altpll_sdram_pll_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --altpll_sdram_pll_slave_address mux, which is an e_mux
  altpll_sdram_pll_slave_address <= A_EXT (A_SRL(shifted_address_to_altpll_sdram_pll_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_altpll_sdram_pll_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_altpll_sdram_pll_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_altpll_sdram_pll_slave_end_xfer <= altpll_sdram_pll_slave_end_xfer;
    end if;

  end process;

  --altpll_sdram_pll_slave_waits_for_read in a cycle, which is an e_mux
  altpll_sdram_pll_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altpll_sdram_pll_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --altpll_sdram_pll_slave_in_a_read_cycle assignment, which is an e_assign
  altpll_sdram_pll_slave_in_a_read_cycle <= internal_cpu_data_master_granted_altpll_sdram_pll_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= altpll_sdram_pll_slave_in_a_read_cycle;
  --altpll_sdram_pll_slave_waits_for_write in a cycle, which is an e_mux
  altpll_sdram_pll_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altpll_sdram_pll_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --altpll_sdram_pll_slave_in_a_write_cycle assignment, which is an e_assign
  altpll_sdram_pll_slave_in_a_write_cycle <= internal_cpu_data_master_granted_altpll_sdram_pll_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= altpll_sdram_pll_slave_in_a_write_cycle;
  wait_for_altpll_sdram_pll_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_altpll_sdram_pll_slave <= internal_cpu_data_master_granted_altpll_sdram_pll_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_altpll_sdram_pll_slave <= internal_cpu_data_master_qualified_request_altpll_sdram_pll_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_altpll_sdram_pll_slave <= internal_cpu_data_master_requests_altpll_sdram_pll_slave;
--synthesis translate_off
    --altpll_sdram/pll_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

library std;
use std.textio.all;

entity cpu_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_debugaccess : IN STD_LOGIC;
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_write : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
              );
end entity cpu_jtag_debug_module_arbitrator;


architecture europa of cpu_jtag_debug_module_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_jtag_debug_module_allgrants :  STD_LOGIC;
                signal cpu_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal cpu_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal cpu_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal cpu_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal cpu_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal cpu_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal cpu_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal cpu_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_cpu_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_data_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module :  STD_LOGIC;
                signal shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_cpu_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT cpu_jtag_debug_module_end_xfer;
    end if;

  end process;

  cpu_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_data_master_qualified_request_cpu_jtag_debug_module OR internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module));
  --assign cpu_jtag_debug_module_readdata_from_sa = cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_jtag_debug_module_readdata_from_sa <= cpu_jtag_debug_module_readdata;
  internal_cpu_data_master_requests_cpu_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("100000000000000100000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  cpu_jtag_debug_module_arb_share_set_values <= std_logic_vector'("01");
  --cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  cpu_jtag_debug_module_non_bursting_master_requests <= ((internal_cpu_data_master_requests_cpu_jtag_debug_module OR internal_cpu_instruction_master_requests_cpu_jtag_debug_module) OR internal_cpu_data_master_requests_cpu_jtag_debug_module) OR internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  cpu_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  cpu_jtag_debug_module_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (cpu_jtag_debug_module_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(cpu_jtag_debug_module_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (cpu_jtag_debug_module_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  cpu_jtag_debug_module_allgrants <= (((or_reduce(cpu_jtag_debug_module_grant_vector)) OR (or_reduce(cpu_jtag_debug_module_grant_vector))) OR (or_reduce(cpu_jtag_debug_module_grant_vector))) OR (or_reduce(cpu_jtag_debug_module_grant_vector));
  --cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  cpu_jtag_debug_module_end_xfer <= NOT ((cpu_jtag_debug_module_waits_for_read OR cpu_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_cpu_jtag_debug_module <= cpu_jtag_debug_module_end_xfer AND (((NOT cpu_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  cpu_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND cpu_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND NOT cpu_jtag_debug_module_non_bursting_master_requests));
  --cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_arb_counter_enable) = '1' then 
        cpu_jtag_debug_module_arb_share_counter <= cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(cpu_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_cpu_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND NOT cpu_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        cpu_jtag_debug_module_slavearbiterlockenable <= or_reduce(cpu_jtag_debug_module_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= cpu_jtag_debug_module_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  cpu_jtag_debug_module_slavearbiterlockenable2 <= or_reduce(cpu_jtag_debug_module_arb_share_counter_next_value);
  --cpu/data_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= cpu_jtag_debug_module_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --cpu/instruction_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= cpu_jtag_debug_module_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= cpu_jtag_debug_module_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master granted cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_instruction_master_saved_grant_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_instruction_master_requests_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module))))));
    end if;

  end process;

  --cpu_instruction_master_continuerequest continued request, which is an e_mux
  cpu_instruction_master_continuerequest <= last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module AND internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  cpu_jtag_debug_module_any_continuerequest <= cpu_instruction_master_continuerequest OR cpu_data_master_continuerequest;
  internal_cpu_data_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_data_master_requests_cpu_jtag_debug_module AND NOT (((((NOT cpu_data_master_waitrequest) AND cpu_data_master_write)) OR cpu_instruction_master_arbiterlock));
  --cpu_jtag_debug_module_writedata mux, which is an e_mux
  cpu_jtag_debug_module_writedata <= cpu_data_master_writedata;
  internal_cpu_instruction_master_requests_cpu_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(26 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("100000000000000100000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --cpu/data_master granted cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_data_master_saved_grant_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_data_master_requests_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module))))));
    end if;

  end process;

  --cpu_data_master_continuerequest continued request, which is an e_mux
  cpu_data_master_continuerequest <= last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module AND internal_cpu_data_master_requests_cpu_jtag_debug_module;
  internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_instruction_master_requests_cpu_jtag_debug_module AND NOT (cpu_data_master_arbiterlock);
  --allow new arb cycle for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_allow_new_arb_cycle <= NOT cpu_data_master_arbiterlock AND NOT cpu_instruction_master_arbiterlock;
  --cpu/instruction_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_master_qreq_vector(0) <= internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  --cpu/instruction_master grant cpu/jtag_debug_module, which is an e_assign
  internal_cpu_instruction_master_granted_cpu_jtag_debug_module <= cpu_jtag_debug_module_grant_vector(0);
  --cpu/instruction_master saved-grant cpu/jtag_debug_module, which is an e_assign
  cpu_instruction_master_saved_grant_cpu_jtag_debug_module <= cpu_jtag_debug_module_arb_winner(0) AND internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu/data_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_master_qreq_vector(1) <= internal_cpu_data_master_qualified_request_cpu_jtag_debug_module;
  --cpu/data_master grant cpu/jtag_debug_module, which is an e_assign
  internal_cpu_data_master_granted_cpu_jtag_debug_module <= cpu_jtag_debug_module_grant_vector(1);
  --cpu/data_master saved-grant cpu/jtag_debug_module, which is an e_assign
  cpu_data_master_saved_grant_cpu_jtag_debug_module <= cpu_jtag_debug_module_arb_winner(1) AND internal_cpu_data_master_requests_cpu_jtag_debug_module;
  --cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  cpu_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((cpu_jtag_debug_module_master_qreq_vector & cpu_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT cpu_jtag_debug_module_master_qreq_vector & NOT cpu_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (cpu_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  cpu_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_allow_new_arb_cycle AND or_reduce(cpu_jtag_debug_module_grant_vector)))) = '1'), cpu_jtag_debug_module_grant_vector, cpu_jtag_debug_module_saved_chosen_master_vector);
  --saved cpu_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        cpu_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(cpu_jtag_debug_module_grant_vector)) = '1'), cpu_jtag_debug_module_grant_vector, cpu_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  cpu_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((cpu_jtag_debug_module_chosen_master_double_vector(1) OR cpu_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((cpu_jtag_debug_module_chosen_master_double_vector(0) OR cpu_jtag_debug_module_chosen_master_double_vector(2)))));
  --cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  cpu_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --cpu/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(cpu_jtag_debug_module_grant_vector)) = '1' then 
        cpu_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_end_xfer) = '1'), cpu_jtag_debug_module_chosen_master_rot_left, cpu_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  cpu_jtag_debug_module_begintransfer <= cpu_jtag_debug_module_begins_xfer;
  --cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  cpu_jtag_debug_module_reset_n <= reset_n;
  --assign cpu_jtag_debug_module_resetrequest_from_sa = cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_jtag_debug_module_resetrequest_from_sa <= cpu_jtag_debug_module_resetrequest;
  cpu_jtag_debug_module_chipselect <= internal_cpu_data_master_granted_cpu_jtag_debug_module OR internal_cpu_instruction_master_granted_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  cpu_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(cpu_jtag_debug_module_begins_xfer) = '1'), cpu_jtag_debug_module_unreg_firsttransfer, cpu_jtag_debug_module_reg_firsttransfer);
  --cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  cpu_jtag_debug_module_unreg_firsttransfer <= NOT ((cpu_jtag_debug_module_slavearbiterlockenable AND cpu_jtag_debug_module_any_continuerequest));
  --cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_begins_xfer) = '1' then 
        cpu_jtag_debug_module_reg_firsttransfer <= cpu_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  cpu_jtag_debug_module_beginbursttransfer_internal <= cpu_jtag_debug_module_begins_xfer;
  --cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  cpu_jtag_debug_module_arbitration_holdoff_internal <= cpu_jtag_debug_module_begins_xfer AND cpu_jtag_debug_module_firsttransfer;
  --cpu_jtag_debug_module_write assignment, which is an e_mux
  cpu_jtag_debug_module_write <= internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_write;
  shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --cpu_jtag_debug_module_address mux, which is an e_mux
  cpu_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
  shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master <= cpu_instruction_master_address_to_slave;
  --d1_cpu_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_cpu_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_cpu_jtag_debug_module_end_xfer <= cpu_jtag_debug_module_end_xfer;
    end if;

  end process;

  --cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  cpu_jtag_debug_module_waits_for_read <= cpu_jtag_debug_module_in_a_read_cycle AND cpu_jtag_debug_module_begins_xfer;
  --cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  cpu_jtag_debug_module_in_a_read_cycle <= ((internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_read)) OR ((internal_cpu_instruction_master_granted_cpu_jtag_debug_module AND cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= cpu_jtag_debug_module_in_a_read_cycle;
  --cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  cpu_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  cpu_jtag_debug_module_in_a_write_cycle <= internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= cpu_jtag_debug_module_in_a_write_cycle;
  wait_for_cpu_jtag_debug_module_counter <= std_logic'('0');
  --cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  cpu_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  cpu_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  cpu_data_master_granted_cpu_jtag_debug_module <= internal_cpu_data_master_granted_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_data_master_qualified_request_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_data_master_requests_cpu_jtag_debug_module <= internal_cpu_data_master_requests_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_cpu_jtag_debug_module <= internal_cpu_instruction_master_granted_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_cpu_jtag_debug_module <= internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
--synthesis translate_off
    --cpu/jtag_debug_module enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line10 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_data_master_granted_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_granted_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line10, now);
          write(write_line10, string'(": "));
          write(write_line10, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line10.all);
          deallocate (write_line10);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line11 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_data_master_saved_grant_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_saved_grant_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line11, now);
          write(write_line11, string'(": "));
          write(write_line11, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line11.all);
          deallocate (write_line11);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity cpu_data_master_arbitrator is 
        port (
              -- inputs:
                 signal I2C_Master_avalon_slave_irq_from_sa : IN STD_LOGIC;
                 signal I2C_Master_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal I2C_Master_avalon_slave_waitrequest_n_from_sa : IN STD_LOGIC;
                 signal TERASIC_SPI_3WIRE_0_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal Teste_SOPC_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal altpll_sdram_pll_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_byteenable_Teste_SOPC_clock_1_in : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_data_master_granted_I2C_Master_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                 signal cpu_data_master_granted_altpll_sdram_pll_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_endcalc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_legselect_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_reset_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_updateflag_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_x_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_y_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_bot_z_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_pio_led_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_data_master_granted_timer_sys_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_I2C_Master_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_altpll_sdram_pll_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_endcalc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_legselect_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_reset_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_updateflag_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_x_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_y_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_z_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_led_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_timer_sys_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_I2C_Master_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_altpll_sdram_pll_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_endcalc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_legselect_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_reset_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_updateflag_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_x_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_y_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_z_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_led_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_timer_sys_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_I2C_Master_avalon_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                 signal cpu_data_master_requests_altpll_sdram_pll_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_endcalc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_legselect_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_reset_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_updateflag_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_x_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_y_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_z_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_pio_led_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_spi_spi_control_port : IN STD_LOGIC;
                 signal cpu_data_master_requests_timer_sys_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_uart_s1 : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_I2C_Master_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal d1_TERASIC_SPI_3WIRE_0_slave_end_xfer : IN STD_LOGIC;
                 signal d1_Teste_SOPC_clock_1_in_end_xfer : IN STD_LOGIC;
                 signal d1_altpll_sdram_pll_slave_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_endcalc_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_legselect_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_reset_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_updateflag_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_wrcoord_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_x_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_y_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_bot_z_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pio_led_s1_end_xfer : IN STD_LOGIC;
                 signal d1_spi_spi_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_timer_sys_s1_end_xfer : IN STD_LOGIC;
                 signal d1_uart_s1_end_xfer : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal pio_bot_endcalc_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_legselect_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_reset_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_updateflag_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_wrcoord_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_x_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_y_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_z_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_led_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal spi_spi_control_port_irq_from_sa : IN STD_LOGIC;
                 signal spi_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal timer_sys_s1_irq_from_sa : IN STD_LOGIC;
                 signal timer_sys_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_s1_irq_from_sa : IN STD_LOGIC;
                 signal uart_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_data_master_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                 signal cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_data_master_arbitrator;


architecture europa of cpu_data_master_arbitrator is
                signal cpu_data_master_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_data_master_run :  STD_LOGIC;
                signal dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal internal_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal internal_cpu_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_cpu_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal internal_cpu_data_master_waitrequest :  STD_LOGIC;
                signal last_dbs_term_and_run :  STD_LOGIC;
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_registered_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal r_3 :  STD_LOGIC;
                signal registered_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_I2C_Master_avalon_slave OR NOT cpu_data_master_requests_I2C_Master_avalon_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_I2C_Master_avalon_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(I2C_Master_avalon_slave_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_I2C_Master_avalon_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(I2C_Master_avalon_slave_waitrequest_n_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave OR registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave) OR NOT cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_Teste_SOPC_clock_1_in OR (((cpu_data_master_write AND NOT(or_reduce(cpu_data_master_byteenable_Teste_SOPC_clock_1_in))) AND internal_cpu_data_master_dbs_address(1)))) OR NOT cpu_data_master_requests_Teste_SOPC_clock_1_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Teste_SOPC_clock_1_in OR NOT cpu_data_master_read)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT Teste_SOPC_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_cpu_data_master_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Teste_SOPC_clock_1_in OR NOT cpu_data_master_write)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT Teste_SOPC_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_cpu_data_master_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_altpll_sdram_pll_slave OR NOT cpu_data_master_requests_altpll_sdram_pll_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_altpll_sdram_pll_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_altpll_sdram_pll_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_requests_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_granted_cpu_jtag_debug_module OR NOT cpu_data_master_qualified_request_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_data_master_run <= ((r_0 AND r_1) AND r_2) AND r_3;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((((((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_endcalc_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_endcalc_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_bot_legselect_s1 OR NOT cpu_data_master_requests_pio_bot_legselect_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_legselect_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_legselect_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_bot_reset_s1 OR NOT cpu_data_master_requests_pio_bot_reset_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_reset_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_reset_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_bot_updateflag_s1 OR NOT cpu_data_master_requests_pio_bot_updateflag_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_updateflag_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_updateflag_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_bot_wrcoord_s1 OR NOT cpu_data_master_requests_pio_bot_wrcoord_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_wrcoord_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_wrcoord_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_bot_x_s1 OR NOT cpu_data_master_requests_pio_bot_x_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_x_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_x_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_bot_y_s1 OR NOT cpu_data_master_requests_pio_bot_y_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_y_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_y_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_bot_z_s1 OR NOT cpu_data_master_requests_pio_bot_z_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_z_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_bot_z_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_pio_led_s1 OR NOT cpu_data_master_requests_pio_led_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_led_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_pio_led_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))));
  --r_3 master_run cascaded wait assignment, which is an e_assign
  r_3 <= Vector_To_Std_Logic((((((((((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_spi_spi_control_port OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_spi_spi_control_port OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_timer_sys_s1 OR NOT cpu_data_master_requests_timer_sys_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_timer_sys_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_timer_sys_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_uart_s1 OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_uart_s1 OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_data_master_address_to_slave <= cpu_data_master_address(26 DOWNTO 0);
  --unpredictable registered wait state incoming data, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      registered_cpu_data_master_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      registered_cpu_data_master_readdata <= p1_registered_cpu_data_master_readdata;
    end if;

  end process;

  --registered readdata mux, which is an e_mux
  p1_registered_cpu_data_master_readdata <= ((((A_REP(NOT cpu_data_master_requests_I2C_Master_avalon_slave, 32) OR (std_logic_vector'("000000000000000000000000") & (I2C_Master_avalon_slave_readdata_from_sa)))) AND ((A_REP(NOT cpu_data_master_requests_Teste_SOPC_clock_1_in, 32) OR Std_Logic_Vector'(Teste_SOPC_clock_1_in_readdata_from_sa(15 DOWNTO 0) & dbs_16_reg_segment_0)))) AND ((A_REP(NOT cpu_data_master_requests_altpll_sdram_pll_slave, 32) OR altpll_sdram_pll_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR jtag_uart_avalon_jtag_slave_readdata_from_sa));
  --cpu/data_master readdata mux, which is an e_mux
  cpu_data_master_readdata <= ((((((((((((((((((A_REP(NOT cpu_data_master_requests_I2C_Master_avalon_slave, 32) OR registered_cpu_data_master_readdata)) AND ((A_REP(NOT cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave, 32) OR (std_logic_vector'("000000000000000000000000") & (TERASIC_SPI_3WIRE_0_slave_readdata_from_sa))))) AND ((A_REP(NOT cpu_data_master_requests_Teste_SOPC_clock_1_in, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_altpll_sdram_pll_slave, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_cpu_jtag_debug_module, 32) OR cpu_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_endcalc_s1, 32) OR pio_bot_endcalc_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_legselect_s1, 32) OR pio_bot_legselect_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_reset_s1, 32) OR pio_bot_reset_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_updateflag_s1, 32) OR pio_bot_updateflag_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_wrcoord_s1, 32) OR pio_bot_wrcoord_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_x_s1, 32) OR pio_bot_x_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_y_s1, 32) OR pio_bot_y_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_bot_z_s1, 32) OR pio_bot_z_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_pio_led_s1, 32) OR pio_led_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_spi_spi_control_port, 32) OR (std_logic_vector'("0000000000000000") & (spi_spi_control_port_readdata_from_sa))))) AND ((A_REP(NOT cpu_data_master_requests_timer_sys_s1, 32) OR (std_logic_vector'("0000000000000000") & (timer_sys_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_data_master_requests_uart_s1, 32) OR uart_s1_readdata_from_sa));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      internal_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((cpu_data_master_read OR cpu_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_run AND internal_cpu_data_master_waitrequest))))))));
    end if;

  end process;

  --irq assign, which is an e_assign
  cpu_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(uart_s1_irq_from_sa) & A_ToStdLogicVector(I2C_Master_avalon_slave_irq_from_sa) & A_ToStdLogicVector(timer_sys_s1_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(spi_spi_control_port_irq_from_sa) & A_ToStdLogicVector(jtag_uart_avalon_jtag_slave_irq_from_sa));
  --no_byte_enables_and_last_term, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_data_master_no_byte_enables_and_last_term <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_cpu_data_master_no_byte_enables_and_last_term <= last_dbs_term_and_run;
    end if;

  end process;

  --compute the last dbs term, which is an e_mux
  last_dbs_term_and_run <= (to_std_logic(((internal_cpu_data_master_dbs_address = std_logic_vector'("10")))) AND cpu_data_master_write) AND NOT(or_reduce(cpu_data_master_byteenable_Teste_SOPC_clock_1_in));
  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((((NOT internal_cpu_data_master_no_byte_enables_and_last_term) AND cpu_data_master_requests_Teste_SOPC_clock_1_in) AND cpu_data_master_write) AND NOT(or_reduce(cpu_data_master_byteenable_Teste_SOPC_clock_1_in))))))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_data_master_granted_Teste_SOPC_clock_1_in AND cpu_data_master_read)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT Teste_SOPC_clock_1_in_waitrequest_from_sa)))))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_data_master_granted_Teste_SOPC_clock_1_in AND cpu_data_master_write)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT Teste_SOPC_clock_1_in_waitrequest_from_sa)))))));
  --input to dbs-16 stored 0, which is an e_mux
  p1_dbs_16_reg_segment_0 <= Teste_SOPC_clock_1_in_readdata_from_sa;
  --dbs register for dbs-16 segment 0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_16_reg_segment_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_cpu_data_master_dbs_address(1))))) = std_logic_vector'("00000000000000000000000000000000")))))) = '1' then 
        dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
      end if;
    end if;

  end process;

  --mux write dbs 1, which is an e_mux
  cpu_data_master_dbs_write_16 <= A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_dbs_address(1))) = '1'), cpu_data_master_writedata(31 DOWNTO 16), cpu_data_master_writedata(15 DOWNTO 0));
  --dbs count increment, which is an e_mux
  cpu_data_master_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((cpu_data_master_requests_Teste_SOPC_clock_1_in)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_cpu_data_master_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_cpu_data_master_dbs_address)) + (std_logic_vector'("0") & (cpu_data_master_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable AND (NOT ((cpu_data_master_requests_Teste_SOPC_clock_1_in AND NOT internal_cpu_data_master_waitrequest)));
  --dbs counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_data_master_dbs_address <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_count_enable) = '1' then 
        internal_cpu_data_master_dbs_address <= next_dbs_address;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  cpu_data_master_address_to_slave <= internal_cpu_data_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_data_master_dbs_address <= internal_cpu_data_master_dbs_address;
  --vhdl renameroo for output signals
  cpu_data_master_no_byte_enables_and_last_term <= internal_cpu_data_master_no_byte_enables_and_last_term;
  --vhdl renameroo for output signals
  cpu_data_master_waitrequest <= internal_cpu_data_master_waitrequest;

end europa;



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

library std;
use std.textio.all;

entity cpu_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal Teste_SOPC_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal cpu_instruction_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_granted_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                 signal cpu_instruction_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_Teste_SOPC_clock_0_in_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_instruction_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_instruction_master_arbitrator;


architecture europa of cpu_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal cpu_instruction_master_address_last_time :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_instruction_master_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_instruction_master_read_last_time :  STD_LOGIC;
                signal cpu_instruction_master_run :  STD_LOGIC;
                signal dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal internal_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal internal_cpu_instruction_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in OR NOT cpu_instruction_master_read)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT Teste_SOPC_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_cpu_instruction_master_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_instruction_master_requests_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_granted_cpu_jtag_debug_module OR NOT cpu_instruction_master_qualified_request_cpu_jtag_debug_module)))))));
  --cascaded wait assignment, which is an e_assign
  cpu_instruction_master_run <= r_0 AND r_1;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_cpu_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_read)))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_instruction_master_address_to_slave <= cpu_instruction_master_address(26 DOWNTO 0);
  --input to dbs-16 stored 0, which is an e_mux
  p1_dbs_16_reg_segment_0 <= Teste_SOPC_clock_0_in_readdata_from_sa;
  --dbs register for dbs-16 segment 0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_16_reg_segment_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_cpu_instruction_master_dbs_address(1))))) = std_logic_vector'("00000000000000000000000000000000")))))) = '1' then 
        dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
      end if;
    end if;

  end process;

  --cpu/instruction_master readdata mux, which is an e_mux
  cpu_instruction_master_readdata <= ((A_REP(NOT cpu_instruction_master_requests_Teste_SOPC_clock_0_in, 32) OR Std_Logic_Vector'(Teste_SOPC_clock_0_in_readdata_from_sa(15 DOWNTO 0) & dbs_16_reg_segment_0))) AND ((A_REP(NOT cpu_instruction_master_requests_cpu_jtag_debug_module, 32) OR cpu_jtag_debug_module_readdata_from_sa));
  --actual waitrequest port, which is an e_assign
  internal_cpu_instruction_master_waitrequest <= NOT cpu_instruction_master_run;
  --dbs count increment, which is an e_mux
  cpu_instruction_master_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((cpu_instruction_master_requests_Teste_SOPC_clock_0_in)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_cpu_instruction_master_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_cpu_instruction_master_dbs_address)) + (std_logic_vector'("0") & (cpu_instruction_master_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable;
  --dbs counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_instruction_master_dbs_address <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_count_enable) = '1' then 
        internal_cpu_instruction_master_dbs_address <= next_dbs_address;
      end if;
    end if;

  end process;

  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic(((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((cpu_instruction_master_granted_Teste_SOPC_clock_0_in AND cpu_instruction_master_read)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT Teste_SOPC_clock_0_in_waitrequest_from_sa)))));
  --vhdl renameroo for output signals
  cpu_instruction_master_address_to_slave <= internal_cpu_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_instruction_master_dbs_address <= internal_cpu_instruction_master_dbs_address;
  --vhdl renameroo for output signals
  cpu_instruction_master_waitrequest <= internal_cpu_instruction_master_waitrequest;
--synthesis translate_off
    --cpu_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_instruction_master_address_last_time <= std_logic_vector'("000000000000000000000000000");
      elsif clk'event and clk = '1' then
        cpu_instruction_master_address_last_time <= cpu_instruction_master_address;
      end if;

    end process;

    --cpu/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_cpu_instruction_master_waitrequest AND (cpu_instruction_master_read);
      end if;

    end process;

    --cpu_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line12 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_instruction_master_address /= cpu_instruction_master_address_last_time))))) = '1' then 
          write(write_line12, now);
          write(write_line12, string'(": "));
          write(write_line12, string'("cpu_instruction_master_address did not heed wait!!!"));
          write(output, write_line12.all);
          deallocate (write_line12);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        cpu_instruction_master_read_last_time <= cpu_instruction_master_read;
      end if;

    end process;

    --cpu_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line13 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_instruction_master_read) /= std_logic'(cpu_instruction_master_read_last_time)))))) = '1' then 
          write(write_line13, now);
          write(write_line13, string'(": "));
          write(write_line13, string'("cpu_instruction_master_read did not heed wait!!!"));
          write(output, write_line13.all);
          deallocate (write_line13);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity jtag_uart_avalon_jtag_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal d1_jtag_uart_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_address : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity jtag_uart_avalon_jtag_slave_arbitrator;


architecture europa of jtag_uart_avalon_jtag_slave_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_allgrants :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_any_continuerequest :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_counter_enable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_begins_xfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_grant_vector :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_in_a_read_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_in_a_write_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_master_qreq_vector :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_non_bursting_master_requests :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_reg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_slavearbiterlockenable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_unreg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waits_for_read :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_jtag_uart_avalon_jtag_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT jtag_uart_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  jtag_uart_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave);
  --assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readdata_from_sa <= jtag_uart_avalon_jtag_slave_readdata;
  internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("100000000000001000110000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_avalon_jtag_slave_waitrequest;
  --jtag_uart_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_avalon_jtag_slave_arb_share_set_values <= std_logic_vector'("01");
  --jtag_uart_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --jtag_uart_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(jtag_uart_avalon_jtag_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (jtag_uart_avalon_jtag_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(jtag_uart_avalon_jtag_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (jtag_uart_avalon_jtag_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --jtag_uart_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  jtag_uart_avalon_jtag_slave_allgrants <= jtag_uart_avalon_jtag_slave_grant_vector;
  --jtag_uart_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_end_xfer <= NOT ((jtag_uart_avalon_jtag_slave_waits_for_read OR jtag_uart_avalon_jtag_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave <= jtag_uart_avalon_jtag_slave_end_xfer AND (((NOT jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --jtag_uart_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  jtag_uart_avalon_jtag_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND jtag_uart_avalon_jtag_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND NOT jtag_uart_avalon_jtag_slave_non_bursting_master_requests));
  --jtag_uart_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_avalon_jtag_slave_arb_counter_enable) = '1' then 
        jtag_uart_avalon_jtag_slave_arb_share_counter <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((jtag_uart_avalon_jtag_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave)) OR ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND NOT jtag_uart_avalon_jtag_slave_non_bursting_master_requests)))) = '1' then 
        jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= or_reduce(jtag_uart_avalon_jtag_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 <= or_reduce(jtag_uart_avalon_jtag_slave_arb_share_counter_next_value);
  --cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --jtag_uart_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --cpu/data_master saved-grant jtag_uart/avalon_jtag_slave, which is an e_assign
  cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart/avalon_jtag_slave, which is an e_assign
  jtag_uart_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_avalon_jtag_slave_chipselect <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  --jtag_uart_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  jtag_uart_avalon_jtag_slave_firsttransfer <= A_WE_StdLogic((std_logic'(jtag_uart_avalon_jtag_slave_begins_xfer) = '1'), jtag_uart_avalon_jtag_slave_unreg_firsttransfer, jtag_uart_avalon_jtag_slave_reg_firsttransfer);
  --jtag_uart_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  jtag_uart_avalon_jtag_slave_unreg_firsttransfer <= NOT ((jtag_uart_avalon_jtag_slave_slavearbiterlockenable AND jtag_uart_avalon_jtag_slave_any_continuerequest));
  --jtag_uart_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_avalon_jtag_slave_begins_xfer) = '1' then 
        jtag_uart_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_avalon_jtag_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  jtag_uart_avalon_jtag_slave_beginbursttransfer_internal <= jtag_uart_avalon_jtag_slave_begins_xfer;
  --~jtag_uart_avalon_jtag_slave_read_n assignment, which is an e_mux
  jtag_uart_avalon_jtag_slave_read_n <= NOT ((internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_read));
  --~jtag_uart_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_avalon_jtag_slave_write_n <= NOT ((internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_write));
  shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --jtag_uart_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_jtag_uart_avalon_jtag_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_jtag_uart_avalon_jtag_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_jtag_uart_avalon_jtag_slave_end_xfer <= jtag_uart_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  jtag_uart_avalon_jtag_slave_waits_for_read <= jtag_uart_avalon_jtag_slave_in_a_read_cycle AND internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_in_a_read_cycle <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_avalon_jtag_slave_waits_for_write <= jtag_uart_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_in_a_write_cycle <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_irq_from_sa <= jtag_uart_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
--synthesis translate_off
    --jtag_uart/avalon_jtag_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_endcalc_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal pio_bot_endcalc_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_endcalc_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_endcalc_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_endcalc_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_endcalc_s1_reset_n : OUT STD_LOGIC
              );
end entity pio_bot_endcalc_s1_arbitrator;


architecture europa of pio_bot_endcalc_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal pio_bot_endcalc_s1_allgrants :  STD_LOGIC;
                signal pio_bot_endcalc_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_endcalc_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_endcalc_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_endcalc_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_endcalc_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_endcalc_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_endcalc_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_endcalc_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_endcalc_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_endcalc_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_endcalc_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_endcalc_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_endcalc_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_endcalc_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_endcalc_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_endcalc_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_endcalc_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_endcalc_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_endcalc_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_endcalc_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_endcalc_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_endcalc_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_endcalc_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_endcalc_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_endcalc_s1_end_xfer;
    end if;

  end process;

  pio_bot_endcalc_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_endcalc_s1);
  --assign pio_bot_endcalc_s1_readdata_from_sa = pio_bot_endcalc_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_endcalc_s1_readdata_from_sa <= pio_bot_endcalc_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_endcalc_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000100110000")))) AND ((cpu_data_master_read OR cpu_data_master_write)))) AND cpu_data_master_read;
  --pio_bot_endcalc_s1_arb_share_counter set values, which is an e_mux
  pio_bot_endcalc_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_endcalc_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_endcalc_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_endcalc_s1;
  --pio_bot_endcalc_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_endcalc_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_endcalc_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_endcalc_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_endcalc_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_endcalc_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_endcalc_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_endcalc_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_endcalc_s1_allgrants all slave grants, which is an e_mux
  pio_bot_endcalc_s1_allgrants <= pio_bot_endcalc_s1_grant_vector;
  --pio_bot_endcalc_s1_end_xfer assignment, which is an e_assign
  pio_bot_endcalc_s1_end_xfer <= NOT ((pio_bot_endcalc_s1_waits_for_read OR pio_bot_endcalc_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_endcalc_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_endcalc_s1 <= pio_bot_endcalc_s1_end_xfer AND (((NOT pio_bot_endcalc_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_endcalc_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_endcalc_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_endcalc_s1 AND pio_bot_endcalc_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_endcalc_s1 AND NOT pio_bot_endcalc_s1_non_bursting_master_requests));
  --pio_bot_endcalc_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_endcalc_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_endcalc_s1_arb_counter_enable) = '1' then 
        pio_bot_endcalc_s1_arb_share_counter <= pio_bot_endcalc_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_endcalc_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_endcalc_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_endcalc_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_endcalc_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_endcalc_s1 AND NOT pio_bot_endcalc_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_endcalc_s1_slavearbiterlockenable <= or_reduce(pio_bot_endcalc_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_endcalc/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_endcalc_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_endcalc_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_endcalc_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_endcalc_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_endcalc/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_endcalc_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_endcalc_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_endcalc_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_endcalc_s1 <= internal_cpu_data_master_requests_pio_bot_endcalc_s1;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_endcalc_s1 <= internal_cpu_data_master_qualified_request_pio_bot_endcalc_s1;
  --cpu/data_master saved-grant pio_bot_endcalc/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_endcalc_s1 <= internal_cpu_data_master_requests_pio_bot_endcalc_s1;
  --allow new arb cycle for pio_bot_endcalc/s1, which is an e_assign
  pio_bot_endcalc_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_endcalc_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_endcalc_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_endcalc_s1_reset_n assignment, which is an e_assign
  pio_bot_endcalc_s1_reset_n <= reset_n;
  --pio_bot_endcalc_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_endcalc_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_endcalc_s1_begins_xfer) = '1'), pio_bot_endcalc_s1_unreg_firsttransfer, pio_bot_endcalc_s1_reg_firsttransfer);
  --pio_bot_endcalc_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_endcalc_s1_unreg_firsttransfer <= NOT ((pio_bot_endcalc_s1_slavearbiterlockenable AND pio_bot_endcalc_s1_any_continuerequest));
  --pio_bot_endcalc_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_endcalc_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_endcalc_s1_begins_xfer) = '1' then 
        pio_bot_endcalc_s1_reg_firsttransfer <= pio_bot_endcalc_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_endcalc_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_endcalc_s1_beginbursttransfer_internal <= pio_bot_endcalc_s1_begins_xfer;
  shifted_address_to_pio_bot_endcalc_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_endcalc_s1_address mux, which is an e_mux
  pio_bot_endcalc_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_endcalc_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_endcalc_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_endcalc_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_endcalc_s1_end_xfer <= pio_bot_endcalc_s1_end_xfer;
    end if;

  end process;

  --pio_bot_endcalc_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_endcalc_s1_waits_for_read <= pio_bot_endcalc_s1_in_a_read_cycle AND pio_bot_endcalc_s1_begins_xfer;
  --pio_bot_endcalc_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_endcalc_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_endcalc_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_endcalc_s1_in_a_read_cycle;
  --pio_bot_endcalc_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_endcalc_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_endcalc_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_endcalc_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_endcalc_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_endcalc_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_endcalc_s1_in_a_write_cycle;
  wait_for_pio_bot_endcalc_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_endcalc_s1 <= internal_cpu_data_master_granted_pio_bot_endcalc_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_endcalc_s1 <= internal_cpu_data_master_qualified_request_pio_bot_endcalc_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_endcalc_s1 <= internal_cpu_data_master_requests_pio_bot_endcalc_s1;
--synthesis translate_off
    --pio_bot_endcalc/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_legselect_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_legselect_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_legselect_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_legselect_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_legselect_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_legselect_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_legselect_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_legselect_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_legselect_s1_chipselect : OUT STD_LOGIC;
                 signal pio_bot_legselect_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_legselect_s1_reset_n : OUT STD_LOGIC;
                 signal pio_bot_legselect_s1_write_n : OUT STD_LOGIC;
                 signal pio_bot_legselect_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_bot_legselect_s1_arbitrator;


architecture europa of pio_bot_legselect_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_legselect_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_legselect_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_legselect_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_legselect_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_legselect_s1 :  STD_LOGIC;
                signal pio_bot_legselect_s1_allgrants :  STD_LOGIC;
                signal pio_bot_legselect_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_legselect_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_legselect_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_legselect_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_legselect_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_legselect_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_legselect_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_legselect_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_legselect_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_legselect_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_legselect_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_legselect_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_legselect_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_legselect_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_legselect_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_legselect_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_legselect_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_legselect_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_legselect_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_legselect_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_legselect_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_legselect_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_legselect_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_legselect_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_legselect_s1_end_xfer;
    end if;

  end process;

  pio_bot_legselect_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_legselect_s1);
  --assign pio_bot_legselect_s1_readdata_from_sa = pio_bot_legselect_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_legselect_s1_readdata_from_sa <= pio_bot_legselect_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_legselect_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000101010000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_bot_legselect_s1_arb_share_counter set values, which is an e_mux
  pio_bot_legselect_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_legselect_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_legselect_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_legselect_s1;
  --pio_bot_legselect_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_legselect_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_legselect_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_legselect_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_legselect_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_legselect_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_legselect_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_legselect_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_legselect_s1_allgrants all slave grants, which is an e_mux
  pio_bot_legselect_s1_allgrants <= pio_bot_legselect_s1_grant_vector;
  --pio_bot_legselect_s1_end_xfer assignment, which is an e_assign
  pio_bot_legselect_s1_end_xfer <= NOT ((pio_bot_legselect_s1_waits_for_read OR pio_bot_legselect_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_legselect_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_legselect_s1 <= pio_bot_legselect_s1_end_xfer AND (((NOT pio_bot_legselect_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_legselect_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_legselect_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_legselect_s1 AND pio_bot_legselect_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_legselect_s1 AND NOT pio_bot_legselect_s1_non_bursting_master_requests));
  --pio_bot_legselect_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_legselect_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_legselect_s1_arb_counter_enable) = '1' then 
        pio_bot_legselect_s1_arb_share_counter <= pio_bot_legselect_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_legselect_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_legselect_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_legselect_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_legselect_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_legselect_s1 AND NOT pio_bot_legselect_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_legselect_s1_slavearbiterlockenable <= or_reduce(pio_bot_legselect_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_legselect/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_legselect_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_legselect_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_legselect_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_legselect_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_legselect/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_legselect_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_legselect_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_legselect_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_legselect_s1 <= internal_cpu_data_master_requests_pio_bot_legselect_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_bot_legselect_s1_writedata mux, which is an e_mux
  pio_bot_legselect_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_legselect_s1 <= internal_cpu_data_master_qualified_request_pio_bot_legselect_s1;
  --cpu/data_master saved-grant pio_bot_legselect/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_legselect_s1 <= internal_cpu_data_master_requests_pio_bot_legselect_s1;
  --allow new arb cycle for pio_bot_legselect/s1, which is an e_assign
  pio_bot_legselect_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_legselect_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_legselect_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_legselect_s1_reset_n assignment, which is an e_assign
  pio_bot_legselect_s1_reset_n <= reset_n;
  pio_bot_legselect_s1_chipselect <= internal_cpu_data_master_granted_pio_bot_legselect_s1;
  --pio_bot_legselect_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_legselect_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_legselect_s1_begins_xfer) = '1'), pio_bot_legselect_s1_unreg_firsttransfer, pio_bot_legselect_s1_reg_firsttransfer);
  --pio_bot_legselect_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_legselect_s1_unreg_firsttransfer <= NOT ((pio_bot_legselect_s1_slavearbiterlockenable AND pio_bot_legselect_s1_any_continuerequest));
  --pio_bot_legselect_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_legselect_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_legselect_s1_begins_xfer) = '1' then 
        pio_bot_legselect_s1_reg_firsttransfer <= pio_bot_legselect_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_legselect_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_legselect_s1_beginbursttransfer_internal <= pio_bot_legselect_s1_begins_xfer;
  --~pio_bot_legselect_s1_write_n assignment, which is an e_mux
  pio_bot_legselect_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_bot_legselect_s1 AND cpu_data_master_write));
  shifted_address_to_pio_bot_legselect_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_legselect_s1_address mux, which is an e_mux
  pio_bot_legselect_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_legselect_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_legselect_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_legselect_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_legselect_s1_end_xfer <= pio_bot_legselect_s1_end_xfer;
    end if;

  end process;

  --pio_bot_legselect_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_legselect_s1_waits_for_read <= pio_bot_legselect_s1_in_a_read_cycle AND pio_bot_legselect_s1_begins_xfer;
  --pio_bot_legselect_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_legselect_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_legselect_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_legselect_s1_in_a_read_cycle;
  --pio_bot_legselect_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_legselect_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_legselect_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_legselect_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_legselect_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_legselect_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_legselect_s1_in_a_write_cycle;
  wait_for_pio_bot_legselect_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_legselect_s1 <= internal_cpu_data_master_granted_pio_bot_legselect_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_legselect_s1 <= internal_cpu_data_master_qualified_request_pio_bot_legselect_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_legselect_s1 <= internal_cpu_data_master_requests_pio_bot_legselect_s1;
--synthesis translate_off
    --pio_bot_legselect/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_reset_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_reset_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_reset_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_reset_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_reset_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_reset_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_reset_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_reset_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_reset_s1_chipselect : OUT STD_LOGIC;
                 signal pio_bot_reset_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_reset_s1_reset_n : OUT STD_LOGIC;
                 signal pio_bot_reset_s1_write_n : OUT STD_LOGIC;
                 signal pio_bot_reset_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_bot_reset_s1_arbitrator;


architecture europa of pio_bot_reset_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_reset_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_reset_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_reset_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_reset_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_reset_s1 :  STD_LOGIC;
                signal pio_bot_reset_s1_allgrants :  STD_LOGIC;
                signal pio_bot_reset_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_reset_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_reset_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_reset_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_reset_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_reset_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_reset_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_reset_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_reset_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_reset_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_reset_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_reset_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_reset_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_reset_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_reset_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_reset_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_reset_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_reset_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_reset_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_reset_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_reset_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_reset_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_reset_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_reset_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_reset_s1_end_xfer;
    end if;

  end process;

  pio_bot_reset_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_reset_s1);
  --assign pio_bot_reset_s1_readdata_from_sa = pio_bot_reset_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_reset_s1_readdata_from_sa <= pio_bot_reset_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_reset_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000101000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_bot_reset_s1_arb_share_counter set values, which is an e_mux
  pio_bot_reset_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_reset_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_reset_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_reset_s1;
  --pio_bot_reset_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_reset_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_reset_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_reset_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_reset_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_reset_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_reset_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_reset_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_reset_s1_allgrants all slave grants, which is an e_mux
  pio_bot_reset_s1_allgrants <= pio_bot_reset_s1_grant_vector;
  --pio_bot_reset_s1_end_xfer assignment, which is an e_assign
  pio_bot_reset_s1_end_xfer <= NOT ((pio_bot_reset_s1_waits_for_read OR pio_bot_reset_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_reset_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_reset_s1 <= pio_bot_reset_s1_end_xfer AND (((NOT pio_bot_reset_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_reset_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_reset_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_reset_s1 AND pio_bot_reset_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_reset_s1 AND NOT pio_bot_reset_s1_non_bursting_master_requests));
  --pio_bot_reset_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_reset_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_reset_s1_arb_counter_enable) = '1' then 
        pio_bot_reset_s1_arb_share_counter <= pio_bot_reset_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_reset_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_reset_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_reset_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_reset_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_reset_s1 AND NOT pio_bot_reset_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_reset_s1_slavearbiterlockenable <= or_reduce(pio_bot_reset_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_reset/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_reset_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_reset_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_reset_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_reset_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_reset/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_reset_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_reset_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_reset_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_reset_s1 <= internal_cpu_data_master_requests_pio_bot_reset_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_bot_reset_s1_writedata mux, which is an e_mux
  pio_bot_reset_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_reset_s1 <= internal_cpu_data_master_qualified_request_pio_bot_reset_s1;
  --cpu/data_master saved-grant pio_bot_reset/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_reset_s1 <= internal_cpu_data_master_requests_pio_bot_reset_s1;
  --allow new arb cycle for pio_bot_reset/s1, which is an e_assign
  pio_bot_reset_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_reset_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_reset_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_reset_s1_reset_n assignment, which is an e_assign
  pio_bot_reset_s1_reset_n <= reset_n;
  pio_bot_reset_s1_chipselect <= internal_cpu_data_master_granted_pio_bot_reset_s1;
  --pio_bot_reset_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_reset_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_reset_s1_begins_xfer) = '1'), pio_bot_reset_s1_unreg_firsttransfer, pio_bot_reset_s1_reg_firsttransfer);
  --pio_bot_reset_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_reset_s1_unreg_firsttransfer <= NOT ((pio_bot_reset_s1_slavearbiterlockenable AND pio_bot_reset_s1_any_continuerequest));
  --pio_bot_reset_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_reset_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_reset_s1_begins_xfer) = '1' then 
        pio_bot_reset_s1_reg_firsttransfer <= pio_bot_reset_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_reset_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_reset_s1_beginbursttransfer_internal <= pio_bot_reset_s1_begins_xfer;
  --~pio_bot_reset_s1_write_n assignment, which is an e_mux
  pio_bot_reset_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_bot_reset_s1 AND cpu_data_master_write));
  shifted_address_to_pio_bot_reset_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_reset_s1_address mux, which is an e_mux
  pio_bot_reset_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_reset_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_reset_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_reset_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_reset_s1_end_xfer <= pio_bot_reset_s1_end_xfer;
    end if;

  end process;

  --pio_bot_reset_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_reset_s1_waits_for_read <= pio_bot_reset_s1_in_a_read_cycle AND pio_bot_reset_s1_begins_xfer;
  --pio_bot_reset_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_reset_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_reset_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_reset_s1_in_a_read_cycle;
  --pio_bot_reset_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_reset_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_reset_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_reset_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_reset_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_reset_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_reset_s1_in_a_write_cycle;
  wait_for_pio_bot_reset_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_reset_s1 <= internal_cpu_data_master_granted_pio_bot_reset_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_reset_s1 <= internal_cpu_data_master_qualified_request_pio_bot_reset_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_reset_s1 <= internal_cpu_data_master_requests_pio_bot_reset_s1;
--synthesis translate_off
    --pio_bot_reset/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_updateflag_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_updateflag_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_updateflag_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_updateflag_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_updateflag_s1_chipselect : OUT STD_LOGIC;
                 signal pio_bot_updateflag_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_updateflag_s1_reset_n : OUT STD_LOGIC;
                 signal pio_bot_updateflag_s1_write_n : OUT STD_LOGIC;
                 signal pio_bot_updateflag_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_bot_updateflag_s1_arbitrator;


architecture europa of pio_bot_updateflag_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal pio_bot_updateflag_s1_allgrants :  STD_LOGIC;
                signal pio_bot_updateflag_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_updateflag_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_updateflag_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_updateflag_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_updateflag_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_updateflag_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_updateflag_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_updateflag_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_updateflag_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_updateflag_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_updateflag_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_updateflag_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_updateflag_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_updateflag_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_updateflag_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_updateflag_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_updateflag_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_updateflag_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_updateflag_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_updateflag_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_updateflag_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_updateflag_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_updateflag_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_updateflag_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_updateflag_s1_end_xfer;
    end if;

  end process;

  pio_bot_updateflag_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_updateflag_s1);
  --assign pio_bot_updateflag_s1_readdata_from_sa = pio_bot_updateflag_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_updateflag_s1_readdata_from_sa <= pio_bot_updateflag_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_updateflag_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000101100000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_bot_updateflag_s1_arb_share_counter set values, which is an e_mux
  pio_bot_updateflag_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_updateflag_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_updateflag_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_updateflag_s1;
  --pio_bot_updateflag_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_updateflag_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_updateflag_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_updateflag_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_updateflag_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_updateflag_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_updateflag_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_updateflag_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_updateflag_s1_allgrants all slave grants, which is an e_mux
  pio_bot_updateflag_s1_allgrants <= pio_bot_updateflag_s1_grant_vector;
  --pio_bot_updateflag_s1_end_xfer assignment, which is an e_assign
  pio_bot_updateflag_s1_end_xfer <= NOT ((pio_bot_updateflag_s1_waits_for_read OR pio_bot_updateflag_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_updateflag_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_updateflag_s1 <= pio_bot_updateflag_s1_end_xfer AND (((NOT pio_bot_updateflag_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_updateflag_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_updateflag_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_updateflag_s1 AND pio_bot_updateflag_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_updateflag_s1 AND NOT pio_bot_updateflag_s1_non_bursting_master_requests));
  --pio_bot_updateflag_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_updateflag_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_updateflag_s1_arb_counter_enable) = '1' then 
        pio_bot_updateflag_s1_arb_share_counter <= pio_bot_updateflag_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_updateflag_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_updateflag_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_updateflag_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_updateflag_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_updateflag_s1 AND NOT pio_bot_updateflag_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_updateflag_s1_slavearbiterlockenable <= or_reduce(pio_bot_updateflag_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_updateflag/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_updateflag_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_updateflag_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_updateflag_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_updateflag_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_updateflag/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_updateflag_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_updateflag_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_updateflag_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_updateflag_s1 <= internal_cpu_data_master_requests_pio_bot_updateflag_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_bot_updateflag_s1_writedata mux, which is an e_mux
  pio_bot_updateflag_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_updateflag_s1 <= internal_cpu_data_master_qualified_request_pio_bot_updateflag_s1;
  --cpu/data_master saved-grant pio_bot_updateflag/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_updateflag_s1 <= internal_cpu_data_master_requests_pio_bot_updateflag_s1;
  --allow new arb cycle for pio_bot_updateflag/s1, which is an e_assign
  pio_bot_updateflag_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_updateflag_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_updateflag_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_updateflag_s1_reset_n assignment, which is an e_assign
  pio_bot_updateflag_s1_reset_n <= reset_n;
  pio_bot_updateflag_s1_chipselect <= internal_cpu_data_master_granted_pio_bot_updateflag_s1;
  --pio_bot_updateflag_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_updateflag_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_updateflag_s1_begins_xfer) = '1'), pio_bot_updateflag_s1_unreg_firsttransfer, pio_bot_updateflag_s1_reg_firsttransfer);
  --pio_bot_updateflag_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_updateflag_s1_unreg_firsttransfer <= NOT ((pio_bot_updateflag_s1_slavearbiterlockenable AND pio_bot_updateflag_s1_any_continuerequest));
  --pio_bot_updateflag_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_updateflag_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_updateflag_s1_begins_xfer) = '1' then 
        pio_bot_updateflag_s1_reg_firsttransfer <= pio_bot_updateflag_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_updateflag_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_updateflag_s1_beginbursttransfer_internal <= pio_bot_updateflag_s1_begins_xfer;
  --~pio_bot_updateflag_s1_write_n assignment, which is an e_mux
  pio_bot_updateflag_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_bot_updateflag_s1 AND cpu_data_master_write));
  shifted_address_to_pio_bot_updateflag_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_updateflag_s1_address mux, which is an e_mux
  pio_bot_updateflag_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_updateflag_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_updateflag_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_updateflag_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_updateflag_s1_end_xfer <= pio_bot_updateflag_s1_end_xfer;
    end if;

  end process;

  --pio_bot_updateflag_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_updateflag_s1_waits_for_read <= pio_bot_updateflag_s1_in_a_read_cycle AND pio_bot_updateflag_s1_begins_xfer;
  --pio_bot_updateflag_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_updateflag_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_updateflag_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_updateflag_s1_in_a_read_cycle;
  --pio_bot_updateflag_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_updateflag_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_updateflag_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_updateflag_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_updateflag_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_updateflag_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_updateflag_s1_in_a_write_cycle;
  wait_for_pio_bot_updateflag_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_updateflag_s1 <= internal_cpu_data_master_granted_pio_bot_updateflag_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_updateflag_s1 <= internal_cpu_data_master_qualified_request_pio_bot_updateflag_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_updateflag_s1 <= internal_cpu_data_master_requests_pio_bot_updateflag_s1;
--synthesis translate_off
    --pio_bot_updateflag/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_wrcoord_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_wrcoord_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_wrcoord_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_wrcoord_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_wrcoord_s1_chipselect : OUT STD_LOGIC;
                 signal pio_bot_wrcoord_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_wrcoord_s1_reset_n : OUT STD_LOGIC;
                 signal pio_bot_wrcoord_s1_write_n : OUT STD_LOGIC;
                 signal pio_bot_wrcoord_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_bot_wrcoord_s1_arbitrator;


architecture europa of pio_bot_wrcoord_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_allgrants :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_wrcoord_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_wrcoord_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_wrcoord_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_wrcoord_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_wrcoord_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_wrcoord_s1_end_xfer;
    end if;

  end process;

  pio_bot_wrcoord_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_wrcoord_s1);
  --assign pio_bot_wrcoord_s1_readdata_from_sa = pio_bot_wrcoord_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_wrcoord_s1_readdata_from_sa <= pio_bot_wrcoord_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_wrcoord_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000101110000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_bot_wrcoord_s1_arb_share_counter set values, which is an e_mux
  pio_bot_wrcoord_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_wrcoord_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_wrcoord_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_wrcoord_s1;
  --pio_bot_wrcoord_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_wrcoord_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_wrcoord_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_wrcoord_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_wrcoord_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_wrcoord_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_wrcoord_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_wrcoord_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_wrcoord_s1_allgrants all slave grants, which is an e_mux
  pio_bot_wrcoord_s1_allgrants <= pio_bot_wrcoord_s1_grant_vector;
  --pio_bot_wrcoord_s1_end_xfer assignment, which is an e_assign
  pio_bot_wrcoord_s1_end_xfer <= NOT ((pio_bot_wrcoord_s1_waits_for_read OR pio_bot_wrcoord_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_wrcoord_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_wrcoord_s1 <= pio_bot_wrcoord_s1_end_xfer AND (((NOT pio_bot_wrcoord_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_wrcoord_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_wrcoord_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_wrcoord_s1 AND pio_bot_wrcoord_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_wrcoord_s1 AND NOT pio_bot_wrcoord_s1_non_bursting_master_requests));
  --pio_bot_wrcoord_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_wrcoord_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_wrcoord_s1_arb_counter_enable) = '1' then 
        pio_bot_wrcoord_s1_arb_share_counter <= pio_bot_wrcoord_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_wrcoord_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_wrcoord_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_wrcoord_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_wrcoord_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_wrcoord_s1 AND NOT pio_bot_wrcoord_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_wrcoord_s1_slavearbiterlockenable <= or_reduce(pio_bot_wrcoord_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_wrcoord/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_wrcoord_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_wrcoord_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_wrcoord_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_wrcoord_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_wrcoord/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_wrcoord_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_wrcoord_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_wrcoord_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_wrcoord_s1 <= internal_cpu_data_master_requests_pio_bot_wrcoord_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_bot_wrcoord_s1_writedata mux, which is an e_mux
  pio_bot_wrcoord_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_wrcoord_s1 <= internal_cpu_data_master_qualified_request_pio_bot_wrcoord_s1;
  --cpu/data_master saved-grant pio_bot_wrcoord/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_wrcoord_s1 <= internal_cpu_data_master_requests_pio_bot_wrcoord_s1;
  --allow new arb cycle for pio_bot_wrcoord/s1, which is an e_assign
  pio_bot_wrcoord_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_wrcoord_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_wrcoord_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_wrcoord_s1_reset_n assignment, which is an e_assign
  pio_bot_wrcoord_s1_reset_n <= reset_n;
  pio_bot_wrcoord_s1_chipselect <= internal_cpu_data_master_granted_pio_bot_wrcoord_s1;
  --pio_bot_wrcoord_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_wrcoord_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_wrcoord_s1_begins_xfer) = '1'), pio_bot_wrcoord_s1_unreg_firsttransfer, pio_bot_wrcoord_s1_reg_firsttransfer);
  --pio_bot_wrcoord_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_wrcoord_s1_unreg_firsttransfer <= NOT ((pio_bot_wrcoord_s1_slavearbiterlockenable AND pio_bot_wrcoord_s1_any_continuerequest));
  --pio_bot_wrcoord_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_wrcoord_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_wrcoord_s1_begins_xfer) = '1' then 
        pio_bot_wrcoord_s1_reg_firsttransfer <= pio_bot_wrcoord_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_wrcoord_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_wrcoord_s1_beginbursttransfer_internal <= pio_bot_wrcoord_s1_begins_xfer;
  --~pio_bot_wrcoord_s1_write_n assignment, which is an e_mux
  pio_bot_wrcoord_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_bot_wrcoord_s1 AND cpu_data_master_write));
  shifted_address_to_pio_bot_wrcoord_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_wrcoord_s1_address mux, which is an e_mux
  pio_bot_wrcoord_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_wrcoord_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_wrcoord_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_wrcoord_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_wrcoord_s1_end_xfer <= pio_bot_wrcoord_s1_end_xfer;
    end if;

  end process;

  --pio_bot_wrcoord_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_wrcoord_s1_waits_for_read <= pio_bot_wrcoord_s1_in_a_read_cycle AND pio_bot_wrcoord_s1_begins_xfer;
  --pio_bot_wrcoord_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_wrcoord_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_wrcoord_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_wrcoord_s1_in_a_read_cycle;
  --pio_bot_wrcoord_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_wrcoord_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_wrcoord_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_wrcoord_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_wrcoord_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_wrcoord_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_wrcoord_s1_in_a_write_cycle;
  wait_for_pio_bot_wrcoord_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_wrcoord_s1 <= internal_cpu_data_master_granted_pio_bot_wrcoord_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_wrcoord_s1 <= internal_cpu_data_master_qualified_request_pio_bot_wrcoord_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_wrcoord_s1 <= internal_cpu_data_master_requests_pio_bot_wrcoord_s1;
--synthesis translate_off
    --pio_bot_wrcoord/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_x_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_x_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_x_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_x_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_x_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_x_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_x_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_x_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_x_s1_chipselect : OUT STD_LOGIC;
                 signal pio_bot_x_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_x_s1_reset_n : OUT STD_LOGIC;
                 signal pio_bot_x_s1_write_n : OUT STD_LOGIC;
                 signal pio_bot_x_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_bot_x_s1_arbitrator;


architecture europa of pio_bot_x_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_x_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_x_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_x_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_x_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_x_s1 :  STD_LOGIC;
                signal pio_bot_x_s1_allgrants :  STD_LOGIC;
                signal pio_bot_x_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_x_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_x_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_x_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_x_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_x_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_x_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_x_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_x_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_x_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_x_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_x_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_x_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_x_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_x_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_x_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_x_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_x_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_x_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_x_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_x_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_x_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_x_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_x_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_x_s1_end_xfer;
    end if;

  end process;

  pio_bot_x_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_x_s1);
  --assign pio_bot_x_s1_readdata_from_sa = pio_bot_x_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_x_s1_readdata_from_sa <= pio_bot_x_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_x_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000100000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_bot_x_s1_arb_share_counter set values, which is an e_mux
  pio_bot_x_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_x_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_x_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_x_s1;
  --pio_bot_x_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_x_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_x_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_x_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_x_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_x_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_x_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_x_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_x_s1_allgrants all slave grants, which is an e_mux
  pio_bot_x_s1_allgrants <= pio_bot_x_s1_grant_vector;
  --pio_bot_x_s1_end_xfer assignment, which is an e_assign
  pio_bot_x_s1_end_xfer <= NOT ((pio_bot_x_s1_waits_for_read OR pio_bot_x_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_x_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_x_s1 <= pio_bot_x_s1_end_xfer AND (((NOT pio_bot_x_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_x_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_x_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_x_s1 AND pio_bot_x_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_x_s1 AND NOT pio_bot_x_s1_non_bursting_master_requests));
  --pio_bot_x_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_x_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_x_s1_arb_counter_enable) = '1' then 
        pio_bot_x_s1_arb_share_counter <= pio_bot_x_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_x_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_x_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_x_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_x_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_x_s1 AND NOT pio_bot_x_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_x_s1_slavearbiterlockenable <= or_reduce(pio_bot_x_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_x/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_x_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_x_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_x_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_x_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_x/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_x_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_x_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_x_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_x_s1 <= internal_cpu_data_master_requests_pio_bot_x_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_bot_x_s1_writedata mux, which is an e_mux
  pio_bot_x_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_x_s1 <= internal_cpu_data_master_qualified_request_pio_bot_x_s1;
  --cpu/data_master saved-grant pio_bot_x/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_x_s1 <= internal_cpu_data_master_requests_pio_bot_x_s1;
  --allow new arb cycle for pio_bot_x/s1, which is an e_assign
  pio_bot_x_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_x_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_x_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_x_s1_reset_n assignment, which is an e_assign
  pio_bot_x_s1_reset_n <= reset_n;
  pio_bot_x_s1_chipselect <= internal_cpu_data_master_granted_pio_bot_x_s1;
  --pio_bot_x_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_x_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_x_s1_begins_xfer) = '1'), pio_bot_x_s1_unreg_firsttransfer, pio_bot_x_s1_reg_firsttransfer);
  --pio_bot_x_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_x_s1_unreg_firsttransfer <= NOT ((pio_bot_x_s1_slavearbiterlockenable AND pio_bot_x_s1_any_continuerequest));
  --pio_bot_x_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_x_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_x_s1_begins_xfer) = '1' then 
        pio_bot_x_s1_reg_firsttransfer <= pio_bot_x_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_x_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_x_s1_beginbursttransfer_internal <= pio_bot_x_s1_begins_xfer;
  --~pio_bot_x_s1_write_n assignment, which is an e_mux
  pio_bot_x_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_bot_x_s1 AND cpu_data_master_write));
  shifted_address_to_pio_bot_x_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_x_s1_address mux, which is an e_mux
  pio_bot_x_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_x_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_x_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_x_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_x_s1_end_xfer <= pio_bot_x_s1_end_xfer;
    end if;

  end process;

  --pio_bot_x_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_x_s1_waits_for_read <= pio_bot_x_s1_in_a_read_cycle AND pio_bot_x_s1_begins_xfer;
  --pio_bot_x_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_x_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_x_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_x_s1_in_a_read_cycle;
  --pio_bot_x_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_x_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_x_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_x_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_x_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_x_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_x_s1_in_a_write_cycle;
  wait_for_pio_bot_x_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_x_s1 <= internal_cpu_data_master_granted_pio_bot_x_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_x_s1 <= internal_cpu_data_master_qualified_request_pio_bot_x_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_x_s1 <= internal_cpu_data_master_requests_pio_bot_x_s1;
--synthesis translate_off
    --pio_bot_x/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_y_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_y_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_y_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_y_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_y_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_y_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_y_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_y_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_y_s1_chipselect : OUT STD_LOGIC;
                 signal pio_bot_y_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_y_s1_reset_n : OUT STD_LOGIC;
                 signal pio_bot_y_s1_write_n : OUT STD_LOGIC;
                 signal pio_bot_y_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_bot_y_s1_arbitrator;


architecture europa of pio_bot_y_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_y_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_y_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_y_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_y_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_y_s1 :  STD_LOGIC;
                signal pio_bot_y_s1_allgrants :  STD_LOGIC;
                signal pio_bot_y_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_y_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_y_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_y_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_y_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_y_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_y_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_y_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_y_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_y_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_y_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_y_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_y_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_y_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_y_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_y_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_y_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_y_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_y_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_y_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_y_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_y_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_y_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_y_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_y_s1_end_xfer;
    end if;

  end process;

  pio_bot_y_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_y_s1);
  --assign pio_bot_y_s1_readdata_from_sa = pio_bot_y_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_y_s1_readdata_from_sa <= pio_bot_y_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_y_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000100010000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_bot_y_s1_arb_share_counter set values, which is an e_mux
  pio_bot_y_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_y_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_y_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_y_s1;
  --pio_bot_y_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_y_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_y_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_y_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_y_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_y_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_y_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_y_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_y_s1_allgrants all slave grants, which is an e_mux
  pio_bot_y_s1_allgrants <= pio_bot_y_s1_grant_vector;
  --pio_bot_y_s1_end_xfer assignment, which is an e_assign
  pio_bot_y_s1_end_xfer <= NOT ((pio_bot_y_s1_waits_for_read OR pio_bot_y_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_y_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_y_s1 <= pio_bot_y_s1_end_xfer AND (((NOT pio_bot_y_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_y_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_y_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_y_s1 AND pio_bot_y_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_y_s1 AND NOT pio_bot_y_s1_non_bursting_master_requests));
  --pio_bot_y_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_y_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_y_s1_arb_counter_enable) = '1' then 
        pio_bot_y_s1_arb_share_counter <= pio_bot_y_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_y_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_y_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_y_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_y_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_y_s1 AND NOT pio_bot_y_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_y_s1_slavearbiterlockenable <= or_reduce(pio_bot_y_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_y/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_y_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_y_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_y_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_y_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_y/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_y_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_y_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_y_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_y_s1 <= internal_cpu_data_master_requests_pio_bot_y_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_bot_y_s1_writedata mux, which is an e_mux
  pio_bot_y_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_y_s1 <= internal_cpu_data_master_qualified_request_pio_bot_y_s1;
  --cpu/data_master saved-grant pio_bot_y/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_y_s1 <= internal_cpu_data_master_requests_pio_bot_y_s1;
  --allow new arb cycle for pio_bot_y/s1, which is an e_assign
  pio_bot_y_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_y_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_y_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_y_s1_reset_n assignment, which is an e_assign
  pio_bot_y_s1_reset_n <= reset_n;
  pio_bot_y_s1_chipselect <= internal_cpu_data_master_granted_pio_bot_y_s1;
  --pio_bot_y_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_y_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_y_s1_begins_xfer) = '1'), pio_bot_y_s1_unreg_firsttransfer, pio_bot_y_s1_reg_firsttransfer);
  --pio_bot_y_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_y_s1_unreg_firsttransfer <= NOT ((pio_bot_y_s1_slavearbiterlockenable AND pio_bot_y_s1_any_continuerequest));
  --pio_bot_y_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_y_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_y_s1_begins_xfer) = '1' then 
        pio_bot_y_s1_reg_firsttransfer <= pio_bot_y_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_y_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_y_s1_beginbursttransfer_internal <= pio_bot_y_s1_begins_xfer;
  --~pio_bot_y_s1_write_n assignment, which is an e_mux
  pio_bot_y_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_bot_y_s1 AND cpu_data_master_write));
  shifted_address_to_pio_bot_y_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_y_s1_address mux, which is an e_mux
  pio_bot_y_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_y_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_y_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_y_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_y_s1_end_xfer <= pio_bot_y_s1_end_xfer;
    end if;

  end process;

  --pio_bot_y_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_y_s1_waits_for_read <= pio_bot_y_s1_in_a_read_cycle AND pio_bot_y_s1_begins_xfer;
  --pio_bot_y_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_y_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_y_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_y_s1_in_a_read_cycle;
  --pio_bot_y_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_y_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_y_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_y_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_y_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_y_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_y_s1_in_a_write_cycle;
  wait_for_pio_bot_y_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_y_s1 <= internal_cpu_data_master_granted_pio_bot_y_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_y_s1 <= internal_cpu_data_master_qualified_request_pio_bot_y_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_y_s1 <= internal_cpu_data_master_requests_pio_bot_y_s1;
--synthesis translate_off
    --pio_bot_y/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_bot_z_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_z_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_bot_z_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_bot_z_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_bot_z_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_bot_z_s1 : OUT STD_LOGIC;
                 signal d1_pio_bot_z_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_bot_z_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_bot_z_s1_chipselect : OUT STD_LOGIC;
                 signal pio_bot_z_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_bot_z_s1_reset_n : OUT STD_LOGIC;
                 signal pio_bot_z_s1_write_n : OUT STD_LOGIC;
                 signal pio_bot_z_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_bot_z_s1_arbitrator;


architecture europa of pio_bot_z_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_bot_z_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_bot_z_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_bot_z_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_bot_z_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_bot_z_s1 :  STD_LOGIC;
                signal pio_bot_z_s1_allgrants :  STD_LOGIC;
                signal pio_bot_z_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_bot_z_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_bot_z_s1_any_continuerequest :  STD_LOGIC;
                signal pio_bot_z_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_bot_z_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_z_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_z_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_z_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_bot_z_s1_begins_xfer :  STD_LOGIC;
                signal pio_bot_z_s1_end_xfer :  STD_LOGIC;
                signal pio_bot_z_s1_firsttransfer :  STD_LOGIC;
                signal pio_bot_z_s1_grant_vector :  STD_LOGIC;
                signal pio_bot_z_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_bot_z_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_bot_z_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_bot_z_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_bot_z_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_bot_z_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_bot_z_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_bot_z_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_bot_z_s1_waits_for_read :  STD_LOGIC;
                signal pio_bot_z_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_bot_z_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_bot_z_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_bot_z_s1_end_xfer;
    end if;

  end process;

  pio_bot_z_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_bot_z_s1);
  --assign pio_bot_z_s1_readdata_from_sa = pio_bot_z_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_bot_z_s1_readdata_from_sa <= pio_bot_z_s1_readdata;
  internal_cpu_data_master_requests_pio_bot_z_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000100100000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_bot_z_s1_arb_share_counter set values, which is an e_mux
  pio_bot_z_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_bot_z_s1_non_bursting_master_requests mux, which is an e_mux
  pio_bot_z_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_bot_z_s1;
  --pio_bot_z_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_bot_z_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_bot_z_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_bot_z_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_bot_z_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_z_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_bot_z_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_bot_z_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_bot_z_s1_allgrants all slave grants, which is an e_mux
  pio_bot_z_s1_allgrants <= pio_bot_z_s1_grant_vector;
  --pio_bot_z_s1_end_xfer assignment, which is an e_assign
  pio_bot_z_s1_end_xfer <= NOT ((pio_bot_z_s1_waits_for_read OR pio_bot_z_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_bot_z_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_bot_z_s1 <= pio_bot_z_s1_end_xfer AND (((NOT pio_bot_z_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_bot_z_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_bot_z_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_bot_z_s1 AND pio_bot_z_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_bot_z_s1 AND NOT pio_bot_z_s1_non_bursting_master_requests));
  --pio_bot_z_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_z_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_z_s1_arb_counter_enable) = '1' then 
        pio_bot_z_s1_arb_share_counter <= pio_bot_z_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_bot_z_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_z_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_bot_z_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_bot_z_s1)) OR ((end_xfer_arb_share_counter_term_pio_bot_z_s1 AND NOT pio_bot_z_s1_non_bursting_master_requests)))) = '1' then 
        pio_bot_z_s1_slavearbiterlockenable <= or_reduce(pio_bot_z_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_bot_z/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_bot_z_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_bot_z_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_bot_z_s1_slavearbiterlockenable2 <= or_reduce(pio_bot_z_s1_arb_share_counter_next_value);
  --cpu/data_master pio_bot_z/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_bot_z_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_bot_z_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_bot_z_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_bot_z_s1 <= internal_cpu_data_master_requests_pio_bot_z_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_bot_z_s1_writedata mux, which is an e_mux
  pio_bot_z_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_bot_z_s1 <= internal_cpu_data_master_qualified_request_pio_bot_z_s1;
  --cpu/data_master saved-grant pio_bot_z/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_bot_z_s1 <= internal_cpu_data_master_requests_pio_bot_z_s1;
  --allow new arb cycle for pio_bot_z/s1, which is an e_assign
  pio_bot_z_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_bot_z_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_bot_z_s1_master_qreq_vector <= std_logic'('1');
  --pio_bot_z_s1_reset_n assignment, which is an e_assign
  pio_bot_z_s1_reset_n <= reset_n;
  pio_bot_z_s1_chipselect <= internal_cpu_data_master_granted_pio_bot_z_s1;
  --pio_bot_z_s1_firsttransfer first transaction, which is an e_assign
  pio_bot_z_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_bot_z_s1_begins_xfer) = '1'), pio_bot_z_s1_unreg_firsttransfer, pio_bot_z_s1_reg_firsttransfer);
  --pio_bot_z_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_bot_z_s1_unreg_firsttransfer <= NOT ((pio_bot_z_s1_slavearbiterlockenable AND pio_bot_z_s1_any_continuerequest));
  --pio_bot_z_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_bot_z_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_bot_z_s1_begins_xfer) = '1' then 
        pio_bot_z_s1_reg_firsttransfer <= pio_bot_z_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_bot_z_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_bot_z_s1_beginbursttransfer_internal <= pio_bot_z_s1_begins_xfer;
  --~pio_bot_z_s1_write_n assignment, which is an e_mux
  pio_bot_z_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_bot_z_s1 AND cpu_data_master_write));
  shifted_address_to_pio_bot_z_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_bot_z_s1_address mux, which is an e_mux
  pio_bot_z_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_bot_z_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_bot_z_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_bot_z_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_bot_z_s1_end_xfer <= pio_bot_z_s1_end_xfer;
    end if;

  end process;

  --pio_bot_z_s1_waits_for_read in a cycle, which is an e_mux
  pio_bot_z_s1_waits_for_read <= pio_bot_z_s1_in_a_read_cycle AND pio_bot_z_s1_begins_xfer;
  --pio_bot_z_s1_in_a_read_cycle assignment, which is an e_assign
  pio_bot_z_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_bot_z_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_bot_z_s1_in_a_read_cycle;
  --pio_bot_z_s1_waits_for_write in a cycle, which is an e_mux
  pio_bot_z_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_bot_z_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_bot_z_s1_in_a_write_cycle assignment, which is an e_assign
  pio_bot_z_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_bot_z_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_bot_z_s1_in_a_write_cycle;
  wait_for_pio_bot_z_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_bot_z_s1 <= internal_cpu_data_master_granted_pio_bot_z_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_bot_z_s1 <= internal_cpu_data_master_qualified_request_pio_bot_z_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_bot_z_s1 <= internal_cpu_data_master_requests_pio_bot_z_s1;
--synthesis translate_off
    --pio_bot_z/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity pio_led_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_led_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_pio_led_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_pio_led_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_pio_led_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_pio_led_s1 : OUT STD_LOGIC;
                 signal d1_pio_led_s1_end_xfer : OUT STD_LOGIC;
                 signal pio_led_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pio_led_s1_chipselect : OUT STD_LOGIC;
                 signal pio_led_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pio_led_s1_reset_n : OUT STD_LOGIC;
                 signal pio_led_s1_write_n : OUT STD_LOGIC;
                 signal pio_led_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pio_led_s1_arbitrator;


architecture europa of pio_led_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_pio_led_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pio_led_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_pio_led_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_pio_led_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_pio_led_s1 :  STD_LOGIC;
                signal pio_led_s1_allgrants :  STD_LOGIC;
                signal pio_led_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal pio_led_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pio_led_s1_any_continuerequest :  STD_LOGIC;
                signal pio_led_s1_arb_counter_enable :  STD_LOGIC;
                signal pio_led_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_led_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_led_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_led_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal pio_led_s1_begins_xfer :  STD_LOGIC;
                signal pio_led_s1_end_xfer :  STD_LOGIC;
                signal pio_led_s1_firsttransfer :  STD_LOGIC;
                signal pio_led_s1_grant_vector :  STD_LOGIC;
                signal pio_led_s1_in_a_read_cycle :  STD_LOGIC;
                signal pio_led_s1_in_a_write_cycle :  STD_LOGIC;
                signal pio_led_s1_master_qreq_vector :  STD_LOGIC;
                signal pio_led_s1_non_bursting_master_requests :  STD_LOGIC;
                signal pio_led_s1_reg_firsttransfer :  STD_LOGIC;
                signal pio_led_s1_slavearbiterlockenable :  STD_LOGIC;
                signal pio_led_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal pio_led_s1_unreg_firsttransfer :  STD_LOGIC;
                signal pio_led_s1_waits_for_read :  STD_LOGIC;
                signal pio_led_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pio_led_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_pio_led_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pio_led_s1_end_xfer;
    end if;

  end process;

  pio_led_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_pio_led_s1);
  --assign pio_led_s1_readdata_from_sa = pio_led_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pio_led_s1_readdata_from_sa <= pio_led_s1_readdata;
  internal_cpu_data_master_requests_pio_led_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100000000000001000011100000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --pio_led_s1_arb_share_counter set values, which is an e_mux
  pio_led_s1_arb_share_set_values <= std_logic_vector'("01");
  --pio_led_s1_non_bursting_master_requests mux, which is an e_mux
  pio_led_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_pio_led_s1;
  --pio_led_s1_any_bursting_master_saved_grant mux, which is an e_mux
  pio_led_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --pio_led_s1_arb_share_counter_next_value assignment, which is an e_assign
  pio_led_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pio_led_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_led_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pio_led_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pio_led_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pio_led_s1_allgrants all slave grants, which is an e_mux
  pio_led_s1_allgrants <= pio_led_s1_grant_vector;
  --pio_led_s1_end_xfer assignment, which is an e_assign
  pio_led_s1_end_xfer <= NOT ((pio_led_s1_waits_for_read OR pio_led_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_pio_led_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pio_led_s1 <= pio_led_s1_end_xfer AND (((NOT pio_led_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pio_led_s1_arb_share_counter arbitration counter enable, which is an e_assign
  pio_led_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pio_led_s1 AND pio_led_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_pio_led_s1 AND NOT pio_led_s1_non_bursting_master_requests));
  --pio_led_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_led_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pio_led_s1_arb_counter_enable) = '1' then 
        pio_led_s1_arb_share_counter <= pio_led_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pio_led_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_led_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((pio_led_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_pio_led_s1)) OR ((end_xfer_arb_share_counter_term_pio_led_s1 AND NOT pio_led_s1_non_bursting_master_requests)))) = '1' then 
        pio_led_s1_slavearbiterlockenable <= or_reduce(pio_led_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master pio_led/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= pio_led_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --pio_led_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pio_led_s1_slavearbiterlockenable2 <= or_reduce(pio_led_s1_arb_share_counter_next_value);
  --cpu/data_master pio_led/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= pio_led_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --pio_led_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  pio_led_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_pio_led_s1 <= internal_cpu_data_master_requests_pio_led_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --pio_led_s1_writedata mux, which is an e_mux
  pio_led_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_pio_led_s1 <= internal_cpu_data_master_qualified_request_pio_led_s1;
  --cpu/data_master saved-grant pio_led/s1, which is an e_assign
  cpu_data_master_saved_grant_pio_led_s1 <= internal_cpu_data_master_requests_pio_led_s1;
  --allow new arb cycle for pio_led/s1, which is an e_assign
  pio_led_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  pio_led_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  pio_led_s1_master_qreq_vector <= std_logic'('1');
  --pio_led_s1_reset_n assignment, which is an e_assign
  pio_led_s1_reset_n <= reset_n;
  pio_led_s1_chipselect <= internal_cpu_data_master_granted_pio_led_s1;
  --pio_led_s1_firsttransfer first transaction, which is an e_assign
  pio_led_s1_firsttransfer <= A_WE_StdLogic((std_logic'(pio_led_s1_begins_xfer) = '1'), pio_led_s1_unreg_firsttransfer, pio_led_s1_reg_firsttransfer);
  --pio_led_s1_unreg_firsttransfer first transaction, which is an e_assign
  pio_led_s1_unreg_firsttransfer <= NOT ((pio_led_s1_slavearbiterlockenable AND pio_led_s1_any_continuerequest));
  --pio_led_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pio_led_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pio_led_s1_begins_xfer) = '1' then 
        pio_led_s1_reg_firsttransfer <= pio_led_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pio_led_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pio_led_s1_beginbursttransfer_internal <= pio_led_s1_begins_xfer;
  --~pio_led_s1_write_n assignment, which is an e_mux
  pio_led_s1_write_n <= NOT ((internal_cpu_data_master_granted_pio_led_s1 AND cpu_data_master_write));
  shifted_address_to_pio_led_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --pio_led_s1_address mux, which is an e_mux
  pio_led_s1_address <= A_EXT (A_SRL(shifted_address_to_pio_led_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_pio_led_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pio_led_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pio_led_s1_end_xfer <= pio_led_s1_end_xfer;
    end if;

  end process;

  --pio_led_s1_waits_for_read in a cycle, which is an e_mux
  pio_led_s1_waits_for_read <= pio_led_s1_in_a_read_cycle AND pio_led_s1_begins_xfer;
  --pio_led_s1_in_a_read_cycle assignment, which is an e_assign
  pio_led_s1_in_a_read_cycle <= internal_cpu_data_master_granted_pio_led_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pio_led_s1_in_a_read_cycle;
  --pio_led_s1_waits_for_write in a cycle, which is an e_mux
  pio_led_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pio_led_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pio_led_s1_in_a_write_cycle assignment, which is an e_assign
  pio_led_s1_in_a_write_cycle <= internal_cpu_data_master_granted_pio_led_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pio_led_s1_in_a_write_cycle;
  wait_for_pio_led_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_pio_led_s1 <= internal_cpu_data_master_granted_pio_led_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_pio_led_s1 <= internal_cpu_data_master_qualified_request_pio_led_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_pio_led_s1 <= internal_cpu_data_master_requests_pio_led_s1;
--synthesis translate_off
    --pio_led/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1_module;


architecture europa of rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (3 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_6;
  empty <= NOT(full_0);
  full_7 <= std_logic'('0');
  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 4);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 4);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 4);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
    end if;

  end process;


end europa;



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

entity rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1_module;


architecture europa of rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (3 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_6;
  empty <= NOT(full_0);
  full_7 <= std_logic'('0');
  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 4);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 4);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 4);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
    end if;

  end process;


end europa;



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

library std;
use std.textio.all;

entity sdram_s1_arbitrator is 
        port (
              -- inputs:
                 signal Teste_SOPC_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Teste_SOPC_clock_0_out_read : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_write : IN STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal Teste_SOPC_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal Teste_SOPC_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Teste_SOPC_clock_1_out_read : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_write : IN STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sdram_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal sdram_s1_readdatavalid : IN STD_LOGIC;
                 signal sdram_s1_waitrequest : IN STD_LOGIC;

              -- outputs:
                 signal Teste_SOPC_clock_0_out_granted_sdram_s1 : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_qualified_request_sdram_s1 : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_0_out_requests_sdram_s1 : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_granted_sdram_s1 : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_qualified_request_sdram_s1 : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register : OUT STD_LOGIC;
                 signal Teste_SOPC_clock_1_out_requests_sdram_s1 : OUT STD_LOGIC;
                 signal d1_sdram_s1_end_xfer : OUT STD_LOGIC;
                 signal sdram_s1_address : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal sdram_s1_byteenable_n : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal sdram_s1_chipselect : OUT STD_LOGIC;
                 signal sdram_s1_read_n : OUT STD_LOGIC;
                 signal sdram_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal sdram_s1_reset_n : OUT STD_LOGIC;
                 signal sdram_s1_waitrequest_from_sa : OUT STD_LOGIC;
                 signal sdram_s1_write_n : OUT STD_LOGIC;
                 signal sdram_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity sdram_s1_arbitrator;


architecture europa of sdram_s1_arbitrator is
component rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1_module;

component rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1_module;

                signal Teste_SOPC_clock_0_out_arbiterlock :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_arbiterlock2 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_continuerequest :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_rdv_fifo_empty_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_rdv_fifo_output_from_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_saved_grant_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_arbiterlock :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_arbiterlock2 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_continuerequest :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_rdv_fifo_empty_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_rdv_fifo_output_from_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_saved_grant_sdram_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sdram_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_0_out_granted_sdram_s1 :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_0_out_qualified_request_sdram_s1 :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_0_out_requests_sdram_s1 :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_1_out_granted_sdram_s1 :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_1_out_qualified_request_sdram_s1 :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register :  STD_LOGIC;
                signal internal_Teste_SOPC_clock_1_out_requests_sdram_s1 :  STD_LOGIC;
                signal internal_sdram_s1_waitrequest_from_sa :  STD_LOGIC;
                signal last_cycle_Teste_SOPC_clock_0_out_granted_slave_sdram_s1 :  STD_LOGIC;
                signal last_cycle_Teste_SOPC_clock_1_out_granted_slave_sdram_s1 :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal module_input2 :  STD_LOGIC;
                signal module_input3 :  STD_LOGIC;
                signal module_input4 :  STD_LOGIC;
                signal module_input5 :  STD_LOGIC;
                signal sdram_s1_allgrants :  STD_LOGIC;
                signal sdram_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal sdram_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sdram_s1_any_continuerequest :  STD_LOGIC;
                signal sdram_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_s1_arb_counter_enable :  STD_LOGIC;
                signal sdram_s1_arb_share_counter :  STD_LOGIC;
                signal sdram_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal sdram_s1_arb_share_set_values :  STD_LOGIC;
                signal sdram_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal sdram_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal sdram_s1_begins_xfer :  STD_LOGIC;
                signal sdram_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal sdram_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_s1_end_xfer :  STD_LOGIC;
                signal sdram_s1_firsttransfer :  STD_LOGIC;
                signal sdram_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_s1_in_a_read_cycle :  STD_LOGIC;
                signal sdram_s1_in_a_write_cycle :  STD_LOGIC;
                signal sdram_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_s1_move_on_to_next_transaction :  STD_LOGIC;
                signal sdram_s1_non_bursting_master_requests :  STD_LOGIC;
                signal sdram_s1_readdatavalid_from_sa :  STD_LOGIC;
                signal sdram_s1_reg_firsttransfer :  STD_LOGIC;
                signal sdram_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_s1_slavearbiterlockenable :  STD_LOGIC;
                signal sdram_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal sdram_s1_unreg_firsttransfer :  STD_LOGIC;
                signal sdram_s1_waits_for_read :  STD_LOGIC;
                signal sdram_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_sdram_s1_from_Teste_SOPC_clock_0_out :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_sdram_s1_from_Teste_SOPC_clock_1_out :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal wait_for_sdram_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT sdram_s1_end_xfer;
    end if;

  end process;

  sdram_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_Teste_SOPC_clock_0_out_qualified_request_sdram_s1 OR internal_Teste_SOPC_clock_1_out_qualified_request_sdram_s1));
  --assign sdram_s1_readdata_from_sa = sdram_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sdram_s1_readdata_from_sa <= sdram_s1_readdata;
  internal_Teste_SOPC_clock_0_out_requests_sdram_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((Teste_SOPC_clock_0_out_read OR Teste_SOPC_clock_0_out_write)))))));
  --assign sdram_s1_waitrequest_from_sa = sdram_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_sdram_s1_waitrequest_from_sa <= sdram_s1_waitrequest;
  --assign sdram_s1_readdatavalid_from_sa = sdram_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  sdram_s1_readdatavalid_from_sa <= sdram_s1_readdatavalid;
  --sdram_s1_arb_share_counter set values, which is an e_mux
  sdram_s1_arb_share_set_values <= std_logic'('1');
  --sdram_s1_non_bursting_master_requests mux, which is an e_mux
  sdram_s1_non_bursting_master_requests <= ((internal_Teste_SOPC_clock_0_out_requests_sdram_s1 OR internal_Teste_SOPC_clock_1_out_requests_sdram_s1) OR internal_Teste_SOPC_clock_0_out_requests_sdram_s1) OR internal_Teste_SOPC_clock_1_out_requests_sdram_s1;
  --sdram_s1_any_bursting_master_saved_grant mux, which is an e_mux
  sdram_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --sdram_s1_arb_share_counter_next_value assignment, which is an e_assign
  sdram_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(sdram_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sdram_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(sdram_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sdram_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --sdram_s1_allgrants all slave grants, which is an e_mux
  sdram_s1_allgrants <= (((or_reduce(sdram_s1_grant_vector)) OR (or_reduce(sdram_s1_grant_vector))) OR (or_reduce(sdram_s1_grant_vector))) OR (or_reduce(sdram_s1_grant_vector));
  --sdram_s1_end_xfer assignment, which is an e_assign
  sdram_s1_end_xfer <= NOT ((sdram_s1_waits_for_read OR sdram_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_sdram_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sdram_s1 <= sdram_s1_end_xfer AND (((NOT sdram_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sdram_s1_arb_share_counter arbitration counter enable, which is an e_assign
  sdram_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sdram_s1 AND sdram_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_sdram_s1 AND NOT sdram_s1_non_bursting_master_requests));
  --sdram_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(sdram_s1_arb_counter_enable) = '1' then 
        sdram_s1_arb_share_counter <= sdram_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sdram_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(sdram_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_sdram_s1)) OR ((end_xfer_arb_share_counter_term_sdram_s1 AND NOT sdram_s1_non_bursting_master_requests)))) = '1' then 
        sdram_s1_slavearbiterlockenable <= sdram_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --Teste_SOPC_clock_0/out sdram/s1 arbiterlock, which is an e_assign
  Teste_SOPC_clock_0_out_arbiterlock <= sdram_s1_slavearbiterlockenable AND Teste_SOPC_clock_0_out_continuerequest;
  --sdram_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sdram_s1_slavearbiterlockenable2 <= sdram_s1_arb_share_counter_next_value;
  --Teste_SOPC_clock_0/out sdram/s1 arbiterlock2, which is an e_assign
  Teste_SOPC_clock_0_out_arbiterlock2 <= sdram_s1_slavearbiterlockenable2 AND Teste_SOPC_clock_0_out_continuerequest;
  --Teste_SOPC_clock_1/out sdram/s1 arbiterlock, which is an e_assign
  Teste_SOPC_clock_1_out_arbiterlock <= sdram_s1_slavearbiterlockenable AND Teste_SOPC_clock_1_out_continuerequest;
  --Teste_SOPC_clock_1/out sdram/s1 arbiterlock2, which is an e_assign
  Teste_SOPC_clock_1_out_arbiterlock2 <= sdram_s1_slavearbiterlockenable2 AND Teste_SOPC_clock_1_out_continuerequest;
  --Teste_SOPC_clock_1/out granted sdram/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_Teste_SOPC_clock_1_out_granted_slave_sdram_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_Teste_SOPC_clock_1_out_granted_slave_sdram_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(Teste_SOPC_clock_1_out_saved_grant_sdram_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((sdram_s1_arbitration_holdoff_internal OR NOT internal_Teste_SOPC_clock_1_out_requests_sdram_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_Teste_SOPC_clock_1_out_granted_slave_sdram_s1))))));
    end if;

  end process;

  --Teste_SOPC_clock_1_out_continuerequest continued request, which is an e_mux
  Teste_SOPC_clock_1_out_continuerequest <= last_cycle_Teste_SOPC_clock_1_out_granted_slave_sdram_s1 AND internal_Teste_SOPC_clock_1_out_requests_sdram_s1;
  --sdram_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  sdram_s1_any_continuerequest <= Teste_SOPC_clock_1_out_continuerequest OR Teste_SOPC_clock_0_out_continuerequest;
  internal_Teste_SOPC_clock_0_out_qualified_request_sdram_s1 <= internal_Teste_SOPC_clock_0_out_requests_sdram_s1 AND NOT ((((Teste_SOPC_clock_0_out_read AND (internal_Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register))) OR Teste_SOPC_clock_1_out_arbiterlock));
  --unique name for sdram_s1_move_on_to_next_transaction, which is an e_assign
  sdram_s1_move_on_to_next_transaction <= sdram_s1_readdatavalid_from_sa;
  --rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1 : rdv_fifo_for_Teste_SOPC_clock_0_out_to_sdram_s1_module
    port map(
      data_out => Teste_SOPC_clock_0_out_rdv_fifo_output_from_sdram_s1,
      empty => open,
      fifo_contains_ones_n => Teste_SOPC_clock_0_out_rdv_fifo_empty_sdram_s1,
      full => open,
      clear_fifo => module_input,
      clk => clk,
      data_in => internal_Teste_SOPC_clock_0_out_granted_sdram_s1,
      read => sdram_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input1,
      write => module_input2
    );

  module_input <= std_logic'('0');
  module_input1 <= std_logic'('0');
  module_input2 <= in_a_read_cycle AND NOT sdram_s1_waits_for_read;

  internal_Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register <= NOT Teste_SOPC_clock_0_out_rdv_fifo_empty_sdram_s1;
  --local readdatavalid Teste_SOPC_clock_0_out_read_data_valid_sdram_s1, which is an e_mux
  Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 <= ((sdram_s1_readdatavalid_from_sa AND Teste_SOPC_clock_0_out_rdv_fifo_output_from_sdram_s1)) AND NOT Teste_SOPC_clock_0_out_rdv_fifo_empty_sdram_s1;
  --sdram_s1_writedata mux, which is an e_mux
  sdram_s1_writedata <= A_WE_StdLogicVector((std_logic'((internal_Teste_SOPC_clock_0_out_granted_sdram_s1)) = '1'), Teste_SOPC_clock_0_out_writedata, Teste_SOPC_clock_1_out_writedata);
  internal_Teste_SOPC_clock_1_out_requests_sdram_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((Teste_SOPC_clock_1_out_read OR Teste_SOPC_clock_1_out_write)))))));
  --Teste_SOPC_clock_0/out granted sdram/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_Teste_SOPC_clock_0_out_granted_slave_sdram_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_Teste_SOPC_clock_0_out_granted_slave_sdram_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(Teste_SOPC_clock_0_out_saved_grant_sdram_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((sdram_s1_arbitration_holdoff_internal OR NOT internal_Teste_SOPC_clock_0_out_requests_sdram_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_Teste_SOPC_clock_0_out_granted_slave_sdram_s1))))));
    end if;

  end process;

  --Teste_SOPC_clock_0_out_continuerequest continued request, which is an e_mux
  Teste_SOPC_clock_0_out_continuerequest <= last_cycle_Teste_SOPC_clock_0_out_granted_slave_sdram_s1 AND internal_Teste_SOPC_clock_0_out_requests_sdram_s1;
  internal_Teste_SOPC_clock_1_out_qualified_request_sdram_s1 <= internal_Teste_SOPC_clock_1_out_requests_sdram_s1 AND NOT ((((Teste_SOPC_clock_1_out_read AND (internal_Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register))) OR Teste_SOPC_clock_0_out_arbiterlock));
  --rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1 : rdv_fifo_for_Teste_SOPC_clock_1_out_to_sdram_s1_module
    port map(
      data_out => Teste_SOPC_clock_1_out_rdv_fifo_output_from_sdram_s1,
      empty => open,
      fifo_contains_ones_n => Teste_SOPC_clock_1_out_rdv_fifo_empty_sdram_s1,
      full => open,
      clear_fifo => module_input3,
      clk => clk,
      data_in => internal_Teste_SOPC_clock_1_out_granted_sdram_s1,
      read => sdram_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input4,
      write => module_input5
    );

  module_input3 <= std_logic'('0');
  module_input4 <= std_logic'('0');
  module_input5 <= in_a_read_cycle AND NOT sdram_s1_waits_for_read;

  internal_Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register <= NOT Teste_SOPC_clock_1_out_rdv_fifo_empty_sdram_s1;
  --local readdatavalid Teste_SOPC_clock_1_out_read_data_valid_sdram_s1, which is an e_mux
  Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 <= ((sdram_s1_readdatavalid_from_sa AND Teste_SOPC_clock_1_out_rdv_fifo_output_from_sdram_s1)) AND NOT Teste_SOPC_clock_1_out_rdv_fifo_empty_sdram_s1;
  --allow new arb cycle for sdram/s1, which is an e_assign
  sdram_s1_allow_new_arb_cycle <= NOT Teste_SOPC_clock_0_out_arbiterlock AND NOT Teste_SOPC_clock_1_out_arbiterlock;
  --Teste_SOPC_clock_1/out assignment into master qualified-requests vector for sdram/s1, which is an e_assign
  sdram_s1_master_qreq_vector(0) <= internal_Teste_SOPC_clock_1_out_qualified_request_sdram_s1;
  --Teste_SOPC_clock_1/out grant sdram/s1, which is an e_assign
  internal_Teste_SOPC_clock_1_out_granted_sdram_s1 <= sdram_s1_grant_vector(0);
  --Teste_SOPC_clock_1/out saved-grant sdram/s1, which is an e_assign
  Teste_SOPC_clock_1_out_saved_grant_sdram_s1 <= sdram_s1_arb_winner(0) AND internal_Teste_SOPC_clock_1_out_requests_sdram_s1;
  --Teste_SOPC_clock_0/out assignment into master qualified-requests vector for sdram/s1, which is an e_assign
  sdram_s1_master_qreq_vector(1) <= internal_Teste_SOPC_clock_0_out_qualified_request_sdram_s1;
  --Teste_SOPC_clock_0/out grant sdram/s1, which is an e_assign
  internal_Teste_SOPC_clock_0_out_granted_sdram_s1 <= sdram_s1_grant_vector(1);
  --Teste_SOPC_clock_0/out saved-grant sdram/s1, which is an e_assign
  Teste_SOPC_clock_0_out_saved_grant_sdram_s1 <= sdram_s1_arb_winner(1) AND internal_Teste_SOPC_clock_0_out_requests_sdram_s1;
  --sdram/s1 chosen-master double-vector, which is an e_assign
  sdram_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((sdram_s1_master_qreq_vector & sdram_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT sdram_s1_master_qreq_vector & NOT sdram_s1_master_qreq_vector))) + (std_logic_vector'("000") & (sdram_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  sdram_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((sdram_s1_allow_new_arb_cycle AND or_reduce(sdram_s1_grant_vector)))) = '1'), sdram_s1_grant_vector, sdram_s1_saved_chosen_master_vector);
  --saved sdram_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(sdram_s1_allow_new_arb_cycle) = '1' then 
        sdram_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(sdram_s1_grant_vector)) = '1'), sdram_s1_grant_vector, sdram_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  sdram_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((sdram_s1_chosen_master_double_vector(1) OR sdram_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((sdram_s1_chosen_master_double_vector(0) OR sdram_s1_chosen_master_double_vector(2)))));
  --sdram/s1 chosen master rotated left, which is an e_assign
  sdram_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(sdram_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(sdram_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --sdram/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(sdram_s1_grant_vector)) = '1' then 
        sdram_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(sdram_s1_end_xfer) = '1'), sdram_s1_chosen_master_rot_left, sdram_s1_grant_vector);
      end if;
    end if;

  end process;

  --sdram_s1_reset_n assignment, which is an e_assign
  sdram_s1_reset_n <= reset_n;
  sdram_s1_chipselect <= internal_Teste_SOPC_clock_0_out_granted_sdram_s1 OR internal_Teste_SOPC_clock_1_out_granted_sdram_s1;
  --sdram_s1_firsttransfer first transaction, which is an e_assign
  sdram_s1_firsttransfer <= A_WE_StdLogic((std_logic'(sdram_s1_begins_xfer) = '1'), sdram_s1_unreg_firsttransfer, sdram_s1_reg_firsttransfer);
  --sdram_s1_unreg_firsttransfer first transaction, which is an e_assign
  sdram_s1_unreg_firsttransfer <= NOT ((sdram_s1_slavearbiterlockenable AND sdram_s1_any_continuerequest));
  --sdram_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sdram_s1_begins_xfer) = '1' then 
        sdram_s1_reg_firsttransfer <= sdram_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sdram_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sdram_s1_beginbursttransfer_internal <= sdram_s1_begins_xfer;
  --sdram_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  sdram_s1_arbitration_holdoff_internal <= sdram_s1_begins_xfer AND sdram_s1_firsttransfer;
  --~sdram_s1_read_n assignment, which is an e_mux
  sdram_s1_read_n <= NOT ((((internal_Teste_SOPC_clock_0_out_granted_sdram_s1 AND Teste_SOPC_clock_0_out_read)) OR ((internal_Teste_SOPC_clock_1_out_granted_sdram_s1 AND Teste_SOPC_clock_1_out_read))));
  --~sdram_s1_write_n assignment, which is an e_mux
  sdram_s1_write_n <= NOT ((((internal_Teste_SOPC_clock_0_out_granted_sdram_s1 AND Teste_SOPC_clock_0_out_write)) OR ((internal_Teste_SOPC_clock_1_out_granted_sdram_s1 AND Teste_SOPC_clock_1_out_write))));
  shifted_address_to_sdram_s1_from_Teste_SOPC_clock_0_out <= Teste_SOPC_clock_0_out_address_to_slave;
  --sdram_s1_address mux, which is an e_mux
  sdram_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_Teste_SOPC_clock_0_out_granted_sdram_s1)) = '1'), (A_SRL(shifted_address_to_sdram_s1_from_Teste_SOPC_clock_0_out,std_logic_vector'("00000000000000000000000000000001"))), (A_SRL(shifted_address_to_sdram_s1_from_Teste_SOPC_clock_1_out,std_logic_vector'("00000000000000000000000000000001")))), 24);
  shifted_address_to_sdram_s1_from_Teste_SOPC_clock_1_out <= Teste_SOPC_clock_1_out_address_to_slave;
  --d1_sdram_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sdram_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_sdram_s1_end_xfer <= sdram_s1_end_xfer;
    end if;

  end process;

  --sdram_s1_waits_for_read in a cycle, which is an e_mux
  sdram_s1_waits_for_read <= sdram_s1_in_a_read_cycle AND internal_sdram_s1_waitrequest_from_sa;
  --sdram_s1_in_a_read_cycle assignment, which is an e_assign
  sdram_s1_in_a_read_cycle <= ((internal_Teste_SOPC_clock_0_out_granted_sdram_s1 AND Teste_SOPC_clock_0_out_read)) OR ((internal_Teste_SOPC_clock_1_out_granted_sdram_s1 AND Teste_SOPC_clock_1_out_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sdram_s1_in_a_read_cycle;
  --sdram_s1_waits_for_write in a cycle, which is an e_mux
  sdram_s1_waits_for_write <= sdram_s1_in_a_write_cycle AND internal_sdram_s1_waitrequest_from_sa;
  --sdram_s1_in_a_write_cycle assignment, which is an e_assign
  sdram_s1_in_a_write_cycle <= ((internal_Teste_SOPC_clock_0_out_granted_sdram_s1 AND Teste_SOPC_clock_0_out_write)) OR ((internal_Teste_SOPC_clock_1_out_granted_sdram_s1 AND Teste_SOPC_clock_1_out_write));
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sdram_s1_in_a_write_cycle;
  wait_for_sdram_s1_counter <= std_logic'('0');
  --~sdram_s1_byteenable_n byte enable port mux, which is an e_mux
  sdram_s1_byteenable_n <= A_EXT (NOT (A_WE_StdLogicVector((std_logic'((internal_Teste_SOPC_clock_0_out_granted_sdram_s1)) = '1'), (std_logic_vector'("000000000000000000000000000000") & (Teste_SOPC_clock_0_out_byteenable)), A_WE_StdLogicVector((std_logic'((internal_Teste_SOPC_clock_1_out_granted_sdram_s1)) = '1'), (std_logic_vector'("000000000000000000000000000000") & (Teste_SOPC_clock_1_out_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))))), 2);
  --vhdl renameroo for output signals
  Teste_SOPC_clock_0_out_granted_sdram_s1 <= internal_Teste_SOPC_clock_0_out_granted_sdram_s1;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_0_out_qualified_request_sdram_s1 <= internal_Teste_SOPC_clock_0_out_qualified_request_sdram_s1;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register <= internal_Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_0_out_requests_sdram_s1 <= internal_Teste_SOPC_clock_0_out_requests_sdram_s1;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_1_out_granted_sdram_s1 <= internal_Teste_SOPC_clock_1_out_granted_sdram_s1;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_1_out_qualified_request_sdram_s1 <= internal_Teste_SOPC_clock_1_out_qualified_request_sdram_s1;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register <= internal_Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register;
  --vhdl renameroo for output signals
  Teste_SOPC_clock_1_out_requests_sdram_s1 <= internal_Teste_SOPC_clock_1_out_requests_sdram_s1;
  --vhdl renameroo for output signals
  sdram_s1_waitrequest_from_sa <= internal_sdram_s1_waitrequest_from_sa;
--synthesis translate_off
    --sdram/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line14 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_Teste_SOPC_clock_0_out_granted_sdram_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_Teste_SOPC_clock_1_out_granted_sdram_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line14, now);
          write(write_line14, string'(": "));
          write(write_line14, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line14.all);
          deallocate (write_line14);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line15 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(Teste_SOPC_clock_0_out_saved_grant_sdram_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(Teste_SOPC_clock_1_out_saved_grant_sdram_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line15, now);
          write(write_line15, string'(": "));
          write(write_line15, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line15.all);
          deallocate (write_line15);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity spi_spi_control_port_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal spi_spi_control_port_dataavailable : IN STD_LOGIC;
                 signal spi_spi_control_port_endofpacket : IN STD_LOGIC;
                 signal spi_spi_control_port_irq : IN STD_LOGIC;
                 signal spi_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal spi_spi_control_port_readyfordata : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_spi_spi_control_port : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_spi_spi_control_port : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_spi_spi_control_port : OUT STD_LOGIC;
                 signal cpu_data_master_requests_spi_spi_control_port : OUT STD_LOGIC;
                 signal d1_spi_spi_control_port_end_xfer : OUT STD_LOGIC;
                 signal spi_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal spi_spi_control_port_chipselect : OUT STD_LOGIC;
                 signal spi_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                 signal spi_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                 signal spi_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                 signal spi_spi_control_port_read_n : OUT STD_LOGIC;
                 signal spi_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal spi_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                 signal spi_spi_control_port_reset_n : OUT STD_LOGIC;
                 signal spi_spi_control_port_write_n : OUT STD_LOGIC;
                 signal spi_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity spi_spi_control_port_arbitrator;


architecture europa of spi_spi_control_port_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_spi_spi_control_port :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_spi_spi_control_port :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_spi_spi_control_port :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_spi_spi_control_port :  STD_LOGIC;
                signal internal_cpu_data_master_requests_spi_spi_control_port :  STD_LOGIC;
                signal shifted_address_to_spi_spi_control_port_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal spi_spi_control_port_allgrants :  STD_LOGIC;
                signal spi_spi_control_port_allow_new_arb_cycle :  STD_LOGIC;
                signal spi_spi_control_port_any_bursting_master_saved_grant :  STD_LOGIC;
                signal spi_spi_control_port_any_continuerequest :  STD_LOGIC;
                signal spi_spi_control_port_arb_counter_enable :  STD_LOGIC;
                signal spi_spi_control_port_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal spi_spi_control_port_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal spi_spi_control_port_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal spi_spi_control_port_beginbursttransfer_internal :  STD_LOGIC;
                signal spi_spi_control_port_begins_xfer :  STD_LOGIC;
                signal spi_spi_control_port_end_xfer :  STD_LOGIC;
                signal spi_spi_control_port_firsttransfer :  STD_LOGIC;
                signal spi_spi_control_port_grant_vector :  STD_LOGIC;
                signal spi_spi_control_port_in_a_read_cycle :  STD_LOGIC;
                signal spi_spi_control_port_in_a_write_cycle :  STD_LOGIC;
                signal spi_spi_control_port_master_qreq_vector :  STD_LOGIC;
                signal spi_spi_control_port_non_bursting_master_requests :  STD_LOGIC;
                signal spi_spi_control_port_reg_firsttransfer :  STD_LOGIC;
                signal spi_spi_control_port_slavearbiterlockenable :  STD_LOGIC;
                signal spi_spi_control_port_slavearbiterlockenable2 :  STD_LOGIC;
                signal spi_spi_control_port_unreg_firsttransfer :  STD_LOGIC;
                signal spi_spi_control_port_waits_for_read :  STD_LOGIC;
                signal spi_spi_control_port_waits_for_write :  STD_LOGIC;
                signal wait_for_spi_spi_control_port_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT spi_spi_control_port_end_xfer;
    end if;

  end process;

  spi_spi_control_port_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_spi_spi_control_port);
  --assign spi_spi_control_port_readdata_from_sa = spi_spi_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_spi_control_port_readdata_from_sa <= spi_spi_control_port_readdata;
  internal_cpu_data_master_requests_spi_spi_control_port <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("100000000000001000010000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign spi_spi_control_port_dataavailable_from_sa = spi_spi_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_spi_control_port_dataavailable_from_sa <= spi_spi_control_port_dataavailable;
  --assign spi_spi_control_port_readyfordata_from_sa = spi_spi_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_spi_control_port_readyfordata_from_sa <= spi_spi_control_port_readyfordata;
  --spi_spi_control_port_arb_share_counter set values, which is an e_mux
  spi_spi_control_port_arb_share_set_values <= std_logic_vector'("01");
  --spi_spi_control_port_non_bursting_master_requests mux, which is an e_mux
  spi_spi_control_port_non_bursting_master_requests <= internal_cpu_data_master_requests_spi_spi_control_port;
  --spi_spi_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  spi_spi_control_port_any_bursting_master_saved_grant <= std_logic'('0');
  --spi_spi_control_port_arb_share_counter_next_value assignment, which is an e_assign
  spi_spi_control_port_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(spi_spi_control_port_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (spi_spi_control_port_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(spi_spi_control_port_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (spi_spi_control_port_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --spi_spi_control_port_allgrants all slave grants, which is an e_mux
  spi_spi_control_port_allgrants <= spi_spi_control_port_grant_vector;
  --spi_spi_control_port_end_xfer assignment, which is an e_assign
  spi_spi_control_port_end_xfer <= NOT ((spi_spi_control_port_waits_for_read OR spi_spi_control_port_waits_for_write));
  --end_xfer_arb_share_counter_term_spi_spi_control_port arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_spi_spi_control_port <= spi_spi_control_port_end_xfer AND (((NOT spi_spi_control_port_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --spi_spi_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  spi_spi_control_port_arb_counter_enable <= ((end_xfer_arb_share_counter_term_spi_spi_control_port AND spi_spi_control_port_allgrants)) OR ((end_xfer_arb_share_counter_term_spi_spi_control_port AND NOT spi_spi_control_port_non_bursting_master_requests));
  --spi_spi_control_port_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_spi_control_port_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(spi_spi_control_port_arb_counter_enable) = '1' then 
        spi_spi_control_port_arb_share_counter <= spi_spi_control_port_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --spi_spi_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_spi_control_port_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((spi_spi_control_port_master_qreq_vector AND end_xfer_arb_share_counter_term_spi_spi_control_port)) OR ((end_xfer_arb_share_counter_term_spi_spi_control_port AND NOT spi_spi_control_port_non_bursting_master_requests)))) = '1' then 
        spi_spi_control_port_slavearbiterlockenable <= or_reduce(spi_spi_control_port_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master spi/spi_control_port arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= spi_spi_control_port_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --spi_spi_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  spi_spi_control_port_slavearbiterlockenable2 <= or_reduce(spi_spi_control_port_arb_share_counter_next_value);
  --cpu/data_master spi/spi_control_port arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= spi_spi_control_port_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --spi_spi_control_port_any_continuerequest at least one master continues requesting, which is an e_assign
  spi_spi_control_port_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_spi_spi_control_port <= internal_cpu_data_master_requests_spi_spi_control_port;
  --spi_spi_control_port_writedata mux, which is an e_mux
  spi_spi_control_port_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --assign spi_spi_control_port_endofpacket_from_sa = spi_spi_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_spi_control_port_endofpacket_from_sa <= spi_spi_control_port_endofpacket;
  --master is always granted when requested
  internal_cpu_data_master_granted_spi_spi_control_port <= internal_cpu_data_master_qualified_request_spi_spi_control_port;
  --cpu/data_master saved-grant spi/spi_control_port, which is an e_assign
  cpu_data_master_saved_grant_spi_spi_control_port <= internal_cpu_data_master_requests_spi_spi_control_port;
  --allow new arb cycle for spi/spi_control_port, which is an e_assign
  spi_spi_control_port_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  spi_spi_control_port_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  spi_spi_control_port_master_qreq_vector <= std_logic'('1');
  --spi_spi_control_port_reset_n assignment, which is an e_assign
  spi_spi_control_port_reset_n <= reset_n;
  spi_spi_control_port_chipselect <= internal_cpu_data_master_granted_spi_spi_control_port;
  --spi_spi_control_port_firsttransfer first transaction, which is an e_assign
  spi_spi_control_port_firsttransfer <= A_WE_StdLogic((std_logic'(spi_spi_control_port_begins_xfer) = '1'), spi_spi_control_port_unreg_firsttransfer, spi_spi_control_port_reg_firsttransfer);
  --spi_spi_control_port_unreg_firsttransfer first transaction, which is an e_assign
  spi_spi_control_port_unreg_firsttransfer <= NOT ((spi_spi_control_port_slavearbiterlockenable AND spi_spi_control_port_any_continuerequest));
  --spi_spi_control_port_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_spi_control_port_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(spi_spi_control_port_begins_xfer) = '1' then 
        spi_spi_control_port_reg_firsttransfer <= spi_spi_control_port_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --spi_spi_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  spi_spi_control_port_beginbursttransfer_internal <= spi_spi_control_port_begins_xfer;
  --~spi_spi_control_port_read_n assignment, which is an e_mux
  spi_spi_control_port_read_n <= NOT ((internal_cpu_data_master_granted_spi_spi_control_port AND cpu_data_master_read));
  --~spi_spi_control_port_write_n assignment, which is an e_mux
  spi_spi_control_port_write_n <= NOT ((internal_cpu_data_master_granted_spi_spi_control_port AND cpu_data_master_write));
  shifted_address_to_spi_spi_control_port_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --spi_spi_control_port_address mux, which is an e_mux
  spi_spi_control_port_address <= A_EXT (A_SRL(shifted_address_to_spi_spi_control_port_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_spi_spi_control_port_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_spi_spi_control_port_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_spi_spi_control_port_end_xfer <= spi_spi_control_port_end_xfer;
    end if;

  end process;

  --spi_spi_control_port_waits_for_read in a cycle, which is an e_mux
  spi_spi_control_port_waits_for_read <= spi_spi_control_port_in_a_read_cycle AND spi_spi_control_port_begins_xfer;
  --spi_spi_control_port_in_a_read_cycle assignment, which is an e_assign
  spi_spi_control_port_in_a_read_cycle <= internal_cpu_data_master_granted_spi_spi_control_port AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= spi_spi_control_port_in_a_read_cycle;
  --spi_spi_control_port_waits_for_write in a cycle, which is an e_mux
  spi_spi_control_port_waits_for_write <= spi_spi_control_port_in_a_write_cycle AND spi_spi_control_port_begins_xfer;
  --spi_spi_control_port_in_a_write_cycle assignment, which is an e_assign
  spi_spi_control_port_in_a_write_cycle <= internal_cpu_data_master_granted_spi_spi_control_port AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= spi_spi_control_port_in_a_write_cycle;
  wait_for_spi_spi_control_port_counter <= std_logic'('0');
  --assign spi_spi_control_port_irq_from_sa = spi_spi_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_spi_control_port_irq_from_sa <= spi_spi_control_port_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_spi_spi_control_port <= internal_cpu_data_master_granted_spi_spi_control_port;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_spi_spi_control_port <= internal_cpu_data_master_qualified_request_spi_spi_control_port;
  --vhdl renameroo for output signals
  cpu_data_master_requests_spi_spi_control_port <= internal_cpu_data_master_requests_spi_spi_control_port;
--synthesis translate_off
    --spi/spi_control_port enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity timer_sys_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal timer_sys_s1_irq : IN STD_LOGIC;
                 signal timer_sys_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_granted_timer_sys_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_timer_sys_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_timer_sys_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_timer_sys_s1 : OUT STD_LOGIC;
                 signal d1_timer_sys_s1_end_xfer : OUT STD_LOGIC;
                 signal timer_sys_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal timer_sys_s1_chipselect : OUT STD_LOGIC;
                 signal timer_sys_s1_irq_from_sa : OUT STD_LOGIC;
                 signal timer_sys_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal timer_sys_s1_reset_n : OUT STD_LOGIC;
                 signal timer_sys_s1_write_n : OUT STD_LOGIC;
                 signal timer_sys_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity timer_sys_s1_arbitrator;


architecture europa of timer_sys_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_timer_sys_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_timer_sys_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_timer_sys_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_timer_sys_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_timer_sys_s1 :  STD_LOGIC;
                signal shifted_address_to_timer_sys_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal timer_sys_s1_allgrants :  STD_LOGIC;
                signal timer_sys_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal timer_sys_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal timer_sys_s1_any_continuerequest :  STD_LOGIC;
                signal timer_sys_s1_arb_counter_enable :  STD_LOGIC;
                signal timer_sys_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal timer_sys_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal timer_sys_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal timer_sys_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal timer_sys_s1_begins_xfer :  STD_LOGIC;
                signal timer_sys_s1_end_xfer :  STD_LOGIC;
                signal timer_sys_s1_firsttransfer :  STD_LOGIC;
                signal timer_sys_s1_grant_vector :  STD_LOGIC;
                signal timer_sys_s1_in_a_read_cycle :  STD_LOGIC;
                signal timer_sys_s1_in_a_write_cycle :  STD_LOGIC;
                signal timer_sys_s1_master_qreq_vector :  STD_LOGIC;
                signal timer_sys_s1_non_bursting_master_requests :  STD_LOGIC;
                signal timer_sys_s1_reg_firsttransfer :  STD_LOGIC;
                signal timer_sys_s1_slavearbiterlockenable :  STD_LOGIC;
                signal timer_sys_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal timer_sys_s1_unreg_firsttransfer :  STD_LOGIC;
                signal timer_sys_s1_waits_for_read :  STD_LOGIC;
                signal timer_sys_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_timer_sys_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT timer_sys_s1_end_xfer;
    end if;

  end process;

  timer_sys_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_timer_sys_s1);
  --assign timer_sys_s1_readdata_from_sa = timer_sys_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_sys_s1_readdata_from_sa <= timer_sys_s1_readdata;
  internal_cpu_data_master_requests_timer_sys_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("100000000000001000010100000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --timer_sys_s1_arb_share_counter set values, which is an e_mux
  timer_sys_s1_arb_share_set_values <= std_logic_vector'("01");
  --timer_sys_s1_non_bursting_master_requests mux, which is an e_mux
  timer_sys_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_timer_sys_s1;
  --timer_sys_s1_any_bursting_master_saved_grant mux, which is an e_mux
  timer_sys_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --timer_sys_s1_arb_share_counter_next_value assignment, which is an e_assign
  timer_sys_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(timer_sys_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (timer_sys_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(timer_sys_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (timer_sys_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --timer_sys_s1_allgrants all slave grants, which is an e_mux
  timer_sys_s1_allgrants <= timer_sys_s1_grant_vector;
  --timer_sys_s1_end_xfer assignment, which is an e_assign
  timer_sys_s1_end_xfer <= NOT ((timer_sys_s1_waits_for_read OR timer_sys_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_timer_sys_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_timer_sys_s1 <= timer_sys_s1_end_xfer AND (((NOT timer_sys_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --timer_sys_s1_arb_share_counter arbitration counter enable, which is an e_assign
  timer_sys_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_timer_sys_s1 AND timer_sys_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_timer_sys_s1 AND NOT timer_sys_s1_non_bursting_master_requests));
  --timer_sys_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_sys_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(timer_sys_s1_arb_counter_enable) = '1' then 
        timer_sys_s1_arb_share_counter <= timer_sys_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --timer_sys_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_sys_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((timer_sys_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_timer_sys_s1)) OR ((end_xfer_arb_share_counter_term_timer_sys_s1 AND NOT timer_sys_s1_non_bursting_master_requests)))) = '1' then 
        timer_sys_s1_slavearbiterlockenable <= or_reduce(timer_sys_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master timer_sys/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= timer_sys_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --timer_sys_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  timer_sys_s1_slavearbiterlockenable2 <= or_reduce(timer_sys_s1_arb_share_counter_next_value);
  --cpu/data_master timer_sys/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= timer_sys_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --timer_sys_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  timer_sys_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_timer_sys_s1 <= internal_cpu_data_master_requests_timer_sys_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --timer_sys_s1_writedata mux, which is an e_mux
  timer_sys_s1_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_timer_sys_s1 <= internal_cpu_data_master_qualified_request_timer_sys_s1;
  --cpu/data_master saved-grant timer_sys/s1, which is an e_assign
  cpu_data_master_saved_grant_timer_sys_s1 <= internal_cpu_data_master_requests_timer_sys_s1;
  --allow new arb cycle for timer_sys/s1, which is an e_assign
  timer_sys_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  timer_sys_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  timer_sys_s1_master_qreq_vector <= std_logic'('1');
  --timer_sys_s1_reset_n assignment, which is an e_assign
  timer_sys_s1_reset_n <= reset_n;
  timer_sys_s1_chipselect <= internal_cpu_data_master_granted_timer_sys_s1;
  --timer_sys_s1_firsttransfer first transaction, which is an e_assign
  timer_sys_s1_firsttransfer <= A_WE_StdLogic((std_logic'(timer_sys_s1_begins_xfer) = '1'), timer_sys_s1_unreg_firsttransfer, timer_sys_s1_reg_firsttransfer);
  --timer_sys_s1_unreg_firsttransfer first transaction, which is an e_assign
  timer_sys_s1_unreg_firsttransfer <= NOT ((timer_sys_s1_slavearbiterlockenable AND timer_sys_s1_any_continuerequest));
  --timer_sys_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_sys_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(timer_sys_s1_begins_xfer) = '1' then 
        timer_sys_s1_reg_firsttransfer <= timer_sys_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --timer_sys_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  timer_sys_s1_beginbursttransfer_internal <= timer_sys_s1_begins_xfer;
  --~timer_sys_s1_write_n assignment, which is an e_mux
  timer_sys_s1_write_n <= NOT ((internal_cpu_data_master_granted_timer_sys_s1 AND cpu_data_master_write));
  shifted_address_to_timer_sys_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --timer_sys_s1_address mux, which is an e_mux
  timer_sys_s1_address <= A_EXT (A_SRL(shifted_address_to_timer_sys_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_timer_sys_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_timer_sys_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_timer_sys_s1_end_xfer <= timer_sys_s1_end_xfer;
    end if;

  end process;

  --timer_sys_s1_waits_for_read in a cycle, which is an e_mux
  timer_sys_s1_waits_for_read <= timer_sys_s1_in_a_read_cycle AND timer_sys_s1_begins_xfer;
  --timer_sys_s1_in_a_read_cycle assignment, which is an e_assign
  timer_sys_s1_in_a_read_cycle <= internal_cpu_data_master_granted_timer_sys_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= timer_sys_s1_in_a_read_cycle;
  --timer_sys_s1_waits_for_write in a cycle, which is an e_mux
  timer_sys_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_sys_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --timer_sys_s1_in_a_write_cycle assignment, which is an e_assign
  timer_sys_s1_in_a_write_cycle <= internal_cpu_data_master_granted_timer_sys_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= timer_sys_s1_in_a_write_cycle;
  wait_for_timer_sys_s1_counter <= std_logic'('0');
  --assign timer_sys_s1_irq_from_sa = timer_sys_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_sys_s1_irq_from_sa <= timer_sys_s1_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_timer_sys_s1 <= internal_cpu_data_master_granted_timer_sys_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_timer_sys_s1 <= internal_cpu_data_master_qualified_request_timer_sys_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_timer_sys_s1 <= internal_cpu_data_master_requests_timer_sys_s1;
--synthesis translate_off
    --timer_sys/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity uart_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal uart_s1_dataavailable : IN STD_LOGIC;
                 signal uart_s1_irq : IN STD_LOGIC;
                 signal uart_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal uart_s1_readyfordata : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_uart_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_uart_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_uart_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_uart_s1 : OUT STD_LOGIC;
                 signal d1_uart_s1_end_xfer : OUT STD_LOGIC;
                 signal uart_s1_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal uart_s1_begintransfer : OUT STD_LOGIC;
                 signal uart_s1_chipselect : OUT STD_LOGIC;
                 signal uart_s1_dataavailable_from_sa : OUT STD_LOGIC;
                 signal uart_s1_irq_from_sa : OUT STD_LOGIC;
                 signal uart_s1_read_n : OUT STD_LOGIC;
                 signal uart_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal uart_s1_readyfordata_from_sa : OUT STD_LOGIC;
                 signal uart_s1_reset_n : OUT STD_LOGIC;
                 signal uart_s1_write_n : OUT STD_LOGIC;
                 signal uart_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity uart_s1_arbitrator;


architecture europa of uart_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_uart_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_uart_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_uart_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_uart_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_uart_s1 :  STD_LOGIC;
                signal shifted_address_to_uart_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal uart_s1_allgrants :  STD_LOGIC;
                signal uart_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal uart_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal uart_s1_any_continuerequest :  STD_LOGIC;
                signal uart_s1_arb_counter_enable :  STD_LOGIC;
                signal uart_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal uart_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal uart_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal uart_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal uart_s1_begins_xfer :  STD_LOGIC;
                signal uart_s1_end_xfer :  STD_LOGIC;
                signal uart_s1_firsttransfer :  STD_LOGIC;
                signal uart_s1_grant_vector :  STD_LOGIC;
                signal uart_s1_in_a_read_cycle :  STD_LOGIC;
                signal uart_s1_in_a_write_cycle :  STD_LOGIC;
                signal uart_s1_master_qreq_vector :  STD_LOGIC;
                signal uart_s1_non_bursting_master_requests :  STD_LOGIC;
                signal uart_s1_reg_firsttransfer :  STD_LOGIC;
                signal uart_s1_slavearbiterlockenable :  STD_LOGIC;
                signal uart_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal uart_s1_unreg_firsttransfer :  STD_LOGIC;
                signal uart_s1_waits_for_read :  STD_LOGIC;
                signal uart_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_uart_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT uart_s1_end_xfer;
    end if;

  end process;

  uart_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_uart_s1);
  --assign uart_s1_readdata_from_sa = uart_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_s1_readdata_from_sa <= uart_s1_readdata;
  internal_cpu_data_master_requests_uart_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(26 DOWNTO 6) & std_logic_vector'("000000")) = std_logic_vector'("100000000000001000001000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign uart_s1_dataavailable_from_sa = uart_s1_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_s1_dataavailable_from_sa <= uart_s1_dataavailable;
  --assign uart_s1_readyfordata_from_sa = uart_s1_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_s1_readyfordata_from_sa <= uart_s1_readyfordata;
  --uart_s1_arb_share_counter set values, which is an e_mux
  uart_s1_arb_share_set_values <= std_logic_vector'("01");
  --uart_s1_non_bursting_master_requests mux, which is an e_mux
  uart_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_uart_s1;
  --uart_s1_any_bursting_master_saved_grant mux, which is an e_mux
  uart_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --uart_s1_arb_share_counter_next_value assignment, which is an e_assign
  uart_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(uart_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (uart_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(uart_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (uart_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --uart_s1_allgrants all slave grants, which is an e_mux
  uart_s1_allgrants <= uart_s1_grant_vector;
  --uart_s1_end_xfer assignment, which is an e_assign
  uart_s1_end_xfer <= NOT ((uart_s1_waits_for_read OR uart_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_uart_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_uart_s1 <= uart_s1_end_xfer AND (((NOT uart_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --uart_s1_arb_share_counter arbitration counter enable, which is an e_assign
  uart_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_uart_s1 AND uart_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_uart_s1 AND NOT uart_s1_non_bursting_master_requests));
  --uart_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(uart_s1_arb_counter_enable) = '1' then 
        uart_s1_arb_share_counter <= uart_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --uart_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((uart_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_uart_s1)) OR ((end_xfer_arb_share_counter_term_uart_s1 AND NOT uart_s1_non_bursting_master_requests)))) = '1' then 
        uart_s1_slavearbiterlockenable <= or_reduce(uart_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --cpu/data_master uart/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= uart_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --uart_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  uart_s1_slavearbiterlockenable2 <= or_reduce(uart_s1_arb_share_counter_next_value);
  --cpu/data_master uart/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= uart_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --uart_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  uart_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_uart_s1 <= internal_cpu_data_master_requests_uart_s1;
  --uart_s1_writedata mux, which is an e_mux
  uart_s1_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_uart_s1 <= internal_cpu_data_master_qualified_request_uart_s1;
  --cpu/data_master saved-grant uart/s1, which is an e_assign
  cpu_data_master_saved_grant_uart_s1 <= internal_cpu_data_master_requests_uart_s1;
  --allow new arb cycle for uart/s1, which is an e_assign
  uart_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  uart_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  uart_s1_master_qreq_vector <= std_logic'('1');
  uart_s1_begintransfer <= uart_s1_begins_xfer;
  --uart_s1_reset_n assignment, which is an e_assign
  uart_s1_reset_n <= reset_n;
  uart_s1_chipselect <= internal_cpu_data_master_granted_uart_s1;
  --uart_s1_firsttransfer first transaction, which is an e_assign
  uart_s1_firsttransfer <= A_WE_StdLogic((std_logic'(uart_s1_begins_xfer) = '1'), uart_s1_unreg_firsttransfer, uart_s1_reg_firsttransfer);
  --uart_s1_unreg_firsttransfer first transaction, which is an e_assign
  uart_s1_unreg_firsttransfer <= NOT ((uart_s1_slavearbiterlockenable AND uart_s1_any_continuerequest));
  --uart_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(uart_s1_begins_xfer) = '1' then 
        uart_s1_reg_firsttransfer <= uart_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --uart_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  uart_s1_beginbursttransfer_internal <= uart_s1_begins_xfer;
  --~uart_s1_read_n assignment, which is an e_mux
  uart_s1_read_n <= NOT ((internal_cpu_data_master_granted_uart_s1 AND cpu_data_master_read));
  --~uart_s1_write_n assignment, which is an e_mux
  uart_s1_write_n <= NOT ((internal_cpu_data_master_granted_uart_s1 AND cpu_data_master_write));
  shifted_address_to_uart_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --uart_s1_address mux, which is an e_mux
  uart_s1_address <= A_EXT (A_SRL(shifted_address_to_uart_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 4);
  --d1_uart_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_uart_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_uart_s1_end_xfer <= uart_s1_end_xfer;
    end if;

  end process;

  --uart_s1_waits_for_read in a cycle, which is an e_mux
  uart_s1_waits_for_read <= uart_s1_in_a_read_cycle AND uart_s1_begins_xfer;
  --uart_s1_in_a_read_cycle assignment, which is an e_assign
  uart_s1_in_a_read_cycle <= internal_cpu_data_master_granted_uart_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= uart_s1_in_a_read_cycle;
  --uart_s1_waits_for_write in a cycle, which is an e_mux
  uart_s1_waits_for_write <= uart_s1_in_a_write_cycle AND uart_s1_begins_xfer;
  --uart_s1_in_a_write_cycle assignment, which is an e_assign
  uart_s1_in_a_write_cycle <= internal_cpu_data_master_granted_uart_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= uart_s1_in_a_write_cycle;
  wait_for_uart_s1_counter <= std_logic'('0');
  --assign uart_s1_irq_from_sa = uart_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_s1_irq_from_sa <= uart_s1_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_uart_s1 <= internal_cpu_data_master_granted_uart_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_uart_s1 <= internal_cpu_data_master_qualified_request_uart_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_uart_s1 <= internal_cpu_data_master_requests_uart_s1;
--synthesis translate_off
    --uart/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



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

entity Teste_SOPC_reset_clk_100_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity Teste_SOPC_reset_clk_100_domain_synch_module;


architecture europa of Teste_SOPC_reset_clk_100_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



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

entity Teste_SOPC_reset_altpll_sdram_c0_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity Teste_SOPC_reset_altpll_sdram_c0_domain_synch_module;


architecture europa of Teste_SOPC_reset_altpll_sdram_c0_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



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

entity Teste_SOPC is 
        port (
              -- 1) global signals:
                 signal altpll_sdram_c0 : OUT STD_LOGIC;
                 signal clk_100 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_I2C_Master
                 signal scl_pad_io_to_and_from_the_I2C_Master : INOUT STD_LOGIC;
                 signal sda_pad_io_to_and_from_the_I2C_Master : INOUT STD_LOGIC;

              -- the_TERASIC_SPI_3WIRE_0
                 signal SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0 : OUT STD_LOGIC;
                 signal SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0 : OUT STD_LOGIC;
                 signal SPI_SDIO_to_and_from_the_TERASIC_SPI_3WIRE_0 : INOUT STD_LOGIC;

              -- the_altpll_sdram
                 signal areset_to_the_altpll_sdram : IN STD_LOGIC;
                 signal locked_from_the_altpll_sdram : OUT STD_LOGIC;
                 signal phasedone_from_the_altpll_sdram : OUT STD_LOGIC;

              -- the_pio_bot_endcalc
                 signal in_port_to_the_pio_bot_endcalc : IN STD_LOGIC;

              -- the_pio_bot_legselect
                 signal out_port_from_the_pio_bot_legselect : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);

              -- the_pio_bot_reset
                 signal out_port_from_the_pio_bot_reset : OUT STD_LOGIC;

              -- the_pio_bot_updateflag
                 signal out_port_from_the_pio_bot_updateflag : OUT STD_LOGIC;

              -- the_pio_bot_wrcoord
                 signal out_port_from_the_pio_bot_wrcoord : OUT STD_LOGIC;

              -- the_pio_bot_x
                 signal out_port_from_the_pio_bot_x : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- the_pio_bot_y
                 signal out_port_from_the_pio_bot_y : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- the_pio_bot_z
                 signal out_port_from_the_pio_bot_z : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- the_pio_led
                 signal out_port_from_the_pio_led : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_sdram
                 signal zs_addr_from_the_sdram : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal zs_ba_from_the_sdram : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal zs_cas_n_from_the_sdram : OUT STD_LOGIC;
                 signal zs_cke_from_the_sdram : OUT STD_LOGIC;
                 signal zs_cs_n_from_the_sdram : OUT STD_LOGIC;
                 signal zs_dq_to_and_from_the_sdram : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal zs_dqm_from_the_sdram : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal zs_ras_n_from_the_sdram : OUT STD_LOGIC;
                 signal zs_we_n_from_the_sdram : OUT STD_LOGIC;

              -- the_spi
                 signal MISO_to_the_spi : IN STD_LOGIC;
                 signal MOSI_from_the_spi : OUT STD_LOGIC;
                 signal SCLK_from_the_spi : OUT STD_LOGIC;
                 signal SS_n_from_the_spi : OUT STD_LOGIC;

              -- the_uart
                 signal rxd_to_the_uart : IN STD_LOGIC;
                 signal txd_from_the_uart : OUT STD_LOGIC
              );
end entity Teste_SOPC;


architecture europa of Teste_SOPC is
component I2C_Master_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal I2C_Master_avalon_slave_irq : IN STD_LOGIC;
                    signal I2C_Master_avalon_slave_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal I2C_Master_avalon_slave_waitrequest_n : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal I2C_Master_avalon_slave_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal I2C_Master_avalon_slave_chipselect : OUT STD_LOGIC;
                    signal I2C_Master_avalon_slave_irq_from_sa : OUT STD_LOGIC;
                    signal I2C_Master_avalon_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal I2C_Master_avalon_slave_reset : OUT STD_LOGIC;
                    signal I2C_Master_avalon_slave_waitrequest_n_from_sa : OUT STD_LOGIC;
                    signal I2C_Master_avalon_slave_write : OUT STD_LOGIC;
                    signal I2C_Master_avalon_slave_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_data_master_granted_I2C_Master_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_I2C_Master_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_I2C_Master_avalon_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_I2C_Master_avalon_slave : OUT STD_LOGIC;
                    signal d1_I2C_Master_avalon_slave_end_xfer : OUT STD_LOGIC
                 );
end component I2C_Master_avalon_slave_arbitrator;

component I2C_Master is 
           port (
                 -- inputs:
                    signal wb_adr_i : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal wb_clk_i : IN STD_LOGIC;
                    signal wb_dat_i : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal wb_rst_i : IN STD_LOGIC;
                    signal wb_stb_i : IN STD_LOGIC;
                    signal wb_we_i : IN STD_LOGIC;

                 -- outputs:
                    signal scl_pad_io : INOUT STD_LOGIC;
                    signal sda_pad_io : INOUT STD_LOGIC;
                    signal wb_ack_o : OUT STD_LOGIC;
                    signal wb_dat_o : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal wb_inta_o : OUT STD_LOGIC
                 );
end component I2C_Master;

component TERASIC_SPI_3WIRE_0_slave_arbitrator is 
           port (
                 -- inputs:
                    signal TERASIC_SPI_3WIRE_0_slave_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal TERASIC_SPI_3WIRE_0_slave_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal TERASIC_SPI_3WIRE_0_slave_chipselect : OUT STD_LOGIC;
                    signal TERASIC_SPI_3WIRE_0_slave_read : OUT STD_LOGIC;
                    signal TERASIC_SPI_3WIRE_0_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal TERASIC_SPI_3WIRE_0_slave_reset_n : OUT STD_LOGIC;
                    signal TERASIC_SPI_3WIRE_0_slave_write : OUT STD_LOGIC;
                    signal TERASIC_SPI_3WIRE_0_slave_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC;
                    signal d1_TERASIC_SPI_3WIRE_0_slave_end_xfer : OUT STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : OUT STD_LOGIC
                 );
end component TERASIC_SPI_3WIRE_0_slave_arbitrator;

component TERASIC_SPI_3WIRE_0 is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal s_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal s_chipselect : IN STD_LOGIC;
                    signal s_read : IN STD_LOGIC;
                    signal s_write : IN STD_LOGIC;
                    signal s_writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal SPI_CS_n : OUT STD_LOGIC;
                    signal SPI_SCLK : OUT STD_LOGIC;
                    signal SPI_SDIO : INOUT STD_LOGIC;
                    signal s_readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component TERASIC_SPI_3WIRE_0;

component Teste_SOPC_clock_0_in_arbitrator is 
           port (
                 -- inputs:
                    signal Teste_SOPC_clock_0_in_endofpacket : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_0_in_waitrequest : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal Teste_SOPC_clock_0_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Teste_SOPC_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal Teste_SOPC_clock_0_in_read : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_0_in_reset_n : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_in_write : OUT STD_LOGIC;
                    signal cpu_instruction_master_granted_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_Teste_SOPC_clock_0_in : OUT STD_LOGIC;
                    signal d1_Teste_SOPC_clock_0_in_end_xfer : OUT STD_LOGIC
                 );
end component Teste_SOPC_clock_0_in_arbitrator;

component Teste_SOPC_clock_0_out_arbitrator is 
           port (
                 -- inputs:
                    signal Teste_SOPC_clock_0_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Teste_SOPC_clock_0_out_granted_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_qualified_request_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_read : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_requests_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_write : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_sdram_s1_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sdram_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal sdram_s1_waitrequest_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal Teste_SOPC_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_0_out_reset_n : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_waitrequest : OUT STD_LOGIC
                 );
end component Teste_SOPC_clock_0_out_arbitrator;

component Teste_SOPC_clock_0 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component Teste_SOPC_clock_0;

component Teste_SOPC_clock_1_in_arbitrator is 
           port (
                 -- inputs:
                    signal Teste_SOPC_clock_1_in_endofpacket : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_1_in_waitrequest : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_data_master_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal Teste_SOPC_clock_1_in_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Teste_SOPC_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal Teste_SOPC_clock_1_in_read : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_1_in_reset_n : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_in_write : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_data_master_byteenable_Teste_SOPC_clock_1_in : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_data_master_granted_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                    signal cpu_data_master_requests_Teste_SOPC_clock_1_in : OUT STD_LOGIC;
                    signal d1_Teste_SOPC_clock_1_in_end_xfer : OUT STD_LOGIC
                 );
end component Teste_SOPC_clock_1_in_arbitrator;

component Teste_SOPC_clock_1_out_arbitrator is 
           port (
                 -- inputs:
                    signal Teste_SOPC_clock_1_out_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Teste_SOPC_clock_1_out_granted_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_qualified_request_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_read : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_requests_sdram_s1 : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_write : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_sdram_s1_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sdram_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal sdram_s1_waitrequest_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal Teste_SOPC_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_1_out_reset_n : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_waitrequest : OUT STD_LOGIC
                 );
end component Teste_SOPC_clock_1_out_arbitrator;

component Teste_SOPC_clock_1 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component Teste_SOPC_clock_1;

component altpll_sdram_pll_slave_arbitrator is 
           port (
                 -- inputs:
                    signal altpll_sdram_pll_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal altpll_sdram_pll_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal altpll_sdram_pll_slave_read : OUT STD_LOGIC;
                    signal altpll_sdram_pll_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal altpll_sdram_pll_slave_reset : OUT STD_LOGIC;
                    signal altpll_sdram_pll_slave_write : OUT STD_LOGIC;
                    signal altpll_sdram_pll_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_granted_altpll_sdram_pll_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_altpll_sdram_pll_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_altpll_sdram_pll_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_altpll_sdram_pll_slave : OUT STD_LOGIC;
                    signal d1_altpll_sdram_pll_slave_end_xfer : OUT STD_LOGIC
                 );
end component altpll_sdram_pll_slave_arbitrator;

component altpll_sdram is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal areset : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal c0 : OUT STD_LOGIC;
                    signal locked : OUT STD_LOGIC;
                    signal phasedone : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component altpll_sdram;

component cpu_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_debugaccess : IN STD_LOGIC;
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_write : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
                 );
end component cpu_jtag_debug_module_arbitrator;

component cpu_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal I2C_Master_avalon_slave_irq_from_sa : IN STD_LOGIC;
                    signal I2C_Master_avalon_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal I2C_Master_avalon_slave_waitrequest_n_from_sa : IN STD_LOGIC;
                    signal TERASIC_SPI_3WIRE_0_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal Teste_SOPC_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal altpll_sdram_pll_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_byteenable_Teste_SOPC_clock_1_in : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_data_master_granted_I2C_Master_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                    signal cpu_data_master_granted_altpll_sdram_pll_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_endcalc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_legselect_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_reset_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_updateflag_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_x_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_y_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_bot_z_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_pio_led_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_data_master_granted_timer_sys_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_I2C_Master_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_altpll_sdram_pll_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_endcalc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_legselect_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_reset_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_updateflag_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_x_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_y_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_z_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_led_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_timer_sys_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_I2C_Master_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_altpll_sdram_pll_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_endcalc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_legselect_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_reset_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_updateflag_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_x_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_y_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_z_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_led_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_timer_sys_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_I2C_Master_avalon_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_Teste_SOPC_clock_1_in : IN STD_LOGIC;
                    signal cpu_data_master_requests_altpll_sdram_pll_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_endcalc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_legselect_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_reset_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_updateflag_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_wrcoord_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_x_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_y_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_z_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_pio_led_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_spi_spi_control_port : IN STD_LOGIC;
                    signal cpu_data_master_requests_timer_sys_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_uart_s1 : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_I2C_Master_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal d1_TERASIC_SPI_3WIRE_0_slave_end_xfer : IN STD_LOGIC;
                    signal d1_Teste_SOPC_clock_1_in_end_xfer : IN STD_LOGIC;
                    signal d1_altpll_sdram_pll_slave_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_endcalc_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_legselect_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_reset_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_updateflag_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_wrcoord_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_x_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_y_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_bot_z_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pio_led_s1_end_xfer : IN STD_LOGIC;
                    signal d1_spi_spi_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_timer_sys_s1_end_xfer : IN STD_LOGIC;
                    signal d1_uart_s1_end_xfer : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal pio_bot_endcalc_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_legselect_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_reset_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_updateflag_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_wrcoord_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_x_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_y_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_z_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_led_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal spi_spi_control_port_irq_from_sa : IN STD_LOGIC;
                    signal spi_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal timer_sys_s1_irq_from_sa : IN STD_LOGIC;
                    signal timer_sys_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_s1_irq_from_sa : IN STD_LOGIC;
                    signal uart_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_data_master_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                    signal cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_data_master_arbitrator;

component cpu_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal Teste_SOPC_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal cpu_instruction_master_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_granted_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                    signal cpu_instruction_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_Teste_SOPC_clock_0_in : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_Teste_SOPC_clock_0_in_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_instruction_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_instruction_master_arbitrator;

component cpu is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d_irq : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_waitrequest : IN STD_LOGIC;
                    signal i_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_waitrequest : IN STD_LOGIC;
                    signal jtag_debug_module_address : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal jtag_debug_module_begintransfer : IN STD_LOGIC;
                    signal jtag_debug_module_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal jtag_debug_module_debugaccess : IN STD_LOGIC;
                    signal jtag_debug_module_select : IN STD_LOGIC;
                    signal jtag_debug_module_write : IN STD_LOGIC;
                    signal jtag_debug_module_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component cpu;

component jtag_uart_avalon_jtag_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal d1_jtag_uart_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_address : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jtag_uart_avalon_jtag_slave_arbitrator;

component jtag_uart is 
           port (
                 -- inputs:
                    signal av_address : IN STD_LOGIC;
                    signal av_chipselect : IN STD_LOGIC;
                    signal av_read_n : IN STD_LOGIC;
                    signal av_write_n : IN STD_LOGIC;
                    signal av_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal rst_n : IN STD_LOGIC;

                 -- outputs:
                    signal av_irq : OUT STD_LOGIC;
                    signal av_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal av_waitrequest : OUT STD_LOGIC;
                    signal dataavailable : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component jtag_uart;

component pio_bot_endcalc_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal pio_bot_endcalc_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_endcalc_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_endcalc_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_endcalc_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_endcalc_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_endcalc_s1_reset_n : OUT STD_LOGIC
                 );
end component pio_bot_endcalc_s1_arbitrator;

component pio_bot_endcalc is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_endcalc;

component pio_bot_legselect_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_legselect_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_legselect_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_legselect_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_legselect_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_legselect_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_legselect_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_legselect_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_legselect_s1_chipselect : OUT STD_LOGIC;
                    signal pio_bot_legselect_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_legselect_s1_reset_n : OUT STD_LOGIC;
                    signal pio_bot_legselect_s1_write_n : OUT STD_LOGIC;
                    signal pio_bot_legselect_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_legselect_s1_arbitrator;

component pio_bot_legselect is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_legselect;

component pio_bot_reset_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_reset_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_reset_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_reset_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_reset_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_reset_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_reset_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_reset_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_reset_s1_chipselect : OUT STD_LOGIC;
                    signal pio_bot_reset_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_reset_s1_reset_n : OUT STD_LOGIC;
                    signal pio_bot_reset_s1_write_n : OUT STD_LOGIC;
                    signal pio_bot_reset_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_reset_s1_arbitrator;

component pio_bot_reset is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_reset;

component pio_bot_updateflag_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_updateflag_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_updateflag_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_updateflag_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_updateflag_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_updateflag_s1_chipselect : OUT STD_LOGIC;
                    signal pio_bot_updateflag_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_updateflag_s1_reset_n : OUT STD_LOGIC;
                    signal pio_bot_updateflag_s1_write_n : OUT STD_LOGIC;
                    signal pio_bot_updateflag_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_updateflag_s1_arbitrator;

component pio_bot_updateflag is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_updateflag;

component pio_bot_wrcoord_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_wrcoord_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_wrcoord_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_wrcoord_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_wrcoord_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_wrcoord_s1_chipselect : OUT STD_LOGIC;
                    signal pio_bot_wrcoord_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_wrcoord_s1_reset_n : OUT STD_LOGIC;
                    signal pio_bot_wrcoord_s1_write_n : OUT STD_LOGIC;
                    signal pio_bot_wrcoord_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_wrcoord_s1_arbitrator;

component pio_bot_wrcoord is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_wrcoord;

component pio_bot_x_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_x_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_x_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_x_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_x_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_x_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_x_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_x_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_x_s1_chipselect : OUT STD_LOGIC;
                    signal pio_bot_x_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_x_s1_reset_n : OUT STD_LOGIC;
                    signal pio_bot_x_s1_write_n : OUT STD_LOGIC;
                    signal pio_bot_x_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_x_s1_arbitrator;

component pio_bot_x is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_x;

component pio_bot_y_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_y_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_y_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_y_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_y_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_y_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_y_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_y_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_y_s1_chipselect : OUT STD_LOGIC;
                    signal pio_bot_y_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_y_s1_reset_n : OUT STD_LOGIC;
                    signal pio_bot_y_s1_write_n : OUT STD_LOGIC;
                    signal pio_bot_y_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_y_s1_arbitrator;

component pio_bot_y is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_y;

component pio_bot_z_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_z_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_bot_z_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_bot_z_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_bot_z_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_bot_z_s1 : OUT STD_LOGIC;
                    signal d1_pio_bot_z_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_bot_z_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_bot_z_s1_chipselect : OUT STD_LOGIC;
                    signal pio_bot_z_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_bot_z_s1_reset_n : OUT STD_LOGIC;
                    signal pio_bot_z_s1_write_n : OUT STD_LOGIC;
                    signal pio_bot_z_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_z_s1_arbitrator;

component pio_bot_z is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_bot_z;

component pio_led_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_led_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_pio_led_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_pio_led_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_pio_led_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_pio_led_s1 : OUT STD_LOGIC;
                    signal d1_pio_led_s1_end_xfer : OUT STD_LOGIC;
                    signal pio_led_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pio_led_s1_chipselect : OUT STD_LOGIC;
                    signal pio_led_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pio_led_s1_reset_n : OUT STD_LOGIC;
                    signal pio_led_s1_write_n : OUT STD_LOGIC;
                    signal pio_led_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_led_s1_arbitrator;

component pio_led is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pio_led;

component sdram_s1_arbitrator is 
           port (
                 -- inputs:
                    signal Teste_SOPC_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Teste_SOPC_clock_0_out_read : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_write : IN STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal Teste_SOPC_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal Teste_SOPC_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Teste_SOPC_clock_1_out_read : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_write : IN STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sdram_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal sdram_s1_readdatavalid : IN STD_LOGIC;
                    signal sdram_s1_waitrequest : IN STD_LOGIC;

                 -- outputs:
                    signal Teste_SOPC_clock_0_out_granted_sdram_s1 : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_qualified_request_sdram_s1 : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_0_out_requests_sdram_s1 : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_granted_sdram_s1 : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_qualified_request_sdram_s1 : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register : OUT STD_LOGIC;
                    signal Teste_SOPC_clock_1_out_requests_sdram_s1 : OUT STD_LOGIC;
                    signal d1_sdram_s1_end_xfer : OUT STD_LOGIC;
                    signal sdram_s1_address : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal sdram_s1_byteenable_n : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal sdram_s1_chipselect : OUT STD_LOGIC;
                    signal sdram_s1_read_n : OUT STD_LOGIC;
                    signal sdram_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal sdram_s1_reset_n : OUT STD_LOGIC;
                    signal sdram_s1_waitrequest_from_sa : OUT STD_LOGIC;
                    signal sdram_s1_write_n : OUT STD_LOGIC;
                    signal sdram_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component sdram_s1_arbitrator;

component sdram is 
           port (
                 -- inputs:
                    signal az_addr : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal az_be_n : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal az_cs : IN STD_LOGIC;
                    signal az_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal az_rd_n : IN STD_LOGIC;
                    signal az_wr_n : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal za_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal za_valid : OUT STD_LOGIC;
                    signal za_waitrequest : OUT STD_LOGIC;
                    signal zs_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal zs_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal zs_cas_n : OUT STD_LOGIC;
                    signal zs_cke : OUT STD_LOGIC;
                    signal zs_cs_n : OUT STD_LOGIC;
                    signal zs_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal zs_dqm : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal zs_ras_n : OUT STD_LOGIC;
                    signal zs_we_n : OUT STD_LOGIC
                 );
end component sdram;

component spi_spi_control_port_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal spi_spi_control_port_dataavailable : IN STD_LOGIC;
                    signal spi_spi_control_port_endofpacket : IN STD_LOGIC;
                    signal spi_spi_control_port_irq : IN STD_LOGIC;
                    signal spi_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal spi_spi_control_port_readyfordata : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_spi_spi_control_port : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_spi_spi_control_port : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_spi_spi_control_port : OUT STD_LOGIC;
                    signal cpu_data_master_requests_spi_spi_control_port : OUT STD_LOGIC;
                    signal d1_spi_spi_control_port_end_xfer : OUT STD_LOGIC;
                    signal spi_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal spi_spi_control_port_chipselect : OUT STD_LOGIC;
                    signal spi_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                    signal spi_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                    signal spi_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                    signal spi_spi_control_port_read_n : OUT STD_LOGIC;
                    signal spi_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal spi_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                    signal spi_spi_control_port_reset_n : OUT STD_LOGIC;
                    signal spi_spi_control_port_write_n : OUT STD_LOGIC;
                    signal spi_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component spi_spi_control_port_arbitrator;

component spi is 
           port (
                 -- inputs:
                    signal MISO : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_from_cpu : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mem_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal spi_select : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;

                 -- outputs:
                    signal MOSI : OUT STD_LOGIC;
                    signal SCLK : OUT STD_LOGIC;
                    signal SS_n : OUT STD_LOGIC;
                    signal data_to_cpu : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal dataavailable : OUT STD_LOGIC;
                    signal endofpacket : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component spi;

component timer_sys_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal timer_sys_s1_irq : IN STD_LOGIC;
                    signal timer_sys_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_granted_timer_sys_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_timer_sys_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_timer_sys_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_timer_sys_s1 : OUT STD_LOGIC;
                    signal d1_timer_sys_s1_end_xfer : OUT STD_LOGIC;
                    signal timer_sys_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal timer_sys_s1_chipselect : OUT STD_LOGIC;
                    signal timer_sys_s1_irq_from_sa : OUT STD_LOGIC;
                    signal timer_sys_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal timer_sys_s1_reset_n : OUT STD_LOGIC;
                    signal timer_sys_s1_write_n : OUT STD_LOGIC;
                    signal timer_sys_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_sys_s1_arbitrator;

component timer_sys is 
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
end component timer_sys;

component uart_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal uart_s1_dataavailable : IN STD_LOGIC;
                    signal uart_s1_irq : IN STD_LOGIC;
                    signal uart_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal uart_s1_readyfordata : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_uart_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_uart_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_uart_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_uart_s1 : OUT STD_LOGIC;
                    signal d1_uart_s1_end_xfer : OUT STD_LOGIC;
                    signal uart_s1_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal uart_s1_begintransfer : OUT STD_LOGIC;
                    signal uart_s1_chipselect : OUT STD_LOGIC;
                    signal uart_s1_dataavailable_from_sa : OUT STD_LOGIC;
                    signal uart_s1_irq_from_sa : OUT STD_LOGIC;
                    signal uart_s1_read_n : OUT STD_LOGIC;
                    signal uart_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal uart_s1_readyfordata_from_sa : OUT STD_LOGIC;
                    signal uart_s1_reset_n : OUT STD_LOGIC;
                    signal uart_s1_write_n : OUT STD_LOGIC;
                    signal uart_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component uart_s1_arbitrator;

component uart is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal begintransfer : IN STD_LOGIC;
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal rxd : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal dataavailable : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal readyfordata : OUT STD_LOGIC;
                    signal txd : OUT STD_LOGIC
                 );
end component uart;

component Teste_SOPC_reset_clk_100_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component Teste_SOPC_reset_clk_100_domain_synch_module;

component Teste_SOPC_reset_altpll_sdram_c0_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component Teste_SOPC_reset_altpll_sdram_c0_domain_synch_module;

                signal I2C_Master_avalon_slave_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal I2C_Master_avalon_slave_chipselect :  STD_LOGIC;
                signal I2C_Master_avalon_slave_irq :  STD_LOGIC;
                signal I2C_Master_avalon_slave_irq_from_sa :  STD_LOGIC;
                signal I2C_Master_avalon_slave_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal I2C_Master_avalon_slave_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal I2C_Master_avalon_slave_reset :  STD_LOGIC;
                signal I2C_Master_avalon_slave_waitrequest_n :  STD_LOGIC;
                signal I2C_Master_avalon_slave_waitrequest_n_from_sa :  STD_LOGIC;
                signal I2C_Master_avalon_slave_write :  STD_LOGIC;
                signal I2C_Master_avalon_slave_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal TERASIC_SPI_3WIRE_0_slave_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal TERASIC_SPI_3WIRE_0_slave_chipselect :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_read :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal TERASIC_SPI_3WIRE_0_slave_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal TERASIC_SPI_3WIRE_0_slave_reset_n :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_write :  STD_LOGIC;
                signal TERASIC_SPI_3WIRE_0_slave_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_endofpacket :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_nativeaddress :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_read :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_0_in_reset_n :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_waitrequest :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_write :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_endofpacket :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_granted_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_qualified_request_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_read :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_requests_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_reset_n :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_waitrequest :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_write :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_endofpacket :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_nativeaddress :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_read :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_reset_n :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_waitrequest :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_write :  STD_LOGIC;
                signal Teste_SOPC_clock_1_in_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_endofpacket :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_granted_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_qualified_request_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_read :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_1_out_requests_sdram_s1 :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_reset_n :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_waitrequest :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_write :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal altpll_sdram_c0_reset_n :  STD_LOGIC;
                signal altpll_sdram_pll_slave_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altpll_sdram_pll_slave_read :  STD_LOGIC;
                signal altpll_sdram_pll_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_sdram_pll_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_sdram_pll_slave_reset :  STD_LOGIC;
                signal altpll_sdram_pll_slave_write :  STD_LOGIC;
                signal altpll_sdram_pll_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clk_100_reset_n :  STD_LOGIC;
                signal cpu_data_master_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_data_master_byteenable_Teste_SOPC_clock_1_in :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_data_master_dbs_write_16 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_data_master_debugaccess :  STD_LOGIC;
                signal cpu_data_master_granted_I2C_Master_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal cpu_data_master_granted_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal cpu_data_master_granted_altpll_sdram_pll_slave :  STD_LOGIC;
                signal cpu_data_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_legselect_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_reset_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_x_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_y_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_bot_z_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_pio_led_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_spi_spi_control_port :  STD_LOGIC;
                signal cpu_data_master_granted_timer_sys_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal cpu_data_master_qualified_request_I2C_Master_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal cpu_data_master_qualified_request_altpll_sdram_pll_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_legselect_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_reset_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_x_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_y_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_bot_z_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_pio_led_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_spi_spi_control_port :  STD_LOGIC;
                signal cpu_data_master_qualified_request_timer_sys_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_read :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_I2C_Master_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_altpll_sdram_pll_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_legselect_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_reset_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_x_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_y_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_bot_z_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_pio_led_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_spi_spi_control_port :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_timer_sys_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_data_master_requests_I2C_Master_avalon_slave :  STD_LOGIC;
                signal cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal cpu_data_master_requests_Teste_SOPC_clock_1_in :  STD_LOGIC;
                signal cpu_data_master_requests_altpll_sdram_pll_slave :  STD_LOGIC;
                signal cpu_data_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_endcalc_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_legselect_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_reset_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_updateflag_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_wrcoord_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_x_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_y_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_bot_z_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_pio_led_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_spi_spi_control_port :  STD_LOGIC;
                signal cpu_data_master_requests_timer_sys_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_uart_s1 :  STD_LOGIC;
                signal cpu_data_master_waitrequest :  STD_LOGIC;
                signal cpu_data_master_write :  STD_LOGIC;
                signal cpu_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_instruction_master_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal cpu_instruction_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_instruction_master_granted_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal cpu_instruction_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_read :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_instruction_master_requests_Teste_SOPC_clock_0_in :  STD_LOGIC;
                signal cpu_instruction_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal cpu_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_jtag_debug_module_chipselect :  STD_LOGIC;
                signal cpu_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal cpu_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal cpu_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal cpu_jtag_debug_module_write :  STD_LOGIC;
                signal cpu_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal d1_I2C_Master_avalon_slave_end_xfer :  STD_LOGIC;
                signal d1_TERASIC_SPI_3WIRE_0_slave_end_xfer :  STD_LOGIC;
                signal d1_Teste_SOPC_clock_0_in_end_xfer :  STD_LOGIC;
                signal d1_Teste_SOPC_clock_1_in_end_xfer :  STD_LOGIC;
                signal d1_altpll_sdram_pll_slave_end_xfer :  STD_LOGIC;
                signal d1_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_endcalc_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_legselect_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_reset_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_updateflag_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_wrcoord_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_x_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_y_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_bot_z_s1_end_xfer :  STD_LOGIC;
                signal d1_pio_led_s1_end_xfer :  STD_LOGIC;
                signal d1_sdram_s1_end_xfer :  STD_LOGIC;
                signal d1_spi_spi_control_port_end_xfer :  STD_LOGIC;
                signal d1_timer_sys_s1_end_xfer :  STD_LOGIC;
                signal d1_uart_s1_end_xfer :  STD_LOGIC;
                signal internal_MOSI_from_the_spi :  STD_LOGIC;
                signal internal_SCLK_from_the_spi :  STD_LOGIC;
                signal internal_SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0 :  STD_LOGIC;
                signal internal_SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0 :  STD_LOGIC;
                signal internal_SS_n_from_the_spi :  STD_LOGIC;
                signal internal_altpll_sdram_c0 :  STD_LOGIC;
                signal internal_locked_from_the_altpll_sdram :  STD_LOGIC;
                signal internal_out_port_from_the_pio_bot_legselect :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal internal_out_port_from_the_pio_bot_reset :  STD_LOGIC;
                signal internal_out_port_from_the_pio_bot_updateflag :  STD_LOGIC;
                signal internal_out_port_from_the_pio_bot_wrcoord :  STD_LOGIC;
                signal internal_out_port_from_the_pio_bot_x :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_out_port_from_the_pio_bot_y :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_out_port_from_the_pio_bot_z :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_out_port_from_the_pio_led :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_phasedone_from_the_altpll_sdram :  STD_LOGIC;
                signal internal_txd_from_the_uart :  STD_LOGIC;
                signal internal_zs_addr_from_the_sdram :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_zs_ba_from_the_sdram :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_zs_cas_n_from_the_sdram :  STD_LOGIC;
                signal internal_zs_cke_from_the_sdram :  STD_LOGIC;
                signal internal_zs_cs_n_from_the_sdram :  STD_LOGIC;
                signal internal_zs_dqm_from_the_sdram :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_zs_ras_n_from_the_sdram :  STD_LOGIC;
                signal internal_zs_we_n_from_the_sdram :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_address :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_chipselect :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_irq :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_read_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_readyfordata :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_reset_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waitrequest :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_write_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal module_input6 :  STD_LOGIC;
                signal module_input7 :  STD_LOGIC;
                signal out_clk_altpll_sdram_c0 :  STD_LOGIC;
                signal pio_bot_endcalc_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_endcalc_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_endcalc_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_endcalc_s1_reset_n :  STD_LOGIC;
                signal pio_bot_legselect_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_legselect_s1_chipselect :  STD_LOGIC;
                signal pio_bot_legselect_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_legselect_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_legselect_s1_reset_n :  STD_LOGIC;
                signal pio_bot_legselect_s1_write_n :  STD_LOGIC;
                signal pio_bot_legselect_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_reset_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_reset_s1_chipselect :  STD_LOGIC;
                signal pio_bot_reset_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_reset_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_reset_s1_reset_n :  STD_LOGIC;
                signal pio_bot_reset_s1_write_n :  STD_LOGIC;
                signal pio_bot_reset_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_updateflag_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_updateflag_s1_chipselect :  STD_LOGIC;
                signal pio_bot_updateflag_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_updateflag_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_updateflag_s1_reset_n :  STD_LOGIC;
                signal pio_bot_updateflag_s1_write_n :  STD_LOGIC;
                signal pio_bot_updateflag_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_wrcoord_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_wrcoord_s1_chipselect :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_wrcoord_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_wrcoord_s1_reset_n :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_write_n :  STD_LOGIC;
                signal pio_bot_wrcoord_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_x_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_x_s1_chipselect :  STD_LOGIC;
                signal pio_bot_x_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_x_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_x_s1_reset_n :  STD_LOGIC;
                signal pio_bot_x_s1_write_n :  STD_LOGIC;
                signal pio_bot_x_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_y_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_y_s1_chipselect :  STD_LOGIC;
                signal pio_bot_y_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_y_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_y_s1_reset_n :  STD_LOGIC;
                signal pio_bot_y_s1_write_n :  STD_LOGIC;
                signal pio_bot_y_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_z_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_bot_z_s1_chipselect :  STD_LOGIC;
                signal pio_bot_z_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_z_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_bot_z_s1_reset_n :  STD_LOGIC;
                signal pio_bot_z_s1_write_n :  STD_LOGIC;
                signal pio_bot_z_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_led_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pio_led_s1_chipselect :  STD_LOGIC;
                signal pio_led_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_led_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pio_led_s1_reset_n :  STD_LOGIC;
                signal pio_led_s1_write_n :  STD_LOGIC;
                signal pio_led_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave :  STD_LOGIC;
                signal reset_n_sources :  STD_LOGIC;
                signal sdram_s1_address :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal sdram_s1_byteenable_n :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_s1_chipselect :  STD_LOGIC;
                signal sdram_s1_read_n :  STD_LOGIC;
                signal sdram_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal sdram_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal sdram_s1_readdatavalid :  STD_LOGIC;
                signal sdram_s1_reset_n :  STD_LOGIC;
                signal sdram_s1_waitrequest :  STD_LOGIC;
                signal sdram_s1_waitrequest_from_sa :  STD_LOGIC;
                signal sdram_s1_write_n :  STD_LOGIC;
                signal sdram_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal spi_spi_control_port_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal spi_spi_control_port_chipselect :  STD_LOGIC;
                signal spi_spi_control_port_dataavailable :  STD_LOGIC;
                signal spi_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal spi_spi_control_port_endofpacket :  STD_LOGIC;
                signal spi_spi_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal spi_spi_control_port_irq :  STD_LOGIC;
                signal spi_spi_control_port_irq_from_sa :  STD_LOGIC;
                signal spi_spi_control_port_read_n :  STD_LOGIC;
                signal spi_spi_control_port_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal spi_spi_control_port_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal spi_spi_control_port_readyfordata :  STD_LOGIC;
                signal spi_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal spi_spi_control_port_reset_n :  STD_LOGIC;
                signal spi_spi_control_port_write_n :  STD_LOGIC;
                signal spi_spi_control_port_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_sys_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_sys_s1_chipselect :  STD_LOGIC;
                signal timer_sys_s1_irq :  STD_LOGIC;
                signal timer_sys_s1_irq_from_sa :  STD_LOGIC;
                signal timer_sys_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_sys_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_sys_s1_reset_n :  STD_LOGIC;
                signal timer_sys_s1_write_n :  STD_LOGIC;
                signal timer_sys_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_s1_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal uart_s1_begintransfer :  STD_LOGIC;
                signal uart_s1_chipselect :  STD_LOGIC;
                signal uart_s1_dataavailable :  STD_LOGIC;
                signal uart_s1_dataavailable_from_sa :  STD_LOGIC;
                signal uart_s1_irq :  STD_LOGIC;
                signal uart_s1_irq_from_sa :  STD_LOGIC;
                signal uart_s1_read_n :  STD_LOGIC;
                signal uart_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal uart_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal uart_s1_readyfordata :  STD_LOGIC;
                signal uart_s1_readyfordata_from_sa :  STD_LOGIC;
                signal uart_s1_reset_n :  STD_LOGIC;
                signal uart_s1_write_n :  STD_LOGIC;
                signal uart_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --the_I2C_Master_avalon_slave, which is an e_instance
  the_I2C_Master_avalon_slave : I2C_Master_avalon_slave_arbitrator
    port map(
      I2C_Master_avalon_slave_address => I2C_Master_avalon_slave_address,
      I2C_Master_avalon_slave_chipselect => I2C_Master_avalon_slave_chipselect,
      I2C_Master_avalon_slave_irq_from_sa => I2C_Master_avalon_slave_irq_from_sa,
      I2C_Master_avalon_slave_readdata_from_sa => I2C_Master_avalon_slave_readdata_from_sa,
      I2C_Master_avalon_slave_reset => I2C_Master_avalon_slave_reset,
      I2C_Master_avalon_slave_waitrequest_n_from_sa => I2C_Master_avalon_slave_waitrequest_n_from_sa,
      I2C_Master_avalon_slave_write => I2C_Master_avalon_slave_write,
      I2C_Master_avalon_slave_writedata => I2C_Master_avalon_slave_writedata,
      cpu_data_master_granted_I2C_Master_avalon_slave => cpu_data_master_granted_I2C_Master_avalon_slave,
      cpu_data_master_qualified_request_I2C_Master_avalon_slave => cpu_data_master_qualified_request_I2C_Master_avalon_slave,
      cpu_data_master_read_data_valid_I2C_Master_avalon_slave => cpu_data_master_read_data_valid_I2C_Master_avalon_slave,
      cpu_data_master_requests_I2C_Master_avalon_slave => cpu_data_master_requests_I2C_Master_avalon_slave,
      d1_I2C_Master_avalon_slave_end_xfer => d1_I2C_Master_avalon_slave_end_xfer,
      I2C_Master_avalon_slave_irq => I2C_Master_avalon_slave_irq,
      I2C_Master_avalon_slave_readdata => I2C_Master_avalon_slave_readdata,
      I2C_Master_avalon_slave_waitrequest_n => I2C_Master_avalon_slave_waitrequest_n,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_100_reset_n
    );


  --the_I2C_Master, which is an e_ptf_instance
  the_I2C_Master : I2C_Master
    port map(
      scl_pad_io => scl_pad_io_to_and_from_the_I2C_Master,
      sda_pad_io => sda_pad_io_to_and_from_the_I2C_Master,
      wb_ack_o => I2C_Master_avalon_slave_waitrequest_n,
      wb_dat_o => I2C_Master_avalon_slave_readdata,
      wb_inta_o => I2C_Master_avalon_slave_irq,
      wb_adr_i => I2C_Master_avalon_slave_address,
      wb_clk_i => clk_100,
      wb_dat_i => I2C_Master_avalon_slave_writedata,
      wb_rst_i => I2C_Master_avalon_slave_reset,
      wb_stb_i => I2C_Master_avalon_slave_chipselect,
      wb_we_i => I2C_Master_avalon_slave_write
    );


  --the_TERASIC_SPI_3WIRE_0_slave, which is an e_instance
  the_TERASIC_SPI_3WIRE_0_slave : TERASIC_SPI_3WIRE_0_slave_arbitrator
    port map(
      TERASIC_SPI_3WIRE_0_slave_address => TERASIC_SPI_3WIRE_0_slave_address,
      TERASIC_SPI_3WIRE_0_slave_chipselect => TERASIC_SPI_3WIRE_0_slave_chipselect,
      TERASIC_SPI_3WIRE_0_slave_read => TERASIC_SPI_3WIRE_0_slave_read,
      TERASIC_SPI_3WIRE_0_slave_readdata_from_sa => TERASIC_SPI_3WIRE_0_slave_readdata_from_sa,
      TERASIC_SPI_3WIRE_0_slave_reset_n => TERASIC_SPI_3WIRE_0_slave_reset_n,
      TERASIC_SPI_3WIRE_0_slave_write => TERASIC_SPI_3WIRE_0_slave_write,
      TERASIC_SPI_3WIRE_0_slave_writedata => TERASIC_SPI_3WIRE_0_slave_writedata,
      cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave,
      cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave,
      cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave,
      cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave,
      d1_TERASIC_SPI_3WIRE_0_slave_end_xfer => d1_TERASIC_SPI_3WIRE_0_slave_end_xfer,
      registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave => registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave,
      TERASIC_SPI_3WIRE_0_slave_readdata => TERASIC_SPI_3WIRE_0_slave_readdata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_100_reset_n
    );


  --the_TERASIC_SPI_3WIRE_0, which is an e_ptf_instance
  the_TERASIC_SPI_3WIRE_0 : TERASIC_SPI_3WIRE_0
    port map(
      SPI_CS_n => internal_SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0,
      SPI_SCLK => internal_SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0,
      SPI_SDIO => SPI_SDIO_to_and_from_the_TERASIC_SPI_3WIRE_0,
      s_readdata => TERASIC_SPI_3WIRE_0_slave_readdata,
      clk => clk_100,
      reset_n => TERASIC_SPI_3WIRE_0_slave_reset_n,
      s_address => TERASIC_SPI_3WIRE_0_slave_address,
      s_chipselect => TERASIC_SPI_3WIRE_0_slave_chipselect,
      s_read => TERASIC_SPI_3WIRE_0_slave_read,
      s_write => TERASIC_SPI_3WIRE_0_slave_write,
      s_writedata => TERASIC_SPI_3WIRE_0_slave_writedata
    );


  --the_Teste_SOPC_clock_0_in, which is an e_instance
  the_Teste_SOPC_clock_0_in : Teste_SOPC_clock_0_in_arbitrator
    port map(
      Teste_SOPC_clock_0_in_address => Teste_SOPC_clock_0_in_address,
      Teste_SOPC_clock_0_in_byteenable => Teste_SOPC_clock_0_in_byteenable,
      Teste_SOPC_clock_0_in_endofpacket_from_sa => Teste_SOPC_clock_0_in_endofpacket_from_sa,
      Teste_SOPC_clock_0_in_nativeaddress => Teste_SOPC_clock_0_in_nativeaddress,
      Teste_SOPC_clock_0_in_read => Teste_SOPC_clock_0_in_read,
      Teste_SOPC_clock_0_in_readdata_from_sa => Teste_SOPC_clock_0_in_readdata_from_sa,
      Teste_SOPC_clock_0_in_reset_n => Teste_SOPC_clock_0_in_reset_n,
      Teste_SOPC_clock_0_in_waitrequest_from_sa => Teste_SOPC_clock_0_in_waitrequest_from_sa,
      Teste_SOPC_clock_0_in_write => Teste_SOPC_clock_0_in_write,
      cpu_instruction_master_granted_Teste_SOPC_clock_0_in => cpu_instruction_master_granted_Teste_SOPC_clock_0_in,
      cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in => cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in,
      cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in => cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in,
      cpu_instruction_master_requests_Teste_SOPC_clock_0_in => cpu_instruction_master_requests_Teste_SOPC_clock_0_in,
      d1_Teste_SOPC_clock_0_in_end_xfer => d1_Teste_SOPC_clock_0_in_end_xfer,
      Teste_SOPC_clock_0_in_endofpacket => Teste_SOPC_clock_0_in_endofpacket,
      Teste_SOPC_clock_0_in_readdata => Teste_SOPC_clock_0_in_readdata,
      Teste_SOPC_clock_0_in_waitrequest => Teste_SOPC_clock_0_in_waitrequest,
      clk => clk_100,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_dbs_address => cpu_instruction_master_dbs_address,
      cpu_instruction_master_read => cpu_instruction_master_read,
      reset_n => clk_100_reset_n
    );


  --the_Teste_SOPC_clock_0_out, which is an e_instance
  the_Teste_SOPC_clock_0_out : Teste_SOPC_clock_0_out_arbitrator
    port map(
      Teste_SOPC_clock_0_out_address_to_slave => Teste_SOPC_clock_0_out_address_to_slave,
      Teste_SOPC_clock_0_out_readdata => Teste_SOPC_clock_0_out_readdata,
      Teste_SOPC_clock_0_out_reset_n => Teste_SOPC_clock_0_out_reset_n,
      Teste_SOPC_clock_0_out_waitrequest => Teste_SOPC_clock_0_out_waitrequest,
      Teste_SOPC_clock_0_out_address => Teste_SOPC_clock_0_out_address,
      Teste_SOPC_clock_0_out_byteenable => Teste_SOPC_clock_0_out_byteenable,
      Teste_SOPC_clock_0_out_granted_sdram_s1 => Teste_SOPC_clock_0_out_granted_sdram_s1,
      Teste_SOPC_clock_0_out_qualified_request_sdram_s1 => Teste_SOPC_clock_0_out_qualified_request_sdram_s1,
      Teste_SOPC_clock_0_out_read => Teste_SOPC_clock_0_out_read,
      Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 => Teste_SOPC_clock_0_out_read_data_valid_sdram_s1,
      Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register => Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register,
      Teste_SOPC_clock_0_out_requests_sdram_s1 => Teste_SOPC_clock_0_out_requests_sdram_s1,
      Teste_SOPC_clock_0_out_write => Teste_SOPC_clock_0_out_write,
      Teste_SOPC_clock_0_out_writedata => Teste_SOPC_clock_0_out_writedata,
      clk => internal_altpll_sdram_c0,
      d1_sdram_s1_end_xfer => d1_sdram_s1_end_xfer,
      reset_n => altpll_sdram_c0_reset_n,
      sdram_s1_readdata_from_sa => sdram_s1_readdata_from_sa,
      sdram_s1_waitrequest_from_sa => sdram_s1_waitrequest_from_sa
    );


  --the_Teste_SOPC_clock_0, which is an e_ptf_instance
  the_Teste_SOPC_clock_0 : Teste_SOPC_clock_0
    port map(
      master_address => Teste_SOPC_clock_0_out_address,
      master_byteenable => Teste_SOPC_clock_0_out_byteenable,
      master_nativeaddress => Teste_SOPC_clock_0_out_nativeaddress,
      master_read => Teste_SOPC_clock_0_out_read,
      master_write => Teste_SOPC_clock_0_out_write,
      master_writedata => Teste_SOPC_clock_0_out_writedata,
      slave_endofpacket => Teste_SOPC_clock_0_in_endofpacket,
      slave_readdata => Teste_SOPC_clock_0_in_readdata,
      slave_waitrequest => Teste_SOPC_clock_0_in_waitrequest,
      master_clk => internal_altpll_sdram_c0,
      master_endofpacket => Teste_SOPC_clock_0_out_endofpacket,
      master_readdata => Teste_SOPC_clock_0_out_readdata,
      master_reset_n => Teste_SOPC_clock_0_out_reset_n,
      master_waitrequest => Teste_SOPC_clock_0_out_waitrequest,
      slave_address => Teste_SOPC_clock_0_in_address,
      slave_byteenable => Teste_SOPC_clock_0_in_byteenable,
      slave_clk => clk_100,
      slave_nativeaddress => Teste_SOPC_clock_0_in_nativeaddress,
      slave_read => Teste_SOPC_clock_0_in_read,
      slave_reset_n => Teste_SOPC_clock_0_in_reset_n,
      slave_write => Teste_SOPC_clock_0_in_write,
      slave_writedata => Teste_SOPC_clock_0_in_writedata
    );


  --the_Teste_SOPC_clock_1_in, which is an e_instance
  the_Teste_SOPC_clock_1_in : Teste_SOPC_clock_1_in_arbitrator
    port map(
      Teste_SOPC_clock_1_in_address => Teste_SOPC_clock_1_in_address,
      Teste_SOPC_clock_1_in_byteenable => Teste_SOPC_clock_1_in_byteenable,
      Teste_SOPC_clock_1_in_endofpacket_from_sa => Teste_SOPC_clock_1_in_endofpacket_from_sa,
      Teste_SOPC_clock_1_in_nativeaddress => Teste_SOPC_clock_1_in_nativeaddress,
      Teste_SOPC_clock_1_in_read => Teste_SOPC_clock_1_in_read,
      Teste_SOPC_clock_1_in_readdata_from_sa => Teste_SOPC_clock_1_in_readdata_from_sa,
      Teste_SOPC_clock_1_in_reset_n => Teste_SOPC_clock_1_in_reset_n,
      Teste_SOPC_clock_1_in_waitrequest_from_sa => Teste_SOPC_clock_1_in_waitrequest_from_sa,
      Teste_SOPC_clock_1_in_write => Teste_SOPC_clock_1_in_write,
      Teste_SOPC_clock_1_in_writedata => Teste_SOPC_clock_1_in_writedata,
      cpu_data_master_byteenable_Teste_SOPC_clock_1_in => cpu_data_master_byteenable_Teste_SOPC_clock_1_in,
      cpu_data_master_granted_Teste_SOPC_clock_1_in => cpu_data_master_granted_Teste_SOPC_clock_1_in,
      cpu_data_master_qualified_request_Teste_SOPC_clock_1_in => cpu_data_master_qualified_request_Teste_SOPC_clock_1_in,
      cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in => cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in,
      cpu_data_master_requests_Teste_SOPC_clock_1_in => cpu_data_master_requests_Teste_SOPC_clock_1_in,
      d1_Teste_SOPC_clock_1_in_end_xfer => d1_Teste_SOPC_clock_1_in_end_xfer,
      Teste_SOPC_clock_1_in_endofpacket => Teste_SOPC_clock_1_in_endofpacket,
      Teste_SOPC_clock_1_in_readdata => Teste_SOPC_clock_1_in_readdata,
      Teste_SOPC_clock_1_in_waitrequest => Teste_SOPC_clock_1_in_waitrequest,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_dbs_address => cpu_data_master_dbs_address,
      cpu_data_master_dbs_write_16 => cpu_data_master_dbs_write_16,
      cpu_data_master_no_byte_enables_and_last_term => cpu_data_master_no_byte_enables_and_last_term,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      reset_n => clk_100_reset_n
    );


  --the_Teste_SOPC_clock_1_out, which is an e_instance
  the_Teste_SOPC_clock_1_out : Teste_SOPC_clock_1_out_arbitrator
    port map(
      Teste_SOPC_clock_1_out_address_to_slave => Teste_SOPC_clock_1_out_address_to_slave,
      Teste_SOPC_clock_1_out_readdata => Teste_SOPC_clock_1_out_readdata,
      Teste_SOPC_clock_1_out_reset_n => Teste_SOPC_clock_1_out_reset_n,
      Teste_SOPC_clock_1_out_waitrequest => Teste_SOPC_clock_1_out_waitrequest,
      Teste_SOPC_clock_1_out_address => Teste_SOPC_clock_1_out_address,
      Teste_SOPC_clock_1_out_byteenable => Teste_SOPC_clock_1_out_byteenable,
      Teste_SOPC_clock_1_out_granted_sdram_s1 => Teste_SOPC_clock_1_out_granted_sdram_s1,
      Teste_SOPC_clock_1_out_qualified_request_sdram_s1 => Teste_SOPC_clock_1_out_qualified_request_sdram_s1,
      Teste_SOPC_clock_1_out_read => Teste_SOPC_clock_1_out_read,
      Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 => Teste_SOPC_clock_1_out_read_data_valid_sdram_s1,
      Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register => Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register,
      Teste_SOPC_clock_1_out_requests_sdram_s1 => Teste_SOPC_clock_1_out_requests_sdram_s1,
      Teste_SOPC_clock_1_out_write => Teste_SOPC_clock_1_out_write,
      Teste_SOPC_clock_1_out_writedata => Teste_SOPC_clock_1_out_writedata,
      clk => internal_altpll_sdram_c0,
      d1_sdram_s1_end_xfer => d1_sdram_s1_end_xfer,
      reset_n => altpll_sdram_c0_reset_n,
      sdram_s1_readdata_from_sa => sdram_s1_readdata_from_sa,
      sdram_s1_waitrequest_from_sa => sdram_s1_waitrequest_from_sa
    );


  --the_Teste_SOPC_clock_1, which is an e_ptf_instance
  the_Teste_SOPC_clock_1 : Teste_SOPC_clock_1
    port map(
      master_address => Teste_SOPC_clock_1_out_address,
      master_byteenable => Teste_SOPC_clock_1_out_byteenable,
      master_nativeaddress => Teste_SOPC_clock_1_out_nativeaddress,
      master_read => Teste_SOPC_clock_1_out_read,
      master_write => Teste_SOPC_clock_1_out_write,
      master_writedata => Teste_SOPC_clock_1_out_writedata,
      slave_endofpacket => Teste_SOPC_clock_1_in_endofpacket,
      slave_readdata => Teste_SOPC_clock_1_in_readdata,
      slave_waitrequest => Teste_SOPC_clock_1_in_waitrequest,
      master_clk => internal_altpll_sdram_c0,
      master_endofpacket => Teste_SOPC_clock_1_out_endofpacket,
      master_readdata => Teste_SOPC_clock_1_out_readdata,
      master_reset_n => Teste_SOPC_clock_1_out_reset_n,
      master_waitrequest => Teste_SOPC_clock_1_out_waitrequest,
      slave_address => Teste_SOPC_clock_1_in_address,
      slave_byteenable => Teste_SOPC_clock_1_in_byteenable,
      slave_clk => clk_100,
      slave_nativeaddress => Teste_SOPC_clock_1_in_nativeaddress,
      slave_read => Teste_SOPC_clock_1_in_read,
      slave_reset_n => Teste_SOPC_clock_1_in_reset_n,
      slave_write => Teste_SOPC_clock_1_in_write,
      slave_writedata => Teste_SOPC_clock_1_in_writedata
    );


  --the_altpll_sdram_pll_slave, which is an e_instance
  the_altpll_sdram_pll_slave : altpll_sdram_pll_slave_arbitrator
    port map(
      altpll_sdram_pll_slave_address => altpll_sdram_pll_slave_address,
      altpll_sdram_pll_slave_read => altpll_sdram_pll_slave_read,
      altpll_sdram_pll_slave_readdata_from_sa => altpll_sdram_pll_slave_readdata_from_sa,
      altpll_sdram_pll_slave_reset => altpll_sdram_pll_slave_reset,
      altpll_sdram_pll_slave_write => altpll_sdram_pll_slave_write,
      altpll_sdram_pll_slave_writedata => altpll_sdram_pll_slave_writedata,
      cpu_data_master_granted_altpll_sdram_pll_slave => cpu_data_master_granted_altpll_sdram_pll_slave,
      cpu_data_master_qualified_request_altpll_sdram_pll_slave => cpu_data_master_qualified_request_altpll_sdram_pll_slave,
      cpu_data_master_read_data_valid_altpll_sdram_pll_slave => cpu_data_master_read_data_valid_altpll_sdram_pll_slave,
      cpu_data_master_requests_altpll_sdram_pll_slave => cpu_data_master_requests_altpll_sdram_pll_slave,
      d1_altpll_sdram_pll_slave_end_xfer => d1_altpll_sdram_pll_slave_end_xfer,
      altpll_sdram_pll_slave_readdata => altpll_sdram_pll_slave_readdata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_100_reset_n
    );


  --altpll_sdram_c0 out_clk assignment, which is an e_assign
  internal_altpll_sdram_c0 <= out_clk_altpll_sdram_c0;
  --the_altpll_sdram, which is an e_ptf_instance
  the_altpll_sdram : altpll_sdram
    port map(
      c0 => out_clk_altpll_sdram_c0,
      locked => internal_locked_from_the_altpll_sdram,
      phasedone => internal_phasedone_from_the_altpll_sdram,
      readdata => altpll_sdram_pll_slave_readdata,
      address => altpll_sdram_pll_slave_address,
      areset => areset_to_the_altpll_sdram,
      clk => clk_100,
      read => altpll_sdram_pll_slave_read,
      reset => altpll_sdram_pll_slave_reset,
      write => altpll_sdram_pll_slave_write,
      writedata => altpll_sdram_pll_slave_writedata
    );


  --the_cpu_jtag_debug_module, which is an e_instance
  the_cpu_jtag_debug_module : cpu_jtag_debug_module_arbitrator
    port map(
      cpu_data_master_granted_cpu_jtag_debug_module => cpu_data_master_granted_cpu_jtag_debug_module,
      cpu_data_master_qualified_request_cpu_jtag_debug_module => cpu_data_master_qualified_request_cpu_jtag_debug_module,
      cpu_data_master_read_data_valid_cpu_jtag_debug_module => cpu_data_master_read_data_valid_cpu_jtag_debug_module,
      cpu_data_master_requests_cpu_jtag_debug_module => cpu_data_master_requests_cpu_jtag_debug_module,
      cpu_instruction_master_granted_cpu_jtag_debug_module => cpu_instruction_master_granted_cpu_jtag_debug_module,
      cpu_instruction_master_qualified_request_cpu_jtag_debug_module => cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
      cpu_instruction_master_read_data_valid_cpu_jtag_debug_module => cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
      cpu_instruction_master_requests_cpu_jtag_debug_module => cpu_instruction_master_requests_cpu_jtag_debug_module,
      cpu_jtag_debug_module_address => cpu_jtag_debug_module_address,
      cpu_jtag_debug_module_begintransfer => cpu_jtag_debug_module_begintransfer,
      cpu_jtag_debug_module_byteenable => cpu_jtag_debug_module_byteenable,
      cpu_jtag_debug_module_chipselect => cpu_jtag_debug_module_chipselect,
      cpu_jtag_debug_module_debugaccess => cpu_jtag_debug_module_debugaccess,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      cpu_jtag_debug_module_reset_n => cpu_jtag_debug_module_reset_n,
      cpu_jtag_debug_module_resetrequest_from_sa => cpu_jtag_debug_module_resetrequest_from_sa,
      cpu_jtag_debug_module_write => cpu_jtag_debug_module_write,
      cpu_jtag_debug_module_writedata => cpu_jtag_debug_module_writedata,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_debugaccess => cpu_data_master_debugaccess,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_jtag_debug_module_readdata => cpu_jtag_debug_module_readdata,
      cpu_jtag_debug_module_resetrequest => cpu_jtag_debug_module_resetrequest,
      reset_n => clk_100_reset_n
    );


  --the_cpu_data_master, which is an e_instance
  the_cpu_data_master : cpu_data_master_arbitrator
    port map(
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_dbs_address => cpu_data_master_dbs_address,
      cpu_data_master_dbs_write_16 => cpu_data_master_dbs_write_16,
      cpu_data_master_irq => cpu_data_master_irq,
      cpu_data_master_no_byte_enables_and_last_term => cpu_data_master_no_byte_enables_and_last_term,
      cpu_data_master_readdata => cpu_data_master_readdata,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      I2C_Master_avalon_slave_irq_from_sa => I2C_Master_avalon_slave_irq_from_sa,
      I2C_Master_avalon_slave_readdata_from_sa => I2C_Master_avalon_slave_readdata_from_sa,
      I2C_Master_avalon_slave_waitrequest_n_from_sa => I2C_Master_avalon_slave_waitrequest_n_from_sa,
      TERASIC_SPI_3WIRE_0_slave_readdata_from_sa => TERASIC_SPI_3WIRE_0_slave_readdata_from_sa,
      Teste_SOPC_clock_1_in_readdata_from_sa => Teste_SOPC_clock_1_in_readdata_from_sa,
      Teste_SOPC_clock_1_in_waitrequest_from_sa => Teste_SOPC_clock_1_in_waitrequest_from_sa,
      altpll_sdram_pll_slave_readdata_from_sa => altpll_sdram_pll_slave_readdata_from_sa,
      clk => clk_100,
      cpu_data_master_address => cpu_data_master_address,
      cpu_data_master_byteenable_Teste_SOPC_clock_1_in => cpu_data_master_byteenable_Teste_SOPC_clock_1_in,
      cpu_data_master_granted_I2C_Master_avalon_slave => cpu_data_master_granted_I2C_Master_avalon_slave,
      cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_granted_TERASIC_SPI_3WIRE_0_slave,
      cpu_data_master_granted_Teste_SOPC_clock_1_in => cpu_data_master_granted_Teste_SOPC_clock_1_in,
      cpu_data_master_granted_altpll_sdram_pll_slave => cpu_data_master_granted_altpll_sdram_pll_slave,
      cpu_data_master_granted_cpu_jtag_debug_module => cpu_data_master_granted_cpu_jtag_debug_module,
      cpu_data_master_granted_jtag_uart_avalon_jtag_slave => cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      cpu_data_master_granted_pio_bot_endcalc_s1 => cpu_data_master_granted_pio_bot_endcalc_s1,
      cpu_data_master_granted_pio_bot_legselect_s1 => cpu_data_master_granted_pio_bot_legselect_s1,
      cpu_data_master_granted_pio_bot_reset_s1 => cpu_data_master_granted_pio_bot_reset_s1,
      cpu_data_master_granted_pio_bot_updateflag_s1 => cpu_data_master_granted_pio_bot_updateflag_s1,
      cpu_data_master_granted_pio_bot_wrcoord_s1 => cpu_data_master_granted_pio_bot_wrcoord_s1,
      cpu_data_master_granted_pio_bot_x_s1 => cpu_data_master_granted_pio_bot_x_s1,
      cpu_data_master_granted_pio_bot_y_s1 => cpu_data_master_granted_pio_bot_y_s1,
      cpu_data_master_granted_pio_bot_z_s1 => cpu_data_master_granted_pio_bot_z_s1,
      cpu_data_master_granted_pio_led_s1 => cpu_data_master_granted_pio_led_s1,
      cpu_data_master_granted_spi_spi_control_port => cpu_data_master_granted_spi_spi_control_port,
      cpu_data_master_granted_timer_sys_s1 => cpu_data_master_granted_timer_sys_s1,
      cpu_data_master_granted_uart_s1 => cpu_data_master_granted_uart_s1,
      cpu_data_master_qualified_request_I2C_Master_avalon_slave => cpu_data_master_qualified_request_I2C_Master_avalon_slave,
      cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_qualified_request_TERASIC_SPI_3WIRE_0_slave,
      cpu_data_master_qualified_request_Teste_SOPC_clock_1_in => cpu_data_master_qualified_request_Teste_SOPC_clock_1_in,
      cpu_data_master_qualified_request_altpll_sdram_pll_slave => cpu_data_master_qualified_request_altpll_sdram_pll_slave,
      cpu_data_master_qualified_request_cpu_jtag_debug_module => cpu_data_master_qualified_request_cpu_jtag_debug_module,
      cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      cpu_data_master_qualified_request_pio_bot_endcalc_s1 => cpu_data_master_qualified_request_pio_bot_endcalc_s1,
      cpu_data_master_qualified_request_pio_bot_legselect_s1 => cpu_data_master_qualified_request_pio_bot_legselect_s1,
      cpu_data_master_qualified_request_pio_bot_reset_s1 => cpu_data_master_qualified_request_pio_bot_reset_s1,
      cpu_data_master_qualified_request_pio_bot_updateflag_s1 => cpu_data_master_qualified_request_pio_bot_updateflag_s1,
      cpu_data_master_qualified_request_pio_bot_wrcoord_s1 => cpu_data_master_qualified_request_pio_bot_wrcoord_s1,
      cpu_data_master_qualified_request_pio_bot_x_s1 => cpu_data_master_qualified_request_pio_bot_x_s1,
      cpu_data_master_qualified_request_pio_bot_y_s1 => cpu_data_master_qualified_request_pio_bot_y_s1,
      cpu_data_master_qualified_request_pio_bot_z_s1 => cpu_data_master_qualified_request_pio_bot_z_s1,
      cpu_data_master_qualified_request_pio_led_s1 => cpu_data_master_qualified_request_pio_led_s1,
      cpu_data_master_qualified_request_spi_spi_control_port => cpu_data_master_qualified_request_spi_spi_control_port,
      cpu_data_master_qualified_request_timer_sys_s1 => cpu_data_master_qualified_request_timer_sys_s1,
      cpu_data_master_qualified_request_uart_s1 => cpu_data_master_qualified_request_uart_s1,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_read_data_valid_I2C_Master_avalon_slave => cpu_data_master_read_data_valid_I2C_Master_avalon_slave,
      cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave,
      cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in => cpu_data_master_read_data_valid_Teste_SOPC_clock_1_in,
      cpu_data_master_read_data_valid_altpll_sdram_pll_slave => cpu_data_master_read_data_valid_altpll_sdram_pll_slave,
      cpu_data_master_read_data_valid_cpu_jtag_debug_module => cpu_data_master_read_data_valid_cpu_jtag_debug_module,
      cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      cpu_data_master_read_data_valid_pio_bot_endcalc_s1 => cpu_data_master_read_data_valid_pio_bot_endcalc_s1,
      cpu_data_master_read_data_valid_pio_bot_legselect_s1 => cpu_data_master_read_data_valid_pio_bot_legselect_s1,
      cpu_data_master_read_data_valid_pio_bot_reset_s1 => cpu_data_master_read_data_valid_pio_bot_reset_s1,
      cpu_data_master_read_data_valid_pio_bot_updateflag_s1 => cpu_data_master_read_data_valid_pio_bot_updateflag_s1,
      cpu_data_master_read_data_valid_pio_bot_wrcoord_s1 => cpu_data_master_read_data_valid_pio_bot_wrcoord_s1,
      cpu_data_master_read_data_valid_pio_bot_x_s1 => cpu_data_master_read_data_valid_pio_bot_x_s1,
      cpu_data_master_read_data_valid_pio_bot_y_s1 => cpu_data_master_read_data_valid_pio_bot_y_s1,
      cpu_data_master_read_data_valid_pio_bot_z_s1 => cpu_data_master_read_data_valid_pio_bot_z_s1,
      cpu_data_master_read_data_valid_pio_led_s1 => cpu_data_master_read_data_valid_pio_led_s1,
      cpu_data_master_read_data_valid_spi_spi_control_port => cpu_data_master_read_data_valid_spi_spi_control_port,
      cpu_data_master_read_data_valid_timer_sys_s1 => cpu_data_master_read_data_valid_timer_sys_s1,
      cpu_data_master_read_data_valid_uart_s1 => cpu_data_master_read_data_valid_uart_s1,
      cpu_data_master_requests_I2C_Master_avalon_slave => cpu_data_master_requests_I2C_Master_avalon_slave,
      cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave => cpu_data_master_requests_TERASIC_SPI_3WIRE_0_slave,
      cpu_data_master_requests_Teste_SOPC_clock_1_in => cpu_data_master_requests_Teste_SOPC_clock_1_in,
      cpu_data_master_requests_altpll_sdram_pll_slave => cpu_data_master_requests_altpll_sdram_pll_slave,
      cpu_data_master_requests_cpu_jtag_debug_module => cpu_data_master_requests_cpu_jtag_debug_module,
      cpu_data_master_requests_jtag_uart_avalon_jtag_slave => cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      cpu_data_master_requests_pio_bot_endcalc_s1 => cpu_data_master_requests_pio_bot_endcalc_s1,
      cpu_data_master_requests_pio_bot_legselect_s1 => cpu_data_master_requests_pio_bot_legselect_s1,
      cpu_data_master_requests_pio_bot_reset_s1 => cpu_data_master_requests_pio_bot_reset_s1,
      cpu_data_master_requests_pio_bot_updateflag_s1 => cpu_data_master_requests_pio_bot_updateflag_s1,
      cpu_data_master_requests_pio_bot_wrcoord_s1 => cpu_data_master_requests_pio_bot_wrcoord_s1,
      cpu_data_master_requests_pio_bot_x_s1 => cpu_data_master_requests_pio_bot_x_s1,
      cpu_data_master_requests_pio_bot_y_s1 => cpu_data_master_requests_pio_bot_y_s1,
      cpu_data_master_requests_pio_bot_z_s1 => cpu_data_master_requests_pio_bot_z_s1,
      cpu_data_master_requests_pio_led_s1 => cpu_data_master_requests_pio_led_s1,
      cpu_data_master_requests_spi_spi_control_port => cpu_data_master_requests_spi_spi_control_port,
      cpu_data_master_requests_timer_sys_s1 => cpu_data_master_requests_timer_sys_s1,
      cpu_data_master_requests_uart_s1 => cpu_data_master_requests_uart_s1,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      d1_I2C_Master_avalon_slave_end_xfer => d1_I2C_Master_avalon_slave_end_xfer,
      d1_TERASIC_SPI_3WIRE_0_slave_end_xfer => d1_TERASIC_SPI_3WIRE_0_slave_end_xfer,
      d1_Teste_SOPC_clock_1_in_end_xfer => d1_Teste_SOPC_clock_1_in_end_xfer,
      d1_altpll_sdram_pll_slave_end_xfer => d1_altpll_sdram_pll_slave_end_xfer,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      d1_jtag_uart_avalon_jtag_slave_end_xfer => d1_jtag_uart_avalon_jtag_slave_end_xfer,
      d1_pio_bot_endcalc_s1_end_xfer => d1_pio_bot_endcalc_s1_end_xfer,
      d1_pio_bot_legselect_s1_end_xfer => d1_pio_bot_legselect_s1_end_xfer,
      d1_pio_bot_reset_s1_end_xfer => d1_pio_bot_reset_s1_end_xfer,
      d1_pio_bot_updateflag_s1_end_xfer => d1_pio_bot_updateflag_s1_end_xfer,
      d1_pio_bot_wrcoord_s1_end_xfer => d1_pio_bot_wrcoord_s1_end_xfer,
      d1_pio_bot_x_s1_end_xfer => d1_pio_bot_x_s1_end_xfer,
      d1_pio_bot_y_s1_end_xfer => d1_pio_bot_y_s1_end_xfer,
      d1_pio_bot_z_s1_end_xfer => d1_pio_bot_z_s1_end_xfer,
      d1_pio_led_s1_end_xfer => d1_pio_led_s1_end_xfer,
      d1_spi_spi_control_port_end_xfer => d1_spi_spi_control_port_end_xfer,
      d1_timer_sys_s1_end_xfer => d1_timer_sys_s1_end_xfer,
      d1_uart_s1_end_xfer => d1_uart_s1_end_xfer,
      jtag_uart_avalon_jtag_slave_irq_from_sa => jtag_uart_avalon_jtag_slave_irq_from_sa,
      jtag_uart_avalon_jtag_slave_readdata_from_sa => jtag_uart_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
      pio_bot_endcalc_s1_readdata_from_sa => pio_bot_endcalc_s1_readdata_from_sa,
      pio_bot_legselect_s1_readdata_from_sa => pio_bot_legselect_s1_readdata_from_sa,
      pio_bot_reset_s1_readdata_from_sa => pio_bot_reset_s1_readdata_from_sa,
      pio_bot_updateflag_s1_readdata_from_sa => pio_bot_updateflag_s1_readdata_from_sa,
      pio_bot_wrcoord_s1_readdata_from_sa => pio_bot_wrcoord_s1_readdata_from_sa,
      pio_bot_x_s1_readdata_from_sa => pio_bot_x_s1_readdata_from_sa,
      pio_bot_y_s1_readdata_from_sa => pio_bot_y_s1_readdata_from_sa,
      pio_bot_z_s1_readdata_from_sa => pio_bot_z_s1_readdata_from_sa,
      pio_led_s1_readdata_from_sa => pio_led_s1_readdata_from_sa,
      registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave => registered_cpu_data_master_read_data_valid_TERASIC_SPI_3WIRE_0_slave,
      reset_n => clk_100_reset_n,
      spi_spi_control_port_irq_from_sa => spi_spi_control_port_irq_from_sa,
      spi_spi_control_port_readdata_from_sa => spi_spi_control_port_readdata_from_sa,
      timer_sys_s1_irq_from_sa => timer_sys_s1_irq_from_sa,
      timer_sys_s1_readdata_from_sa => timer_sys_s1_readdata_from_sa,
      uart_s1_irq_from_sa => uart_s1_irq_from_sa,
      uart_s1_readdata_from_sa => uart_s1_readdata_from_sa
    );


  --the_cpu_instruction_master, which is an e_instance
  the_cpu_instruction_master : cpu_instruction_master_arbitrator
    port map(
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_dbs_address => cpu_instruction_master_dbs_address,
      cpu_instruction_master_readdata => cpu_instruction_master_readdata,
      cpu_instruction_master_waitrequest => cpu_instruction_master_waitrequest,
      Teste_SOPC_clock_0_in_readdata_from_sa => Teste_SOPC_clock_0_in_readdata_from_sa,
      Teste_SOPC_clock_0_in_waitrequest_from_sa => Teste_SOPC_clock_0_in_waitrequest_from_sa,
      clk => clk_100,
      cpu_instruction_master_address => cpu_instruction_master_address,
      cpu_instruction_master_granted_Teste_SOPC_clock_0_in => cpu_instruction_master_granted_Teste_SOPC_clock_0_in,
      cpu_instruction_master_granted_cpu_jtag_debug_module => cpu_instruction_master_granted_cpu_jtag_debug_module,
      cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in => cpu_instruction_master_qualified_request_Teste_SOPC_clock_0_in,
      cpu_instruction_master_qualified_request_cpu_jtag_debug_module => cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in => cpu_instruction_master_read_data_valid_Teste_SOPC_clock_0_in,
      cpu_instruction_master_read_data_valid_cpu_jtag_debug_module => cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
      cpu_instruction_master_requests_Teste_SOPC_clock_0_in => cpu_instruction_master_requests_Teste_SOPC_clock_0_in,
      cpu_instruction_master_requests_cpu_jtag_debug_module => cpu_instruction_master_requests_cpu_jtag_debug_module,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      d1_Teste_SOPC_clock_0_in_end_xfer => d1_Teste_SOPC_clock_0_in_end_xfer,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      reset_n => clk_100_reset_n
    );


  --the_cpu, which is an e_ptf_instance
  the_cpu : cpu
    port map(
      d_address => cpu_data_master_address,
      d_byteenable => cpu_data_master_byteenable,
      d_read => cpu_data_master_read,
      d_write => cpu_data_master_write,
      d_writedata => cpu_data_master_writedata,
      i_address => cpu_instruction_master_address,
      i_read => cpu_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => cpu_data_master_debugaccess,
      jtag_debug_module_readdata => cpu_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => cpu_jtag_debug_module_resetrequest,
      clk => clk_100,
      d_irq => cpu_data_master_irq,
      d_readdata => cpu_data_master_readdata,
      d_waitrequest => cpu_data_master_waitrequest,
      i_readdata => cpu_instruction_master_readdata,
      i_waitrequest => cpu_instruction_master_waitrequest,
      jtag_debug_module_address => cpu_jtag_debug_module_address,
      jtag_debug_module_begintransfer => cpu_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => cpu_jtag_debug_module_byteenable,
      jtag_debug_module_debugaccess => cpu_jtag_debug_module_debugaccess,
      jtag_debug_module_select => cpu_jtag_debug_module_chipselect,
      jtag_debug_module_write => cpu_jtag_debug_module_write,
      jtag_debug_module_writedata => cpu_jtag_debug_module_writedata,
      reset_n => cpu_jtag_debug_module_reset_n
    );


  --the_jtag_uart_avalon_jtag_slave, which is an e_instance
  the_jtag_uart_avalon_jtag_slave : jtag_uart_avalon_jtag_slave_arbitrator
    port map(
      cpu_data_master_granted_jtag_uart_avalon_jtag_slave => cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      cpu_data_master_requests_jtag_uart_avalon_jtag_slave => cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      d1_jtag_uart_avalon_jtag_slave_end_xfer => d1_jtag_uart_avalon_jtag_slave_end_xfer,
      jtag_uart_avalon_jtag_slave_address => jtag_uart_avalon_jtag_slave_address,
      jtag_uart_avalon_jtag_slave_chipselect => jtag_uart_avalon_jtag_slave_chipselect,
      jtag_uart_avalon_jtag_slave_dataavailable_from_sa => jtag_uart_avalon_jtag_slave_dataavailable_from_sa,
      jtag_uart_avalon_jtag_slave_irq_from_sa => jtag_uart_avalon_jtag_slave_irq_from_sa,
      jtag_uart_avalon_jtag_slave_read_n => jtag_uart_avalon_jtag_slave_read_n,
      jtag_uart_avalon_jtag_slave_readdata_from_sa => jtag_uart_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_readyfordata_from_sa => jtag_uart_avalon_jtag_slave_readyfordata_from_sa,
      jtag_uart_avalon_jtag_slave_reset_n => jtag_uart_avalon_jtag_slave_reset_n,
      jtag_uart_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
      jtag_uart_avalon_jtag_slave_write_n => jtag_uart_avalon_jtag_slave_write_n,
      jtag_uart_avalon_jtag_slave_writedata => jtag_uart_avalon_jtag_slave_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      jtag_uart_avalon_jtag_slave_dataavailable => jtag_uart_avalon_jtag_slave_dataavailable,
      jtag_uart_avalon_jtag_slave_irq => jtag_uart_avalon_jtag_slave_irq,
      jtag_uart_avalon_jtag_slave_readdata => jtag_uart_avalon_jtag_slave_readdata,
      jtag_uart_avalon_jtag_slave_readyfordata => jtag_uart_avalon_jtag_slave_readyfordata,
      jtag_uart_avalon_jtag_slave_waitrequest => jtag_uart_avalon_jtag_slave_waitrequest,
      reset_n => clk_100_reset_n
    );


  --the_jtag_uart, which is an e_ptf_instance
  the_jtag_uart : jtag_uart
    port map(
      av_irq => jtag_uart_avalon_jtag_slave_irq,
      av_readdata => jtag_uart_avalon_jtag_slave_readdata,
      av_waitrequest => jtag_uart_avalon_jtag_slave_waitrequest,
      dataavailable => jtag_uart_avalon_jtag_slave_dataavailable,
      readyfordata => jtag_uart_avalon_jtag_slave_readyfordata,
      av_address => jtag_uart_avalon_jtag_slave_address,
      av_chipselect => jtag_uart_avalon_jtag_slave_chipselect,
      av_read_n => jtag_uart_avalon_jtag_slave_read_n,
      av_write_n => jtag_uart_avalon_jtag_slave_write_n,
      av_writedata => jtag_uart_avalon_jtag_slave_writedata,
      clk => clk_100,
      rst_n => jtag_uart_avalon_jtag_slave_reset_n
    );


  --the_pio_bot_endcalc_s1, which is an e_instance
  the_pio_bot_endcalc_s1 : pio_bot_endcalc_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_endcalc_s1 => cpu_data_master_granted_pio_bot_endcalc_s1,
      cpu_data_master_qualified_request_pio_bot_endcalc_s1 => cpu_data_master_qualified_request_pio_bot_endcalc_s1,
      cpu_data_master_read_data_valid_pio_bot_endcalc_s1 => cpu_data_master_read_data_valid_pio_bot_endcalc_s1,
      cpu_data_master_requests_pio_bot_endcalc_s1 => cpu_data_master_requests_pio_bot_endcalc_s1,
      d1_pio_bot_endcalc_s1_end_xfer => d1_pio_bot_endcalc_s1_end_xfer,
      pio_bot_endcalc_s1_address => pio_bot_endcalc_s1_address,
      pio_bot_endcalc_s1_readdata_from_sa => pio_bot_endcalc_s1_readdata_from_sa,
      pio_bot_endcalc_s1_reset_n => pio_bot_endcalc_s1_reset_n,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_write => cpu_data_master_write,
      pio_bot_endcalc_s1_readdata => pio_bot_endcalc_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_endcalc, which is an e_ptf_instance
  the_pio_bot_endcalc : pio_bot_endcalc
    port map(
      readdata => pio_bot_endcalc_s1_readdata,
      address => pio_bot_endcalc_s1_address,
      clk => clk_100,
      in_port => in_port_to_the_pio_bot_endcalc,
      reset_n => pio_bot_endcalc_s1_reset_n
    );


  --the_pio_bot_legselect_s1, which is an e_instance
  the_pio_bot_legselect_s1 : pio_bot_legselect_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_legselect_s1 => cpu_data_master_granted_pio_bot_legselect_s1,
      cpu_data_master_qualified_request_pio_bot_legselect_s1 => cpu_data_master_qualified_request_pio_bot_legselect_s1,
      cpu_data_master_read_data_valid_pio_bot_legselect_s1 => cpu_data_master_read_data_valid_pio_bot_legselect_s1,
      cpu_data_master_requests_pio_bot_legselect_s1 => cpu_data_master_requests_pio_bot_legselect_s1,
      d1_pio_bot_legselect_s1_end_xfer => d1_pio_bot_legselect_s1_end_xfer,
      pio_bot_legselect_s1_address => pio_bot_legselect_s1_address,
      pio_bot_legselect_s1_chipselect => pio_bot_legselect_s1_chipselect,
      pio_bot_legselect_s1_readdata_from_sa => pio_bot_legselect_s1_readdata_from_sa,
      pio_bot_legselect_s1_reset_n => pio_bot_legselect_s1_reset_n,
      pio_bot_legselect_s1_write_n => pio_bot_legselect_s1_write_n,
      pio_bot_legselect_s1_writedata => pio_bot_legselect_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_bot_legselect_s1_readdata => pio_bot_legselect_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_legselect, which is an e_ptf_instance
  the_pio_bot_legselect : pio_bot_legselect
    port map(
      out_port => internal_out_port_from_the_pio_bot_legselect,
      readdata => pio_bot_legselect_s1_readdata,
      address => pio_bot_legselect_s1_address,
      chipselect => pio_bot_legselect_s1_chipselect,
      clk => clk_100,
      reset_n => pio_bot_legselect_s1_reset_n,
      write_n => pio_bot_legselect_s1_write_n,
      writedata => pio_bot_legselect_s1_writedata
    );


  --the_pio_bot_reset_s1, which is an e_instance
  the_pio_bot_reset_s1 : pio_bot_reset_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_reset_s1 => cpu_data_master_granted_pio_bot_reset_s1,
      cpu_data_master_qualified_request_pio_bot_reset_s1 => cpu_data_master_qualified_request_pio_bot_reset_s1,
      cpu_data_master_read_data_valid_pio_bot_reset_s1 => cpu_data_master_read_data_valid_pio_bot_reset_s1,
      cpu_data_master_requests_pio_bot_reset_s1 => cpu_data_master_requests_pio_bot_reset_s1,
      d1_pio_bot_reset_s1_end_xfer => d1_pio_bot_reset_s1_end_xfer,
      pio_bot_reset_s1_address => pio_bot_reset_s1_address,
      pio_bot_reset_s1_chipselect => pio_bot_reset_s1_chipselect,
      pio_bot_reset_s1_readdata_from_sa => pio_bot_reset_s1_readdata_from_sa,
      pio_bot_reset_s1_reset_n => pio_bot_reset_s1_reset_n,
      pio_bot_reset_s1_write_n => pio_bot_reset_s1_write_n,
      pio_bot_reset_s1_writedata => pio_bot_reset_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_bot_reset_s1_readdata => pio_bot_reset_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_reset, which is an e_ptf_instance
  the_pio_bot_reset : pio_bot_reset
    port map(
      out_port => internal_out_port_from_the_pio_bot_reset,
      readdata => pio_bot_reset_s1_readdata,
      address => pio_bot_reset_s1_address,
      chipselect => pio_bot_reset_s1_chipselect,
      clk => clk_100,
      reset_n => pio_bot_reset_s1_reset_n,
      write_n => pio_bot_reset_s1_write_n,
      writedata => pio_bot_reset_s1_writedata
    );


  --the_pio_bot_updateflag_s1, which is an e_instance
  the_pio_bot_updateflag_s1 : pio_bot_updateflag_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_updateflag_s1 => cpu_data_master_granted_pio_bot_updateflag_s1,
      cpu_data_master_qualified_request_pio_bot_updateflag_s1 => cpu_data_master_qualified_request_pio_bot_updateflag_s1,
      cpu_data_master_read_data_valid_pio_bot_updateflag_s1 => cpu_data_master_read_data_valid_pio_bot_updateflag_s1,
      cpu_data_master_requests_pio_bot_updateflag_s1 => cpu_data_master_requests_pio_bot_updateflag_s1,
      d1_pio_bot_updateflag_s1_end_xfer => d1_pio_bot_updateflag_s1_end_xfer,
      pio_bot_updateflag_s1_address => pio_bot_updateflag_s1_address,
      pio_bot_updateflag_s1_chipselect => pio_bot_updateflag_s1_chipselect,
      pio_bot_updateflag_s1_readdata_from_sa => pio_bot_updateflag_s1_readdata_from_sa,
      pio_bot_updateflag_s1_reset_n => pio_bot_updateflag_s1_reset_n,
      pio_bot_updateflag_s1_write_n => pio_bot_updateflag_s1_write_n,
      pio_bot_updateflag_s1_writedata => pio_bot_updateflag_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_bot_updateflag_s1_readdata => pio_bot_updateflag_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_updateflag, which is an e_ptf_instance
  the_pio_bot_updateflag : pio_bot_updateflag
    port map(
      out_port => internal_out_port_from_the_pio_bot_updateflag,
      readdata => pio_bot_updateflag_s1_readdata,
      address => pio_bot_updateflag_s1_address,
      chipselect => pio_bot_updateflag_s1_chipselect,
      clk => clk_100,
      reset_n => pio_bot_updateflag_s1_reset_n,
      write_n => pio_bot_updateflag_s1_write_n,
      writedata => pio_bot_updateflag_s1_writedata
    );


  --the_pio_bot_wrcoord_s1, which is an e_instance
  the_pio_bot_wrcoord_s1 : pio_bot_wrcoord_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_wrcoord_s1 => cpu_data_master_granted_pio_bot_wrcoord_s1,
      cpu_data_master_qualified_request_pio_bot_wrcoord_s1 => cpu_data_master_qualified_request_pio_bot_wrcoord_s1,
      cpu_data_master_read_data_valid_pio_bot_wrcoord_s1 => cpu_data_master_read_data_valid_pio_bot_wrcoord_s1,
      cpu_data_master_requests_pio_bot_wrcoord_s1 => cpu_data_master_requests_pio_bot_wrcoord_s1,
      d1_pio_bot_wrcoord_s1_end_xfer => d1_pio_bot_wrcoord_s1_end_xfer,
      pio_bot_wrcoord_s1_address => pio_bot_wrcoord_s1_address,
      pio_bot_wrcoord_s1_chipselect => pio_bot_wrcoord_s1_chipselect,
      pio_bot_wrcoord_s1_readdata_from_sa => pio_bot_wrcoord_s1_readdata_from_sa,
      pio_bot_wrcoord_s1_reset_n => pio_bot_wrcoord_s1_reset_n,
      pio_bot_wrcoord_s1_write_n => pio_bot_wrcoord_s1_write_n,
      pio_bot_wrcoord_s1_writedata => pio_bot_wrcoord_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_bot_wrcoord_s1_readdata => pio_bot_wrcoord_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_wrcoord, which is an e_ptf_instance
  the_pio_bot_wrcoord : pio_bot_wrcoord
    port map(
      out_port => internal_out_port_from_the_pio_bot_wrcoord,
      readdata => pio_bot_wrcoord_s1_readdata,
      address => pio_bot_wrcoord_s1_address,
      chipselect => pio_bot_wrcoord_s1_chipselect,
      clk => clk_100,
      reset_n => pio_bot_wrcoord_s1_reset_n,
      write_n => pio_bot_wrcoord_s1_write_n,
      writedata => pio_bot_wrcoord_s1_writedata
    );


  --the_pio_bot_x_s1, which is an e_instance
  the_pio_bot_x_s1 : pio_bot_x_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_x_s1 => cpu_data_master_granted_pio_bot_x_s1,
      cpu_data_master_qualified_request_pio_bot_x_s1 => cpu_data_master_qualified_request_pio_bot_x_s1,
      cpu_data_master_read_data_valid_pio_bot_x_s1 => cpu_data_master_read_data_valid_pio_bot_x_s1,
      cpu_data_master_requests_pio_bot_x_s1 => cpu_data_master_requests_pio_bot_x_s1,
      d1_pio_bot_x_s1_end_xfer => d1_pio_bot_x_s1_end_xfer,
      pio_bot_x_s1_address => pio_bot_x_s1_address,
      pio_bot_x_s1_chipselect => pio_bot_x_s1_chipselect,
      pio_bot_x_s1_readdata_from_sa => pio_bot_x_s1_readdata_from_sa,
      pio_bot_x_s1_reset_n => pio_bot_x_s1_reset_n,
      pio_bot_x_s1_write_n => pio_bot_x_s1_write_n,
      pio_bot_x_s1_writedata => pio_bot_x_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_bot_x_s1_readdata => pio_bot_x_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_x, which is an e_ptf_instance
  the_pio_bot_x : pio_bot_x
    port map(
      out_port => internal_out_port_from_the_pio_bot_x,
      readdata => pio_bot_x_s1_readdata,
      address => pio_bot_x_s1_address,
      chipselect => pio_bot_x_s1_chipselect,
      clk => clk_100,
      reset_n => pio_bot_x_s1_reset_n,
      write_n => pio_bot_x_s1_write_n,
      writedata => pio_bot_x_s1_writedata
    );


  --the_pio_bot_y_s1, which is an e_instance
  the_pio_bot_y_s1 : pio_bot_y_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_y_s1 => cpu_data_master_granted_pio_bot_y_s1,
      cpu_data_master_qualified_request_pio_bot_y_s1 => cpu_data_master_qualified_request_pio_bot_y_s1,
      cpu_data_master_read_data_valid_pio_bot_y_s1 => cpu_data_master_read_data_valid_pio_bot_y_s1,
      cpu_data_master_requests_pio_bot_y_s1 => cpu_data_master_requests_pio_bot_y_s1,
      d1_pio_bot_y_s1_end_xfer => d1_pio_bot_y_s1_end_xfer,
      pio_bot_y_s1_address => pio_bot_y_s1_address,
      pio_bot_y_s1_chipselect => pio_bot_y_s1_chipselect,
      pio_bot_y_s1_readdata_from_sa => pio_bot_y_s1_readdata_from_sa,
      pio_bot_y_s1_reset_n => pio_bot_y_s1_reset_n,
      pio_bot_y_s1_write_n => pio_bot_y_s1_write_n,
      pio_bot_y_s1_writedata => pio_bot_y_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_bot_y_s1_readdata => pio_bot_y_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_y, which is an e_ptf_instance
  the_pio_bot_y : pio_bot_y
    port map(
      out_port => internal_out_port_from_the_pio_bot_y,
      readdata => pio_bot_y_s1_readdata,
      address => pio_bot_y_s1_address,
      chipselect => pio_bot_y_s1_chipselect,
      clk => clk_100,
      reset_n => pio_bot_y_s1_reset_n,
      write_n => pio_bot_y_s1_write_n,
      writedata => pio_bot_y_s1_writedata
    );


  --the_pio_bot_z_s1, which is an e_instance
  the_pio_bot_z_s1 : pio_bot_z_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_bot_z_s1 => cpu_data_master_granted_pio_bot_z_s1,
      cpu_data_master_qualified_request_pio_bot_z_s1 => cpu_data_master_qualified_request_pio_bot_z_s1,
      cpu_data_master_read_data_valid_pio_bot_z_s1 => cpu_data_master_read_data_valid_pio_bot_z_s1,
      cpu_data_master_requests_pio_bot_z_s1 => cpu_data_master_requests_pio_bot_z_s1,
      d1_pio_bot_z_s1_end_xfer => d1_pio_bot_z_s1_end_xfer,
      pio_bot_z_s1_address => pio_bot_z_s1_address,
      pio_bot_z_s1_chipselect => pio_bot_z_s1_chipselect,
      pio_bot_z_s1_readdata_from_sa => pio_bot_z_s1_readdata_from_sa,
      pio_bot_z_s1_reset_n => pio_bot_z_s1_reset_n,
      pio_bot_z_s1_write_n => pio_bot_z_s1_write_n,
      pio_bot_z_s1_writedata => pio_bot_z_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_bot_z_s1_readdata => pio_bot_z_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_bot_z, which is an e_ptf_instance
  the_pio_bot_z : pio_bot_z
    port map(
      out_port => internal_out_port_from_the_pio_bot_z,
      readdata => pio_bot_z_s1_readdata,
      address => pio_bot_z_s1_address,
      chipselect => pio_bot_z_s1_chipselect,
      clk => clk_100,
      reset_n => pio_bot_z_s1_reset_n,
      write_n => pio_bot_z_s1_write_n,
      writedata => pio_bot_z_s1_writedata
    );


  --the_pio_led_s1, which is an e_instance
  the_pio_led_s1 : pio_led_s1_arbitrator
    port map(
      cpu_data_master_granted_pio_led_s1 => cpu_data_master_granted_pio_led_s1,
      cpu_data_master_qualified_request_pio_led_s1 => cpu_data_master_qualified_request_pio_led_s1,
      cpu_data_master_read_data_valid_pio_led_s1 => cpu_data_master_read_data_valid_pio_led_s1,
      cpu_data_master_requests_pio_led_s1 => cpu_data_master_requests_pio_led_s1,
      d1_pio_led_s1_end_xfer => d1_pio_led_s1_end_xfer,
      pio_led_s1_address => pio_led_s1_address,
      pio_led_s1_chipselect => pio_led_s1_chipselect,
      pio_led_s1_readdata_from_sa => pio_led_s1_readdata_from_sa,
      pio_led_s1_reset_n => pio_led_s1_reset_n,
      pio_led_s1_write_n => pio_led_s1_write_n,
      pio_led_s1_writedata => pio_led_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      pio_led_s1_readdata => pio_led_s1_readdata,
      reset_n => clk_100_reset_n
    );


  --the_pio_led, which is an e_ptf_instance
  the_pio_led : pio_led
    port map(
      out_port => internal_out_port_from_the_pio_led,
      readdata => pio_led_s1_readdata,
      address => pio_led_s1_address,
      chipselect => pio_led_s1_chipselect,
      clk => clk_100,
      reset_n => pio_led_s1_reset_n,
      write_n => pio_led_s1_write_n,
      writedata => pio_led_s1_writedata
    );


  --the_sdram_s1, which is an e_instance
  the_sdram_s1 : sdram_s1_arbitrator
    port map(
      Teste_SOPC_clock_0_out_granted_sdram_s1 => Teste_SOPC_clock_0_out_granted_sdram_s1,
      Teste_SOPC_clock_0_out_qualified_request_sdram_s1 => Teste_SOPC_clock_0_out_qualified_request_sdram_s1,
      Teste_SOPC_clock_0_out_read_data_valid_sdram_s1 => Teste_SOPC_clock_0_out_read_data_valid_sdram_s1,
      Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register => Teste_SOPC_clock_0_out_read_data_valid_sdram_s1_shift_register,
      Teste_SOPC_clock_0_out_requests_sdram_s1 => Teste_SOPC_clock_0_out_requests_sdram_s1,
      Teste_SOPC_clock_1_out_granted_sdram_s1 => Teste_SOPC_clock_1_out_granted_sdram_s1,
      Teste_SOPC_clock_1_out_qualified_request_sdram_s1 => Teste_SOPC_clock_1_out_qualified_request_sdram_s1,
      Teste_SOPC_clock_1_out_read_data_valid_sdram_s1 => Teste_SOPC_clock_1_out_read_data_valid_sdram_s1,
      Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register => Teste_SOPC_clock_1_out_read_data_valid_sdram_s1_shift_register,
      Teste_SOPC_clock_1_out_requests_sdram_s1 => Teste_SOPC_clock_1_out_requests_sdram_s1,
      d1_sdram_s1_end_xfer => d1_sdram_s1_end_xfer,
      sdram_s1_address => sdram_s1_address,
      sdram_s1_byteenable_n => sdram_s1_byteenable_n,
      sdram_s1_chipselect => sdram_s1_chipselect,
      sdram_s1_read_n => sdram_s1_read_n,
      sdram_s1_readdata_from_sa => sdram_s1_readdata_from_sa,
      sdram_s1_reset_n => sdram_s1_reset_n,
      sdram_s1_waitrequest_from_sa => sdram_s1_waitrequest_from_sa,
      sdram_s1_write_n => sdram_s1_write_n,
      sdram_s1_writedata => sdram_s1_writedata,
      Teste_SOPC_clock_0_out_address_to_slave => Teste_SOPC_clock_0_out_address_to_slave,
      Teste_SOPC_clock_0_out_byteenable => Teste_SOPC_clock_0_out_byteenable,
      Teste_SOPC_clock_0_out_read => Teste_SOPC_clock_0_out_read,
      Teste_SOPC_clock_0_out_write => Teste_SOPC_clock_0_out_write,
      Teste_SOPC_clock_0_out_writedata => Teste_SOPC_clock_0_out_writedata,
      Teste_SOPC_clock_1_out_address_to_slave => Teste_SOPC_clock_1_out_address_to_slave,
      Teste_SOPC_clock_1_out_byteenable => Teste_SOPC_clock_1_out_byteenable,
      Teste_SOPC_clock_1_out_read => Teste_SOPC_clock_1_out_read,
      Teste_SOPC_clock_1_out_write => Teste_SOPC_clock_1_out_write,
      Teste_SOPC_clock_1_out_writedata => Teste_SOPC_clock_1_out_writedata,
      clk => internal_altpll_sdram_c0,
      reset_n => altpll_sdram_c0_reset_n,
      sdram_s1_readdata => sdram_s1_readdata,
      sdram_s1_readdatavalid => sdram_s1_readdatavalid,
      sdram_s1_waitrequest => sdram_s1_waitrequest
    );


  --the_sdram, which is an e_ptf_instance
  the_sdram : sdram
    port map(
      za_data => sdram_s1_readdata,
      za_valid => sdram_s1_readdatavalid,
      za_waitrequest => sdram_s1_waitrequest,
      zs_addr => internal_zs_addr_from_the_sdram,
      zs_ba => internal_zs_ba_from_the_sdram,
      zs_cas_n => internal_zs_cas_n_from_the_sdram,
      zs_cke => internal_zs_cke_from_the_sdram,
      zs_cs_n => internal_zs_cs_n_from_the_sdram,
      zs_dq => zs_dq_to_and_from_the_sdram,
      zs_dqm => internal_zs_dqm_from_the_sdram,
      zs_ras_n => internal_zs_ras_n_from_the_sdram,
      zs_we_n => internal_zs_we_n_from_the_sdram,
      az_addr => sdram_s1_address,
      az_be_n => sdram_s1_byteenable_n,
      az_cs => sdram_s1_chipselect,
      az_data => sdram_s1_writedata,
      az_rd_n => sdram_s1_read_n,
      az_wr_n => sdram_s1_write_n,
      clk => internal_altpll_sdram_c0,
      reset_n => sdram_s1_reset_n
    );


  --the_spi_spi_control_port, which is an e_instance
  the_spi_spi_control_port : spi_spi_control_port_arbitrator
    port map(
      cpu_data_master_granted_spi_spi_control_port => cpu_data_master_granted_spi_spi_control_port,
      cpu_data_master_qualified_request_spi_spi_control_port => cpu_data_master_qualified_request_spi_spi_control_port,
      cpu_data_master_read_data_valid_spi_spi_control_port => cpu_data_master_read_data_valid_spi_spi_control_port,
      cpu_data_master_requests_spi_spi_control_port => cpu_data_master_requests_spi_spi_control_port,
      d1_spi_spi_control_port_end_xfer => d1_spi_spi_control_port_end_xfer,
      spi_spi_control_port_address => spi_spi_control_port_address,
      spi_spi_control_port_chipselect => spi_spi_control_port_chipselect,
      spi_spi_control_port_dataavailable_from_sa => spi_spi_control_port_dataavailable_from_sa,
      spi_spi_control_port_endofpacket_from_sa => spi_spi_control_port_endofpacket_from_sa,
      spi_spi_control_port_irq_from_sa => spi_spi_control_port_irq_from_sa,
      spi_spi_control_port_read_n => spi_spi_control_port_read_n,
      spi_spi_control_port_readdata_from_sa => spi_spi_control_port_readdata_from_sa,
      spi_spi_control_port_readyfordata_from_sa => spi_spi_control_port_readyfordata_from_sa,
      spi_spi_control_port_reset_n => spi_spi_control_port_reset_n,
      spi_spi_control_port_write_n => spi_spi_control_port_write_n,
      spi_spi_control_port_writedata => spi_spi_control_port_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_100_reset_n,
      spi_spi_control_port_dataavailable => spi_spi_control_port_dataavailable,
      spi_spi_control_port_endofpacket => spi_spi_control_port_endofpacket,
      spi_spi_control_port_irq => spi_spi_control_port_irq,
      spi_spi_control_port_readdata => spi_spi_control_port_readdata,
      spi_spi_control_port_readyfordata => spi_spi_control_port_readyfordata
    );


  --the_spi, which is an e_ptf_instance
  the_spi : spi
    port map(
      MOSI => internal_MOSI_from_the_spi,
      SCLK => internal_SCLK_from_the_spi,
      SS_n => internal_SS_n_from_the_spi,
      data_to_cpu => spi_spi_control_port_readdata,
      dataavailable => spi_spi_control_port_dataavailable,
      endofpacket => spi_spi_control_port_endofpacket,
      irq => spi_spi_control_port_irq,
      readyfordata => spi_spi_control_port_readyfordata,
      MISO => MISO_to_the_spi,
      clk => clk_100,
      data_from_cpu => spi_spi_control_port_writedata,
      mem_addr => spi_spi_control_port_address,
      read_n => spi_spi_control_port_read_n,
      reset_n => spi_spi_control_port_reset_n,
      spi_select => spi_spi_control_port_chipselect,
      write_n => spi_spi_control_port_write_n
    );


  --the_timer_sys_s1, which is an e_instance
  the_timer_sys_s1 : timer_sys_s1_arbitrator
    port map(
      cpu_data_master_granted_timer_sys_s1 => cpu_data_master_granted_timer_sys_s1,
      cpu_data_master_qualified_request_timer_sys_s1 => cpu_data_master_qualified_request_timer_sys_s1,
      cpu_data_master_read_data_valid_timer_sys_s1 => cpu_data_master_read_data_valid_timer_sys_s1,
      cpu_data_master_requests_timer_sys_s1 => cpu_data_master_requests_timer_sys_s1,
      d1_timer_sys_s1_end_xfer => d1_timer_sys_s1_end_xfer,
      timer_sys_s1_address => timer_sys_s1_address,
      timer_sys_s1_chipselect => timer_sys_s1_chipselect,
      timer_sys_s1_irq_from_sa => timer_sys_s1_irq_from_sa,
      timer_sys_s1_readdata_from_sa => timer_sys_s1_readdata_from_sa,
      timer_sys_s1_reset_n => timer_sys_s1_reset_n,
      timer_sys_s1_write_n => timer_sys_s1_write_n,
      timer_sys_s1_writedata => timer_sys_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_100_reset_n,
      timer_sys_s1_irq => timer_sys_s1_irq,
      timer_sys_s1_readdata => timer_sys_s1_readdata
    );


  --the_timer_sys, which is an e_ptf_instance
  the_timer_sys : timer_sys
    port map(
      irq => timer_sys_s1_irq,
      readdata => timer_sys_s1_readdata,
      address => timer_sys_s1_address,
      chipselect => timer_sys_s1_chipselect,
      clk => clk_100,
      reset_n => timer_sys_s1_reset_n,
      write_n => timer_sys_s1_write_n,
      writedata => timer_sys_s1_writedata
    );


  --the_uart_s1, which is an e_instance
  the_uart_s1 : uart_s1_arbitrator
    port map(
      cpu_data_master_granted_uart_s1 => cpu_data_master_granted_uart_s1,
      cpu_data_master_qualified_request_uart_s1 => cpu_data_master_qualified_request_uart_s1,
      cpu_data_master_read_data_valid_uart_s1 => cpu_data_master_read_data_valid_uart_s1,
      cpu_data_master_requests_uart_s1 => cpu_data_master_requests_uart_s1,
      d1_uart_s1_end_xfer => d1_uart_s1_end_xfer,
      uart_s1_address => uart_s1_address,
      uart_s1_begintransfer => uart_s1_begintransfer,
      uart_s1_chipselect => uart_s1_chipselect,
      uart_s1_dataavailable_from_sa => uart_s1_dataavailable_from_sa,
      uart_s1_irq_from_sa => uart_s1_irq_from_sa,
      uart_s1_read_n => uart_s1_read_n,
      uart_s1_readdata_from_sa => uart_s1_readdata_from_sa,
      uart_s1_readyfordata_from_sa => uart_s1_readyfordata_from_sa,
      uart_s1_reset_n => uart_s1_reset_n,
      uart_s1_write_n => uart_s1_write_n,
      uart_s1_writedata => uart_s1_writedata,
      clk => clk_100,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_100_reset_n,
      uart_s1_dataavailable => uart_s1_dataavailable,
      uart_s1_irq => uart_s1_irq,
      uart_s1_readdata => uart_s1_readdata,
      uart_s1_readyfordata => uart_s1_readyfordata
    );


  --the_uart, which is an e_ptf_instance
  the_uart : uart
    port map(
      dataavailable => uart_s1_dataavailable,
      irq => uart_s1_irq,
      readdata => uart_s1_readdata,
      readyfordata => uart_s1_readyfordata,
      txd => internal_txd_from_the_uart,
      address => uart_s1_address,
      begintransfer => uart_s1_begintransfer,
      chipselect => uart_s1_chipselect,
      clk => clk_100,
      read_n => uart_s1_read_n,
      reset_n => uart_s1_reset_n,
      rxd => rxd_to_the_uart,
      write_n => uart_s1_write_n,
      writedata => uart_s1_writedata
    );


  --reset is asserted asynchronously and deasserted synchronously
  Teste_SOPC_reset_clk_100_domain_synch : Teste_SOPC_reset_clk_100_domain_synch_module
    port map(
      data_out => clk_100_reset_n,
      clk => clk_100,
      data_in => module_input6,
      reset_n => reset_n_sources
    );

  module_input6 <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT ((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_resetrequest_from_sa)))) OR std_logic_vector'("00000000000000000000000000000000"))));
  --reset is asserted asynchronously and deasserted synchronously
  Teste_SOPC_reset_altpll_sdram_c0_domain_synch : Teste_SOPC_reset_altpll_sdram_c0_domain_synch_module
    port map(
      data_out => altpll_sdram_c0_reset_n,
      clk => internal_altpll_sdram_c0,
      data_in => module_input7,
      reset_n => reset_n_sources
    );

  module_input7 <= std_logic'('1');

  --Teste_SOPC_clock_0_in_writedata of type writedata does not connect to anything so wire it to default (0)
  Teste_SOPC_clock_0_in_writedata <= std_logic_vector'("0000000000000000");
  --Teste_SOPC_clock_0_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  Teste_SOPC_clock_0_out_endofpacket <= std_logic'('0');
  --Teste_SOPC_clock_1_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  Teste_SOPC_clock_1_out_endofpacket <= std_logic'('0');
  --vhdl renameroo for output signals
  MOSI_from_the_spi <= internal_MOSI_from_the_spi;
  --vhdl renameroo for output signals
  SCLK_from_the_spi <= internal_SCLK_from_the_spi;
  --vhdl renameroo for output signals
  SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0 <= internal_SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0;
  --vhdl renameroo for output signals
  SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0 <= internal_SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0;
  --vhdl renameroo for output signals
  SS_n_from_the_spi <= internal_SS_n_from_the_spi;
  --vhdl renameroo for output signals
  altpll_sdram_c0 <= internal_altpll_sdram_c0;
  --vhdl renameroo for output signals
  locked_from_the_altpll_sdram <= internal_locked_from_the_altpll_sdram;
  --vhdl renameroo for output signals
  out_port_from_the_pio_bot_legselect <= internal_out_port_from_the_pio_bot_legselect;
  --vhdl renameroo for output signals
  out_port_from_the_pio_bot_reset <= internal_out_port_from_the_pio_bot_reset;
  --vhdl renameroo for output signals
  out_port_from_the_pio_bot_updateflag <= internal_out_port_from_the_pio_bot_updateflag;
  --vhdl renameroo for output signals
  out_port_from_the_pio_bot_wrcoord <= internal_out_port_from_the_pio_bot_wrcoord;
  --vhdl renameroo for output signals
  out_port_from_the_pio_bot_x <= internal_out_port_from_the_pio_bot_x;
  --vhdl renameroo for output signals
  out_port_from_the_pio_bot_y <= internal_out_port_from_the_pio_bot_y;
  --vhdl renameroo for output signals
  out_port_from_the_pio_bot_z <= internal_out_port_from_the_pio_bot_z;
  --vhdl renameroo for output signals
  out_port_from_the_pio_led <= internal_out_port_from_the_pio_led;
  --vhdl renameroo for output signals
  phasedone_from_the_altpll_sdram <= internal_phasedone_from_the_altpll_sdram;
  --vhdl renameroo for output signals
  txd_from_the_uart <= internal_txd_from_the_uart;
  --vhdl renameroo for output signals
  zs_addr_from_the_sdram <= internal_zs_addr_from_the_sdram;
  --vhdl renameroo for output signals
  zs_ba_from_the_sdram <= internal_zs_ba_from_the_sdram;
  --vhdl renameroo for output signals
  zs_cas_n_from_the_sdram <= internal_zs_cas_n_from_the_sdram;
  --vhdl renameroo for output signals
  zs_cke_from_the_sdram <= internal_zs_cke_from_the_sdram;
  --vhdl renameroo for output signals
  zs_cs_n_from_the_sdram <= internal_zs_cs_n_from_the_sdram;
  --vhdl renameroo for output signals
  zs_dqm_from_the_sdram <= internal_zs_dqm_from_the_sdram;
  --vhdl renameroo for output signals
  zs_ras_n_from_the_sdram <= internal_zs_ras_n_from_the_sdram;
  --vhdl renameroo for output signals
  zs_we_n_from_the_sdram <= internal_zs_we_n_from_the_sdram;

end europa;


--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your libraries here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>

entity test_bench is 
end entity test_bench;


architecture europa of test_bench is
component Teste_SOPC is 
           port (
                 -- 1) global signals:
                    signal altpll_sdram_c0 : OUT STD_LOGIC;
                    signal clk_100 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_I2C_Master
                    signal scl_pad_io_to_and_from_the_I2C_Master : INOUT STD_LOGIC;
                    signal sda_pad_io_to_and_from_the_I2C_Master : INOUT STD_LOGIC;

                 -- the_TERASIC_SPI_3WIRE_0
                    signal SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0 : OUT STD_LOGIC;
                    signal SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0 : OUT STD_LOGIC;
                    signal SPI_SDIO_to_and_from_the_TERASIC_SPI_3WIRE_0 : INOUT STD_LOGIC;

                 -- the_altpll_sdram
                    signal areset_to_the_altpll_sdram : IN STD_LOGIC;
                    signal locked_from_the_altpll_sdram : OUT STD_LOGIC;
                    signal phasedone_from_the_altpll_sdram : OUT STD_LOGIC;

                 -- the_pio_bot_endcalc
                    signal in_port_to_the_pio_bot_endcalc : IN STD_LOGIC;

                 -- the_pio_bot_legselect
                    signal out_port_from_the_pio_bot_legselect : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);

                 -- the_pio_bot_reset
                    signal out_port_from_the_pio_bot_reset : OUT STD_LOGIC;

                 -- the_pio_bot_updateflag
                    signal out_port_from_the_pio_bot_updateflag : OUT STD_LOGIC;

                 -- the_pio_bot_wrcoord
                    signal out_port_from_the_pio_bot_wrcoord : OUT STD_LOGIC;

                 -- the_pio_bot_x
                    signal out_port_from_the_pio_bot_x : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- the_pio_bot_y
                    signal out_port_from_the_pio_bot_y : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- the_pio_bot_z
                    signal out_port_from_the_pio_bot_z : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- the_pio_led
                    signal out_port_from_the_pio_led : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_sdram
                    signal zs_addr_from_the_sdram : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal zs_ba_from_the_sdram : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal zs_cas_n_from_the_sdram : OUT STD_LOGIC;
                    signal zs_cke_from_the_sdram : OUT STD_LOGIC;
                    signal zs_cs_n_from_the_sdram : OUT STD_LOGIC;
                    signal zs_dq_to_and_from_the_sdram : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal zs_dqm_from_the_sdram : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal zs_ras_n_from_the_sdram : OUT STD_LOGIC;
                    signal zs_we_n_from_the_sdram : OUT STD_LOGIC;

                 -- the_spi
                    signal MISO_to_the_spi : IN STD_LOGIC;
                    signal MOSI_from_the_spi : OUT STD_LOGIC;
                    signal SCLK_from_the_spi : OUT STD_LOGIC;
                    signal SS_n_from_the_spi : OUT STD_LOGIC;

                 -- the_uart
                    signal rxd_to_the_uart : IN STD_LOGIC;
                    signal txd_from_the_uart : OUT STD_LOGIC
                 );
end component Teste_SOPC;

                signal MISO_to_the_spi :  STD_LOGIC;
                signal MOSI_from_the_spi :  STD_LOGIC;
                signal SCLK_from_the_spi :  STD_LOGIC;
                signal SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0 :  STD_LOGIC;
                signal SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0 :  STD_LOGIC;
                signal SPI_SDIO_to_and_from_the_TERASIC_SPI_3WIRE_0 :  STD_LOGIC;
                signal SS_n_from_the_spi :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal Teste_SOPC_clock_0_in_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Teste_SOPC_clock_0_out_endofpacket :  STD_LOGIC;
                signal Teste_SOPC_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal Teste_SOPC_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_endofpacket :  STD_LOGIC;
                signal Teste_SOPC_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal altpll_sdram_c0 :  STD_LOGIC;
                signal areset_to_the_altpll_sdram :  STD_LOGIC;
                signal clk :  STD_LOGIC;
                signal clk_100 :  STD_LOGIC;
                signal in_port_to_the_pio_bot_endcalc :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal locked_from_the_altpll_sdram :  STD_LOGIC;
                signal out_port_from_the_pio_bot_legselect :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal out_port_from_the_pio_bot_reset :  STD_LOGIC;
                signal out_port_from_the_pio_bot_updateflag :  STD_LOGIC;
                signal out_port_from_the_pio_bot_wrcoord :  STD_LOGIC;
                signal out_port_from_the_pio_bot_x :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal out_port_from_the_pio_bot_y :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal out_port_from_the_pio_bot_z :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal out_port_from_the_pio_led :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal phasedone_from_the_altpll_sdram :  STD_LOGIC;
                signal reset_n :  STD_LOGIC;
                signal rxd_to_the_uart :  STD_LOGIC;
                signal scl_pad_io_to_and_from_the_I2C_Master :  STD_LOGIC;
                signal sda_pad_io_to_and_from_the_I2C_Master :  STD_LOGIC;
                signal spi_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal spi_spi_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal spi_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal txd_from_the_uart :  STD_LOGIC;
                signal uart_s1_dataavailable_from_sa :  STD_LOGIC;
                signal uart_s1_readyfordata_from_sa :  STD_LOGIC;
                signal zs_addr_from_the_sdram :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal zs_ba_from_the_sdram :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal zs_cas_n_from_the_sdram :  STD_LOGIC;
                signal zs_cke_from_the_sdram :  STD_LOGIC;
                signal zs_cs_n_from_the_sdram :  STD_LOGIC;
                signal zs_dq_to_and_from_the_sdram :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal zs_dqm_from_the_sdram :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal zs_ras_n_from_the_sdram :  STD_LOGIC;
                signal zs_we_n_from_the_sdram :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : Teste_SOPC
    port map(
      MOSI_from_the_spi => MOSI_from_the_spi,
      SCLK_from_the_spi => SCLK_from_the_spi,
      SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0 => SPI_CS_n_from_the_TERASIC_SPI_3WIRE_0,
      SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0 => SPI_SCLK_from_the_TERASIC_SPI_3WIRE_0,
      SPI_SDIO_to_and_from_the_TERASIC_SPI_3WIRE_0 => SPI_SDIO_to_and_from_the_TERASIC_SPI_3WIRE_0,
      SS_n_from_the_spi => SS_n_from_the_spi,
      altpll_sdram_c0 => altpll_sdram_c0,
      locked_from_the_altpll_sdram => locked_from_the_altpll_sdram,
      out_port_from_the_pio_bot_legselect => out_port_from_the_pio_bot_legselect,
      out_port_from_the_pio_bot_reset => out_port_from_the_pio_bot_reset,
      out_port_from_the_pio_bot_updateflag => out_port_from_the_pio_bot_updateflag,
      out_port_from_the_pio_bot_wrcoord => out_port_from_the_pio_bot_wrcoord,
      out_port_from_the_pio_bot_x => out_port_from_the_pio_bot_x,
      out_port_from_the_pio_bot_y => out_port_from_the_pio_bot_y,
      out_port_from_the_pio_bot_z => out_port_from_the_pio_bot_z,
      out_port_from_the_pio_led => out_port_from_the_pio_led,
      phasedone_from_the_altpll_sdram => phasedone_from_the_altpll_sdram,
      scl_pad_io_to_and_from_the_I2C_Master => scl_pad_io_to_and_from_the_I2C_Master,
      sda_pad_io_to_and_from_the_I2C_Master => sda_pad_io_to_and_from_the_I2C_Master,
      txd_from_the_uart => txd_from_the_uart,
      zs_addr_from_the_sdram => zs_addr_from_the_sdram,
      zs_ba_from_the_sdram => zs_ba_from_the_sdram,
      zs_cas_n_from_the_sdram => zs_cas_n_from_the_sdram,
      zs_cke_from_the_sdram => zs_cke_from_the_sdram,
      zs_cs_n_from_the_sdram => zs_cs_n_from_the_sdram,
      zs_dq_to_and_from_the_sdram => zs_dq_to_and_from_the_sdram,
      zs_dqm_from_the_sdram => zs_dqm_from_the_sdram,
      zs_ras_n_from_the_sdram => zs_ras_n_from_the_sdram,
      zs_we_n_from_the_sdram => zs_we_n_from_the_sdram,
      MISO_to_the_spi => MISO_to_the_spi,
      areset_to_the_altpll_sdram => areset_to_the_altpll_sdram,
      clk_100 => clk_100,
      in_port_to_the_pio_bot_endcalc => in_port_to_the_pio_bot_endcalc,
      reset_n => reset_n,
      rxd_to_the_uart => rxd_to_the_uart
    );


  process
  begin
    clk_100 <= '0';
    loop
       wait for 5 ns;
       clk_100 <= not clk_100;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 100 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
