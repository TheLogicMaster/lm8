-- Top level computer entity

library ieee;
use ieee.std_logic_1164.all;

entity computer is
	port (
		-- Clocks
		ADC_CLK_10, MAX10_CLK1_50, MAX10_CLK2_50 : in std_logic;

		-- SDRAM
		DRAM_DQ : inout std_logic_vector(15 downto 0);
		DRAM_ADDR : out std_logic_vector(12 downto 0);
		DRAM_BA : out std_logic_vector(1 downto 0);
		DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N : out std_logic;

		-- Switches
		SW : in std_logic_vector(9 downto 0);

		-- Push buttons
		KEY: in std_logic_vector(1 downto 0);

		-- Seven segment displays
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0);

		-- LEDs
		LEDR : out std_logic_vector(9 downto 0);

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

architecture impl of computer is
	component cpu is
		port (
			clock	: in std_logic;
			reset	: in std_logic;
			memory : in std_logic_vector(7 downto 0);
			port_in : in std_logic_vector(7 downto 0);
			freeze : in std_logic;
			data : out std_logic_vector(7 downto 0);
			address : out std_logic_vector(15 downto 0);
			hl : out std_logic_vector(15 downto 0);
			memory_write : out std_logic;
			io_port : out std_logic_vector(7 downto 0);
			port_write : out std_logic
		);
	end component;

	component memory is
		port (
			address_a : in std_logic_vector(15 downto 0);
			address_b : in std_logic_vector(15 downto 0);
			data_in_a : in std_logic_vector(7 downto 0);
			data_in_b : in std_logic_vector(7 downto 0);
			write_en : in std_logic;
			clock : in std_logic;
			data_out_a : out std_logic_vector(7 downto 0);
			data_out_b : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component peripherals is
        port (
            clock	: in std_logic;
            memory : in std_logic_vector(7 downto 0);
            io_port : in std_logic_vector(7 downto 0);
            port_in : in std_logic_vector(7 downto 0);
            port_write : in std_logic;
				hl : in std_logic_vector(15 downto 0);
				reset : in std_logic;
				buttons : in std_logic_vector(1 downto 0);
				switches : in std_logic_vector(9 downto 0);
				gpio : inout std_logic_vector(35 downto 0);
				arduino : inout std_logic_vector(15 downto 0);
            leds : out std_logic_vector(9 downto 0);
            hex0 : out std_logic_vector(7 downto 0);
            hex1 : out std_logic_vector(7 downto 0);
            hex2 : out std_logic_vector(7 downto 0);
            hex3 : out std_logic_vector(7 downto 0);
            hex4 : out std_logic_vector(7 downto 0);
            hex5 : out std_logic_vector(7 downto 0);
				vga_r : out std_logic_vector(3 downto 0);
				vga_g : out std_logic_vector(3 downto 0);
				vga_b : out std_logic_vector(3 downto 0);
				vga_hs : out std_logic;
				vga_vs : out std_logic;
            port_out : out std_logic_vector(7 downto 0);
            address : out std_logic_vector(15 downto 0);
            freeze : out std_logic
        );
    end component;
	 
	 component power_on_reset is
		port (
			clock : in std_logic;
			reset_in : in std_logic;
			reset_out : out std_logic
		);
	end component;

	signal memory_cpu_data : std_logic_vector(7 downto 0);
	signal memory_peripheral_data : std_logic_vector(7 downto 0);
	signal cpu_data : std_logic_vector(7 downto 0);
	signal peripheral_data : std_logic_vector(7 downto 0);
	signal peripheral_data_out : std_logic_vector(7 downto 0);
	signal io_port : std_logic_vector(7 downto 0);
	signal port_write : std_logic;
	signal cpu_address : std_logic_vector(15 downto 0);
	signal cpu_hl : std_logic_vector(15 downto 0);
	signal peripheral_address : std_logic_vector(15 downto 0);
	signal memory_write : std_logic;
	signal cpu_freeze : std_logic;
	signal reset : std_logic;
	signal reset_btn : std_logic;
	signal clock : std_logic;
begin
	reset_btn <= not KEY(0);
	--reset_btn <= '0';
	--clock <= not KEY(1);
	clock <= MAX10_CLK1_50;
	
	prcoessor : cpu
		port map (
			clock => clock,
			reset => reset,
			memory => memory_cpu_data,
			port_in => peripheral_data_out,
			freeze => cpu_freeze,
			data => cpu_data,
			address => cpu_address,
			hl => cpu_hl,
			memory_write => memory_write,
			io_port => io_port,
			port_write => port_write
		);
		
	mem : memory
		port map (
			address_a => cpu_address,
			address_b => peripheral_address,
			data_in_a => cpu_data,
			data_in_b => peripheral_data,
			write_en => memory_write,
			clock => MAX10_CLK1_50,
			data_out_a => memory_cpu_data,
			data_out_b => memory_peripheral_data
		);

	io : peripherals
		port map (
			clock => clock,
			memory => memory_peripheral_data,
			io_port => io_port,
			port_in => cpu_data,
			port_write => port_write,
			hl => cpu_hl,
			reset => reset,
			buttons => KEY,
			switches => SW,
			gpio => GPIO,
			arduino => ARDUINO_IO,
			leds => LEDR,
			hex0 => HEX0,
			hex1 => HEX1,
			hex2 => HEX2,
			hex3 => HEX3,
			hex4 => HEX4,
			hex5 => HEX5,
			vga_r => VGA_R,
			vga_g => VGA_G,
			vga_b => VGA_B,
			vga_hs => VGA_HS,
			vga_vs => VGA_VS,
			port_out => peripheral_data_out,
			address => peripheral_address,
			freeze => cpu_freeze
		);
		
	por : power_on_reset
		port map (
			clock => MAX10_CLK1_50,
			reset_in => reset_btn,
			reset_out => reset
		);
end architecture;
