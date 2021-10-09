library ieee;
use ieee.std_logic_1164.all;

entity adc_driver is
  port (
	  clock : in std_logic;
	  reset : in std_logic;
	  ch0 : out std_logic_vector(7 downto 0);
	  ch1 : out std_logic_vector(7 downto 0);
	  ch2 : out std_logic_vector(7 downto 0);
	  ch3 : out std_logic_vector(7 downto 0);
	  ch4 : out std_logic_vector(7 downto 0);
	  ch5 : out std_logic_vector(7 downto 0)
    );
end adc_driver;

architecture impl of adc_driver is
	component adc is
		port (
			CLOCK : in std_logic := '0';
			CH0 : out std_logic_vector(11 downto 0);
			CH1 : out std_logic_vector(11 downto 0);
			CH2 : out std_logic_vector(11 downto 0);
			CH3 : out std_logic_vector(11 downto 0);
			CH4 : out std_logic_vector(11 downto 0);
			CH5 : out std_logic_vector(11 downto 0);
			CH6 : out std_logic_vector(11 downto 0);
			CH7 : out std_logic_vector(11 downto 0);
			RESET : in std_logic := '0'
		);
	end component;

	signal channel0, channel1, channel2, channel3, channel4, channel5 : std_logic_vector(11 downto 0);
begin
	driver : adc
		port map (
			CLOCK => clock,
			RESET => reset,
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
