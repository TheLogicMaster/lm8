-- Top level CPU entity

library ieee;
use ieee.std_logic_1164.all;

entity lm8 is
	port (
		-- Clocks
		ADC_CLK_10, MAX10_CLK1_50, MAX10_CLK2_50 : in std_logic;
		
		-- SDRAM
		DRAM_DQ : inout std_logic_vector(15 downto 0);
		DRAM_ADDR : out std_logic_vector(12 downto 0);
		DRAM_BA : out std_logic_vector(1 downto 0);
		DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N : out std_logic;
		
		-- Switches
		SW : in std_logic_vector(10 downto 0); 
		
		-- Push buttons
		KEY: in std_logic_vector(1 downto 0); 
		
		-- Seven segment displays
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0);
		
		-- LEDs
		LEDR : out std_logic_vector(10 downto 0);
		
		-- VGA
		VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0);
		VGA_HS, VGA_VS : out std_logic;
		
		-- Accelerometer
		GSENSOR_INT : in std_logic_vector(2 downto 1);
		GSENSOR_SDI, GSENSOR_SDO : inout std_logic;
		GSENSOR_CS_N, GSENSOR_SCLK : out std_logic;
		
		-- Arduino
		ARDUINO_IO : inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N : inout std_logic;
		
		-- GPIO
		GPIO : inout std_logic_vector(35 downto 0)
	);
end entity;

architecture impl of lm8 is
	signal flags_0, flags_1 : std_logic_vector(3 downto 0);
	signal result_0, result_1 : std_logic_vector(7 downto 0);
begin
	seven_seg_0 : work.seg7 port map(x"9", HEX0);
	seven_seg_1 : work.seg7 port map(x"6", HEX1);
	seven_seg_2 : work.seg7 port map(x"9", HEX2);
	seven_seg_3 : work.seg7 port map(x"6", HEX3);
	seven_seg_4 : work.seg7 port map(x"9", HEX4);
	seven_seg_5 : work.seg7 port map(x"6", HEX5);

	LEDR <= SW;
end architecture;
