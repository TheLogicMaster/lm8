-- A Power-on-Reset module

library ieee;
use ieee.std_logic_1164.all;

entity power_on_reset is
	port (
		clock : in std_logic;
		reset_in : in std_logic;
		reset_out : out std_logic
	);
end entity;

architecture impl of power_on_reset is
	constant RESET_CYCLES: integer := 5;

	signal state : integer range 0 to RESET_CYCLES;
begin
	process(all)
	begin
		if reset_in='1' then
			state <= 0;
			reset_out <= '1';
		elsif rising_edge(clock) then
			if state < RESET_CYCLES then
				state <= state + 1;
				reset_out <= '1';
			else
				reset_out <= '0';
			end if;		
		end if;
	end process;
end architecture;
