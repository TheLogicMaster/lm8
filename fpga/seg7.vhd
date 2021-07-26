-- A seven segment display driver

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY seg7 IS
	PORT (
		digit : IN STD_LOGIC_VECTOR(0 to 3);
		segments: OUT STD_LOGIC_VECTOR(0 to 7)
	);
END seg7;

ARCHITECTURE impl OF seg7 IS
BEGIN
	switch: PROCESS (digit)
	BEGIN
		CASE digit IS
			WHEN x"0" => segments <= "00000011";
			WHEN x"1" => segments <= "10011111";
			WHEN x"2" => segments <= "00100101";
			WHEN x"3" => segments <= "00001101";
			WHEN x"4" => segments <= "10011001";
			WHEN x"5" => segments <= "01001001";
			WHEN x"6" => segments <= "01000001";
			WHEN x"7" => segments <= "00011111";
			WHEN x"8" => segments <= "00000001";
			WHEN x"9" => segments <= "00011001";
			WHEN x"A" => segments <= "00010001";
			WHEN x"B" => segments <= "11000001";
			WHEN x"C" => segments <= "01100011";
			WHEN x"D" => segments <= "10000101";
			WHEN x"E" => segments <= "01100001";
			WHEN x"F" => segments <= "01110001";
		END CASE;
	END PROCESS;
END impl;
