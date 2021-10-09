library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	port (
		clock	: in std_logic;
		reset : in std_logic;
		clear : in std_logic;
		unit : in std_logic_vector(2 downto 0);
		multiplier : in std_logic_vector(7 downto 0);
		triggered : out std_logic
	);
end entity;

architecture impl of timer is
	signal count : unsigned(36 downto 0);
	signal timer_triggered : std_logic;
	signal unit_counts : integer;
begin
	with unit select
		unit_counts <=
			50 when "000",
			500 when "001",
			5000 when "010",
			50000 when "011",
			500000 when "100",
			5000000 when "101",
			50000000 when "110",
			500000000 when "111",
			0 when others;
	timer_triggered <= '1' when count >= to_unsigned(unit_counts, 37) * resize(unsigned(multiplier), 37) else '0';
	triggered <= timer_triggered;
	
	process(all)
	begin
		if reset = '1' then
			count <= to_unsigned(0, 37);
		elsif rising_edge(clock) then
			if clear = '1' then
				count <= to_unsigned(0, 37);
			elsif timer_triggered = '0' then
				count <= count + 1;
			end if;
		end if;
	end process;
end architecture;
