-- Arithmatic Logic Unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port (
		mode : in std_logic_vector(2 downto 0); -- The ALU operation to perform
		reg_a : in std_logic_vector(7 downto 0); -- The A register
		operand : in std_logic_vector(7 downto 0); -- The operation operand
		flags_in: in std_logic_vector(3 downto 0); -- The status register
		result : out std_logic_vector(7 downto 0); -- The operation result
		flags_out : out std_logic_vector(3 downto 0) -- The resulting status flags
	);
end entity;

architecture impl of alu is
begin
	process(mode, reg_a, operand, flags_in)
		variable r : std_logic_vector(7 downto 0);
		variable c : unsigned(0 downto 0);
	begin
		flags_out <= flags_in;
		
		if mode = "001" or mode = "011" then
			c := "" & flags_in(2);
		else
			c := b"0";
		end if;
		
		case mode is
			when "000" => r := std_logic_vector(unsigned(reg_a) + unsigned(operand));
			when "001" => r := std_logic_vector(unsigned(reg_a) + unsigned(operand) + c);
			when "010" | "111" => r := std_logic_vector(unsigned(reg_a) - unsigned(operand));
			when "011" => r := std_logic_vector(unsigned(reg_a) - unsigned(operand) - c);
			when "100" => r := reg_a and operand;
			when "101" => r := reg_a or operand;
			when "110" => r := reg_a xor operand;
		end case;
		
		-- Cary flag
		if mode = "000" or mode = "001" then
			if '0' & unsigned(reg_a) + unsigned(operand) + c > x"FF" then
				flags_out(2) <= '1';
			else
				flags_out(2) <= '0';
			end if;
		elsif mode = "010" or mode = "011" or mode = "111" then
			if unsigned(operand) + c > unsigned(reg_a) then
				flags_out(2) <= '1';
			else
				flags_out(2) <= '0';
			end if;
		end if;
		
		-- Overflow flag
		if mode = "000" or mode = "001" or mode = "010" or mode = "011" or mode = "111" then
			if reg_a(7) = operand(7) and reg_a(7) /= r(7) then
				flags_out(0) <= '1';
			else
				flags_out(0) <= '0';
			end if;
		end if;
		
		-- Negative flag
		flags_out(1) <= r(7);
		
		-- Zero flag
		if r = x"00" then
			flags_out(3) <= '1';
		else
			flags_out(3) <= '0';
		end if;
		
		result <= r;
	end process;
end architecture;
