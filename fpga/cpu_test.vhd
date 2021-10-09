library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_test is
end cpu_test;

architecture test of cpu_test is
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

    signal clock, reset, freeze : std_logic;
	 signal hl : std_logic_vector(15 downto 0);
    signal memory, io_port_out : std_logic_vector(7 downto 0);
    signal data, io_port : std_logic_vector(7 downto 0);
    signal address : std_logic_vector(15 downto 0);
    signal port_write, memory_write : std_logic;
	 signal hex0 : std_logic_vector(7 downto 0);
	 signal rom : std_logic_vector(7 downto 0);
	 signal leds : std_logic_vector(9 downto 0);
begin
    prcoessor : cpu
		port map (
			clock => clock,
			reset => reset,
			memory => memory,
			port_in => io_port_out,
			freeze => freeze,
			data => data,
			address => address,
			hl => hl,
			memory_write => memory_write,
			io_port => io_port,
			port_write => port_write
		);
		
	p : peripherals
        port map (
            clock => clock,
            memory => x"00",
            io_port => io_port,
            port_in => data,
            port_write => port_write,
				hl => hl,
				reset => reset,
				buttons => "00",
				switches => "0000000000",
				--gpio => x"ZZZZZZZZZ",
				--arduino => x"ZZZZ",
            leds => leds,
            hex0 => hex0,
            --hex1 => hex1,
            --hex2 => hex2,
            --hex3 => hex3,
            --hex4 => hex4,
            --hex5 => hex5,
            port_out => io_port_out,
            --address => address,
            freeze => freeze
        );

	 rom <= 
		x"04" when address = x"0000" else
		x"12" when address = x"0001" else
		x"90" when address = x"0002" else
		x"95" when address = x"0003" else
		x"A0" when address = x"0004" else
		x"00";
		
    vectors: process
		  constant period: time := 10 ns;
    begin
		  memory <= x"00";
        clock <= '0';
		  		  
		  -- Reset
		  reset <= '1';
		  wait for period;
        clock <= '1';
		  wait for period;
        clock <= '0';
		  wait for period;
        clock <= '1';
		  wait for period;
        clock <= '0';
		  wait for period;
		  reset <= '0';
		  
		  wait for period;
		  memory <= rom;
        clock <= '1';
		  wait for period;
        clock <= '0';
		  		  
		  for i in 1 to 20 loop
				wait for period;
				memory <= rom;
				clock <= '1';
				wait for period;
				clock <= '0';
		  end loop;
		  
		  wait;
    end process;
end test;
