library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer_test is
end timer_test;

architecture test of timer_test is
	component timer is
		port (
			clock	: in std_logic;
			reset : in std_logic;
			clear : in std_logic;
			unit : in std_logic_vector(2 downto 0);
			multiplier : in std_logic_vector(7 downto 0);
			triggered : out std_logic
		);
	end component;

	signal clock, reset, clear, triggered : std_logic;
	signal unit : std_logic_vector(2 downto 0);
	signal multiplier : std_logic_vector(7 downto 0);
begin
	t : timer 
		port map(
			clock => clock,
			reset => reset,
			clear => clear,
			unit => unit,
			multiplier => multiplier,
			triggered => triggered
		);
		
    vectors: process
		  constant period: time := 10 ns;
    begin
		  clear <= '0'; 
        clock <= '0';
		  unit <= "110";
		  multiplier <= x"01";
		  		  
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
		  
		  for i in 1 to 50000100 loop
				wait for period;
				clock <= '1';
				wait for period;
				clock <= '0';
		  end loop;
		  
		  wait;
    end process;
end test;
