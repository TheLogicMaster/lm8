library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity cpu is
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
end cpu;

architecture impl of cpu is
	component alu is
		port (
			mode : in std_logic_vector(3 downto 0);
			reg_a : in std_logic_vector(7 downto 0);
			operand : in std_logic_vector(7 downto 0);
			flags_in: in std_logic_vector(3 downto 0);
			result : out std_logic_vector(7 downto 0);
			flags_out : out std_logic_vector(3 downto 0)
		);
	end component;
	
	component microcode is
		port (
			Address : in std_logic_vector(8 downto 0);
			Data : out std_logic_vector(23 downto 0)
		);
	end component;

	-- Control lines
	signal line_addr_mode : std_logic_vector(1 downto 0);
	signal line_write_op_sel : std_logic_vector(1 downto 0);
	signal line_read_sel : std_logic_vector(3 downto 0);
	signal line_write_sel : std_logic_vector(2 downto 0);
	signal line_mode : std_logic_vector(3 downto 0);
	signal line_mode_2 : std_logic_vector(1 downto 0);
	signal line_mode_1 : std_logic;
	signal line_sp_write : std_logic;
	signal line_sp_inc : std_logic;
	signal line_write : std_logic;
	signal line_f_write : std_logic;
	signal line_cond_en : std_logic;
	signal line_halt : std_logic;
	signal line_pc_inc : std_logic;
	signal line_pc_write : std_logic;
	signal line_instr_done : std_logic;
	
	-- Registers
	signal reg_a : std_logic_vector(7 downto 0);
	signal reg_b : std_logic_vector(7 downto 0);
	signal reg_h : std_logic_vector(7 downto 0);
	signal reg_l : std_logic_vector(7 downto 0);
	signal reg_c0 : std_logic_vector(7 downto 0);
	signal reg_c1 : std_logic_vector(7 downto 0);
	signal reg_sp : std_logic_vector(7 downto 0);
	signal reg_pc : std_logic_vector(15 downto 0);
	signal reg_f : std_logic_vector(3 downto 0);
	signal reg_instr : std_logic_vector(7 downto 0);
	signal reg_instr_state : integer range 0 to 15;
	signal reg_halted : std_logic;
	
	-- Signals
	signal addr_mode : std_logic_vector(1 downto 0);
	signal instr_reg_cond : std_logic_vector(1 downto 0);
	signal alu_f : std_logic_vector(3 downto 0);
	signal alu_result : std_logic_vector(7 downto 0);
	signal operand_reg : std_logic_vector(7 downto 0);
	signal operation_input : std_logic_vector(7 downto 0);
	signal microcode_addr : std_logic_vector(8 downto 0);
	signal control_lines : std_logic_vector(23 downto 0);
	signal cond_success : std_logic;
	signal data_bus : std_logic_vector(7 downto 0);
	
