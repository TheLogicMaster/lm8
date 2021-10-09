library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity peripherals_test is
end peripherals_test;

architecture test of peripherals_test is
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

    -- Inputs
    signal clock, port_write : std_logic;
	 signal hl : std_logic_vector(15 downto 0);
    signal memory, io_port, port_in : std_logic_vector(7 downto 0);
	 signal buttons : std_logic_vector(1 downto 0);
	 signal switches : std_logic_vector(9 downto 0);
	 
    -- Outputs
    signal hex0, hex1, hex2, hex3, hex4, hex5 : std_logic_vector(7 downto 0);
    signal leds : std_logic_vector(9 downto 0);
    signal port_out : std_logic_vector(7 downto 0);
    signal address : std_logic_vector(15 downto 0);
    signal freeze : std_logic;
begin
    p : peripherals
        port map (
            clock => clock,
            memory => memory,
            io_port => io_port,
            port_in => port_in,
            port_write => port_write,
				hl => hl,
				reset => '0',
				buttons => buttons,
				switches => switches,
				--gpio => gpio,
				--arduino => arduino,
            leds => leds,
            hex0 => hex0,
            hex1 => hex1,
            hex2 => hex2,
            hex3 => hex3,
            hex4 => hex4,
            hex5 => hex5,
            port_out => port_out,
            address => address,
            freeze => freeze
        );

    vectors: process
		  constant period: time := 10 ns;
    begin
		  memory <= x"00";
        io_port <= x"02";
        port_in <= x"08";
        clock <= '0';
        port_write <= '1';
		  
		  for i in 1 to 10 loop
				wait for period;
				clock <= '1';
				wait for period;
				clock <= '0';
		  end loop;
		  wait for period;
		  
		  wait;
    end process;
end test;
