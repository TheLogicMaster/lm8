library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity uart_controller is
	port (
		clock : in std_logic;
		reset : in std_logic;
		write_en : in std_logic;
		data : in std_logic_vector(7 downto 0);
		rx : in std_logic;
		pop : in std_logic;
		full : out std_logic;
		tx : out std_logic;
		received : out std_logic_vector(7 downto 0);
		available : out std_logic_vector(7 downto 0)
	);
end uart_controller;

architecture impl of uart_controller is
	component uart is
		port (
			clk_clk : in std_logic := '0';
			reset_reset_n : in std_logic := '0';
			rs232_0_from_uart_ready : in std_logic := '0';
			rs232_0_from_uart_data : out std_logic_vector(7 downto 0);
			rs232_0_from_uart_error : out std_logic;
			rs232_0_from_uart_valid : out std_logic;
			rs232_0_to_uart_data : in std_logic_vector(7 downto 0) := (others => '0');
			rs232_0_to_uart_error : in std_logic := '0';
			rs232_0_to_uart_valid : in std_logic := '0';
			rs232_0_to_uart_ready : out std_logic;
			rs232_0_UART_RXD : in std_logic := '0';
			rs232_0_UART_TXD : out std_logic;
			rs232_0_reset : in std_logic := '0'
		);
end component uart;

	signal transmit_ready : std_logic;
	signal receive_error : std_logic;
	signal receive_valid : std_logic;
	signal fifo_data : std_logic_vector(7 downto 0);
	signal fifo_write : std_logic;
begin
	fifo : scfifo
		generic map (
			add_ram_output_register => "OFF",
			intended_device_family => "MAX 10",
			lpm_numwords => 256,
			lpm_showahead => "ON",
			lpm_type => "scfifo",
			lpm_width => 8,
			lpm_widthu => 8,
			overflow_checking => "ON",
			underflow_checking => "ON",
			use_eab => "ON"
		)
		port map (
			aclr => reset,
			clock => clock,
			data => fifo_data,
			rdreq => pop,
			wrreq => fifo_write,
			q => received,
			usedw => available
		);
	
	rs232 : uart
		port map (
			clk_clk => clock,
			rs232_0_reset => reset,
			rs232_0_from_uart_ready => '1',
			rs232_0_from_uart_data => fifo_data,
			rs232_0_from_uart_error => receive_error,
			rs232_0_from_uart_valid => receive_valid,
			rs232_0_to_uart_data => data,
			rs232_0_to_uart_error => '0',
			rs232_0_to_uart_valid => write_en,
			rs232_0_to_uart_ready => transmit_ready,
			rs232_0_UART_RXD => rx,
			rs232_0_UART_TXD => tx
		);
		
	full <= not transmit_ready;
	
	process(all)
	begin
		if receive_error='0' and receive_valid='1' and available/=x"FD" then
			fifo_write <= '1';
		else
			fifo_write <= '0';
		end if;
	end process;
end architecture;