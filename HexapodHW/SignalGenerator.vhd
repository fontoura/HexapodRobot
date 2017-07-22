-- Copyright (c) 2012, Felipe Michels Fontoura

library ieee;

use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Gerador gen�rico de sinais.
-- OBS1: com PulseWidth = 0, o sinal fica sempre em baixa.
-- OBS2: com PulseWidth >= Period, o sinal fica sempre em alta.
entity SignalGenerator is
	generic (
		-- largura do barramento com o per�odo
		WidthOfPulse: integer := 10;
		WidthOfPeriod: integer := 10;
		Period : integer := 2000;
		pulse : integer := 1200;
		offset : integer := 0
	);
	port (
		-- largura de pulso, em ciclos de clock
		PulseWidthIn: in std_logic_vector((WidthOfPulse - 1) downto 0) := std_logic_vector(to_unsigned(pulse*100, WidthOfPulse));-- := std_logic_vector(to_unsigned(1, WidthOfPeriod));
		--PulseWidthIn: in std_logic_vector((WidthOfPeriod - 1) downto 0) := std_logic_vector(to_unsigned(80, WidthOfPeriod));

		-- clock de entrada
		ClockIn : in bit;

		-- sinal de saida
		SignalOutNot : out bit
		--SignalOut : buffer bit
	);
end SignalGenerator;

architecture ArchitectureOfSignalGenerator of SignalGenerator is
	-- per�odo, em ciclos de clock.
	signal PeriodIn: std_logic_vector((WidthOfPeriod - 1) downto 0) := std_logic_vector(to_unsigned(Period, WidthOfPeriod));
	
	-- contador de ciclos (quando chega a zero, recome�a).
	signal CycleCounter: integer range 0 to (2**WidthOfPeriod - 1);

	-- contador de pulso (quando chega a zero, o pulso terminou).
	signal PulseCounter: integer range 0 to (2**WidthOfPeriod - 1);
	
	signal SignalOut : bit;
begin

	process (ClockIn)
	begin
		if (ClockIn'event and ClockIn = '1') then

			if (CycleCounter = 0) then

				-- reinicia a contagem.
				CycleCounter <= conv_integer(PeriodIn) - 1;
				-- de acordo com a largura de pulso desejada, decide o que fazer.
				if (conv_integer(PulseWidthIn + offset*100) > 0) then
					-- p�e o sinal em alta e inicia a contagem regressiva.
					SignalOut <= '1';
					PulseCounter <= conv_integer(PulseWidthIn + offset*100) - 1;
				else
					-- deixa o sinal em baixa e n�o inicia a contagem regressiva.
					SignalOut <= '0';
					PulseCounter <= 0;
				end if;

			else

				-- decrementa o contador de ciclo.
				CycleCounter <= CycleCounter - 1;
				-- de acordo com o contador de ciclo, decide o que fazer.
				if (PulseCounter = 0) then
					-- p�e o sinal em baixa
					SignalOut <= '0';
					PulseCounter <= 0;
				else
					-- decrementa o contador de pulso.
					SignalOut <= '1';
					PulseCounter <= PulseCounter - 1;
				end if;

			end if;
			SignalOutNot <= not SignalOut;
		end if;
	end process;

end ArchitectureOfSignalGenerator;
