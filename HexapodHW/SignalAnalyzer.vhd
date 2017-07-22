-- Copyright (c) 2012, Felipe Michels Fontoura

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Medidor genérico de PWM.
-- OBS1: a contagem só é realizada quando há pulsos: isso significa que o componente não mede pulsos de largura zero.
entity SignalAnalyzer is
	generic (
		-- período máximo
		-- a unidade de medida do período é ciclos de clock.
		MaxPeriod: integer := 1000;

		-- largura do barramento com o período
		WidthOfPeriod: integer := 10
	);
	port (
		-- clock de entrada
		ClockIn : in bit;

		-- sinal de entrada
		SignalIn : in bit;

		-- largura de pulso, em ciclos de clock
		PeriodOut: buffer std_logic_vector(WidthOfPeriod - 1 downto 0);

		-- período, em ciclos de clock.
		PulseWidthOut: buffer std_logic_vector(WidthOfPeriod - 1 downto 0)
	);
end SignalAnalyzer;

architecture ArchitectureOfSignalAnalyzer of SignalAnalyzer is
	-- contador de pulso (quando chega a zero, o pulso terminou).
	signal Counter: integer range 0 to MaxPeriod;

	-- valor atual do status (1 = em alta, 0 = em baixa).
	signal SignalStatus: bit;

	-- valor atual do status (1 = em alta, 0 = em baixa).
	signal Status: bit;

begin

	process (ClockIn)
	begin

		if (ClockIn'event and ClockIn = '1') then

			SignalStatus <= SignalIn;
			if (SignalStatus /= Status) then
				
				-- se é borda de descida, atualiza a saída.
				if (Status = '1') then
					PulseWidthOut <= conv_std_logic_vector(Counter, WidthOfPeriod);
					Counter <= Counter + 1;
				else
					PeriodOut <= conv_std_logic_vector(Counter, WidthOfPeriod);
					Counter <= 1;
				end if;

			elsif (Counter = MaxPeriod) then

				-- se der overflow, para de contar.
				if (Status = '1') then
					PulseWidthOut <= conv_std_logic_vector(Counter, WidthOfPeriod);
					PeriodOut <= conv_std_logic_vector(Counter, WidthOfPeriod);
				else
					PulseWidthOut <= conv_std_logic_vector(0, WidthOfPeriod);
					PeriodOut <= conv_std_logic_vector(0, WidthOfPeriod);
				end if;

			else

				-- se estiver ok, continua contando.
				Counter <= Counter + 1;

			end if;

			-- salva o valor atual do sinal.
			Status <= SignalStatus;

		end if;

	end process;

end ArchitectureOfSignalAnalyzer;
