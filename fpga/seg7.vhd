-- A seven segment display driver

library ieee;
use ieee.std_logic_1164.all;

entity seg7 is
	port (
		digit : in std_logic_vector(3 downto 0);
		segments: out std_logic_vector(7 downto 0)
	);
end entity;

architecture impl of seg7 is
begin
	with digit select segments <=
		"11000000" when x"0",
		"11111001" when x"1",
		"10100100" when x"2",
		"10110000" when x"3",
		"10011001" when x"4",
		"10010010" when x"5",
		"10000010" when x"6",
		"11111000" when x"7",
		"10000000" when x"8",
		"10010000" when x"9",
		"10001000" when x"A",
		"10000011" when x"B",
		"11000110" when x"C",
		"10100001" when x"D",
		"10000110" when x"E",
		"10001110" when x"F",
		"00000000" when others;
end architecture;
