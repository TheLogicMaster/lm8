library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_driver is
	port (
		clock	: in std_logic;
		reset : in std_logic;
		duty_cycle : in std_logic_vector(7 downto 0);
		modulated : out std_logic
	);
end entity;

architecture impl of pwm_driver is
	signal count : unsigned(7 downto 0);
begin
	modulated <= '1' when duty_cycle = x"FF" or count < unsigned(duty_cycle) else '0';
	
	process(all)
	begin
		if reset = '1' then
			count <= to_unsigned(0, 8);
		elsif rising_edge(clock) then
			count <= count + 1;
		end if;
	end process;
end architecture;
