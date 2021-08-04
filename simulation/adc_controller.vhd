-- DE10-Lite ADC implementation that maps the top 8 bits of each ADC

library ieee;
use ieee.std_logic_1164.all;

architecture impl of ADC_dummy is
	signal channel0, channel1, channel2, channel3, channel4, channel5 : std_logic_vector(11 downto 0);
begin
	adc : ieee.adc
		port map (
			CLOCK => adc_clk,
			RESET => '0',
			CH0 => channel0,
			CH1 => channel1,
			CH2 => channel2,
			CH3 => channel3,
			CH4 => channel4,
			CH5 => channel5
		);
	
	ch0 <= channel0(11 downto 4);
	ch1 <= channel1(11 downto 4);
	ch2 <= channel2(11 downto 4);
	ch3 <= channel3(11 downto 4);
	ch4 <= channel4(11 downto 4);
	ch5 <= channel5(11 downto 4);
end architecture;
