-- Arithmatic Logic Unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port (
		mode : in std_logic_vector(3 downto 0); -- The ALU operation to perform
		reg_a : in std_logic_vector(7 downto 0); -- The A register
		operand : in std_logic_vector(7 downto 0); -- The operation operand
		flags_in: in std_logic_vector(3 downto 0); -- The status register
		result : out std_logic_vector(7 downto 0); -- The operation result
		flags_out : out std_logic_vector(3 downto 0) -- The resulting status flags
	);
end entity;

architecture impl of alu is
begin
	process(all)
		variable r : std_logic_vector(7 downto 0);
		variable c : unsigned(0 downto 0);
	begin
		flags_out <= flags_in;
		
		if mode = "0001" or mode = "0011" then
			c := "" & flags_in(2);
		else
			c := b"0";
		end if;
		
		case mode is
			when "0000" => r := std_logic_vector(unsigned(reg_a) + unsigned(operand));
			when "0001" => r := std_logic_vector(unsigned(reg_a) + unsigned(operand) + c);
			when "0010" | "0111" => r := std_logic_vector(unsigned(reg_a) - unsigned(operand));
			when "0011" => r := std_logic_vector(unsigned(reg_a) - unsigned(operand) - c);
			when "0100" => r := reg_a and operand;
			when "0101" => r := reg_a or operand;
			when "0110" => r := reg_a xor operand;
			when "1000" => r := std_logic_vector(shift_left(unsigned(reg_a), 1));
			when "1001" => r := std_logic_vector(shift_right(unsigned(reg_a), 1));
			when "1010" => r := std_logic_vector(shift_right(signed(reg_a), 1));
			when others => r := x"XX";
		end case;
		
		-- Cary flag
		if mode = "0000" or mode = "0001" then
			if '0' & unsigned(reg_a) + unsigned(operand) + c > x"FF" then
				flags_out(2) <= '1';
			else
				flags_out(2) <= '0';
			end if;
		elsif mode = "0010" or mode = "0011" or mode = "0111" then
			if unsigned(operand) + c > unsigned(reg_a) then
				flags_out(2) <= '1';
			else
				flags_out(2) <= '0';
			end if;
		elsif mode = "1000" then
			flags_out(2) <= reg_a(7);
		elsif mode = "1001" or mode = "1010" then
			flags_out(2) <= reg_a(0);
		end if;
		
		-- Overflow flag
		if mode = "0000" or mode = "0001" or mode = "0010" or mode = "0011" or mode = "0111" then
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