begin
	arithmetic : alu
		port map (
			mode => line_mode,
			reg_a => reg_a,
			operand => operation_input,
			flags_in => reg_f,
			result => alu_result,
			flags_out => alu_f
		);
	
	micro : microcode -- Auto-generated LUT based microcode, ignore style-issues
		port map (
			Address => microcode_addr,
			Data => control_lines
		);

	data <= data_bus;
	hl <= reg_h & reg_l;
	io_port <= reg_c0;
		
	-- Control line assignments
	line_addr_mode <= control_lines(1 downto 0);
	line_write_op_sel <= control_lines(3 downto 2);
	line_read_sel <= control_lines(7 downto 4);
	line_write_sel <= control_lines(10 downto 8);
	line_mode <= control_lines(14 downto 11);
	line_mode_2 <= control_lines(12 downto 11);
	line_mode_1 <= control_lines(11);
	line_sp_write <= control_lines(15);
	line_sp_inc <= control_lines(16);
	line_write <= control_lines(17);
	line_f_write <= control_lines(18);
	line_cond_en <= control_lines(19);
	line_halt <= control_lines(20);
	line_pc_inc <= control_lines(21);
	line_pc_write <= control_lines(22);
	line_instr_done <= control_lines(23);
	
	-- Memory addressing
	addr_mode <= "00" when reg_instr_state < 2 else line_addr_mode;
	address <= 
		reg_pc when addr_mode = "00" else
		x"FF" & not reg_sp when addr_mode = "01" else
		reg_h & reg_l when addr_mode = "10" else
		reg_c0 & reg_c1 when addr_mode = "11" else
		x"XXXX";
	
	-- Microcode addressing
	microcode_addr <= 
		std_logic_vector(to_unsigned(4, 9)) when reg_instr_state = 0 else
		std_logic_vector(to_unsigned(to_integer(unsigned(memory(7 downto 2))) * 8, 9)) when reg_instr_state = 1 else
		std_logic_vector(to_unsigned(reg_instr_state - 1 + to_integer(unsigned(reg_instr(7 downto 2))) * 8, 9)) when reg_instr_state >= 2 else
		std_logic_vector(to_unsigned(0, 9));
	
	-- Parse operand register or condition
	instr_reg_cond <=
		memory(1 downto 0) when reg_instr_state = 1 else
		reg_instr(1 downto 0) when reg_instr_state >= 2 else
		"XX";
	
	-- Data output bus
	data_bus <=
		alu_result when line_write_op_sel = "00" else
		operation_input when line_write_op_sel = "01" else
		std_logic_vector(unsigned(operation_input) + 1) when line_write_op_sel = "10" else
		std_logic_vector(unsigned(operation_input) - 1) when line_write_op_sel = "11" else
		x"XX";
	
	-- CPU output write logic
	memory_write <= '1' when line_write = '1' and line_write_sel = "110" else '0';
	port_write <= '1' when line_write = '1' and line_write_sel = "111" else '0';
	
	-- Operation input bus
	operand_reg <=
		reg_a when instr_reg_cond = "00" else
		reg_b when instr_reg_cond = "01" else
		reg_h when instr_reg_cond = "10" else
		reg_l when instr_reg_cond = "11" else
		x"XX";
	operation_input <=
		reg_a when line_read_sel = "0000" else
		operand_reg when line_read_sel = "0001" else
		reg_h when line_read_sel = "0010" else
		reg_l when line_read_sel = "0011" else
		reg_c0 when line_read_sel = "0100" else
		reg_c1 when line_read_sel = "0101" else
		memory when line_read_sel = "0110" else
		reg_pc(7 downto 0) when line_read_sel = "0111" else
		reg_pc(15 downto 8) when line_read_sel = "1000" else
		port_in when line_read_sel = "1001" else
		x"XX";
	
	-- Processor control logic
	controller : process(all)
	begin
		if reset = '1' then
			reg_instr <= x"00";
			reg_instr_state <= 0;
		elsif rising_edge(clock) and reg_halted = '0' and freeze = '0' then
			if line_instr_done = '1' or (cond_success = '1' and line_cond_en='1') then
				reg_instr_state <= 0;
			else
				if reg_instr_state = 1 then
  					reg_instr <= memory;
				end if;
				reg_instr_state <= reg_instr_state + 1;
			end if;
		end if;
	end process;
	
	-- Processor data-flow logic
	data_flow : process(all)
		variable status : std_logic_vector(3 downto 0);
	begin
		if reset = '1' then
			reg_a <= x"00";
			reg_b <= x"00";
			reg_h <= x"00";
			reg_l <= x"00";
			reg_c0 <= x"00";
			reg_c1 <= x"00";
			reg_sp <= x"00";
			reg_pc <= x"0000";
			reg_f <= x"0";
			reg_halted <= '0';
		elsif rising_edge(clock) then
			-- Update registers
			if line_write = '1' then
				case line_write_sel is
					when "000" => reg_a <= data_bus;
					when "010" => reg_h <= data_bus;
					when "011" => reg_l <= data_bus;
					when "100" => reg_c0 <= data_bus;
					when "101" => reg_c1 <= data_bus;
					when others => null;
				end case;
				
				if line_write_sel = "001" then
					case instr_reg_cond is
						when "00" => reg_a <= data_bus;
						when "01" => reg_b <= data_bus;
						when "10" => reg_h <= data_bus;
						when "11" => reg_l <= data_bus;
						when others => null;
					end case;
				end if;
			end if;
		
			-- Halt
			if line_halt then
				reg_halted <= '1';
			end if;
		
			-- Update Status register
			if line_f_write = '1' then
				if line_write_op_sel = "00" then
					reg_f <= alu_f;
				else
					status := reg_f;
					if data_bus = x"00" then
						status := status or "1000";
					else
						status := status and "0111";
					end if;
					if line_write_op_sel = "10" then
						if operation_input = x"FF" then
							status := status or "0100";
						else
							status := status and "1011";
						end if;
					elsif line_write_op_sel = "11" then
						if operation_input = x"00" then
							status := status or "0100";
						else
							status := status and "1011";
						end if;
					end if;
					reg_f <= status;
				end if;
			end if;
		
			-- Update SP
			if line_sp_write = '1' then
				if line_sp_inc = '1' then
					reg_sp <= std_logic_vector(unsigned(reg_sp) + 1);
				else
					reg_sp <= std_logic_vector(unsigned(reg_sp) - 1);
				end if;
			end if;
		
			-- Update PC
			if line_pc_write = '1' then
				if line_mode_2 = "00" then
						reg_pc <= reg_h & reg_l;
					elsif line_mode_2 = "01" then
						reg_pc <= reg_c0 & reg_c1;
					elsif line_mode_2 = "10" then
						reg_pc <= std_logic_vector(unsigned(reg_pc) + unsigned(resize(signed(data_bus), 16)));
					end if;
			elsif reg_instr_state = 1 or line_pc_inc = '1' then
				reg_pc <= std_logic_vector(unsigned(reg_pc) + 1);
			end if;
		end if;
	end process;
	
	-- Instruction termination logic
	conditions : process(all)
	begin
		if line_mode_2 = "00" then
			cond_success <= shift_left(unsigned(reg_f), to_integer(unsigned(instr_reg_cond)))(3);
		elsif line_mode_2 = "01" then
			cond_success <= not shift_left(unsigned(reg_f), to_integer(unsigned(instr_reg_cond)))(3);
		elsif line_mode_2 = "10" then
			if unsigned(data_bus) > 0 then
				cond_success <= '1';
			else
				cond_success <= '0';
			end if;
		elsif line_mode_2 = "11" then
			if unsigned(data_bus) < x"ff" then
				cond_success <= '1';
			else
				cond_success <= '0';
			end if;
		end if;
	end process;
end impl;
