library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity random is
	port (
		clock	: in std_logic;
		reset : in std_logic;
		seed : in std_logic_vector(7 downto 0);
		seed_write : in std_logic;
		rand : out std_logic_vector(7 downto 0)
	);
end entity;

architecture impl of random is
	signal lsfr : std_logic_vector(7 downto 0);
begin
	rand <= lsfr;
	
	process(all)
	begin
		if reset = '1' then
			lsfr <= x"FF";
		elsif rising_edge(clock) then
			if seed_write = '1' then
				lsfr <= seed;
			else
				lsfr(7) <= lsfr(0);
				lsfr(6) <= lsfr(7) xor lsfr(0);
				lsfr(5) <= lsfr(6);
				lsfr(4) <= lsfr(5);
				lsfr(3) <= lsfr(4);
				lsfr(2) <= lsfr(3);
				lsfr(1) <= lsfr(2);
				lsfr(0) <= lsfr(1);
			end if;
		end if;
	end process;
end architecture;
