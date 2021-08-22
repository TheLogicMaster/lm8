-- DE10-Lite UART implementation

library ieee;
use ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

architecture impl of UART_dummy is
	signal transmit_waiting : std_logic;
	signal transmit_ready : std_logic;
	signal receive_error : std_logic;
	signal receive_valid : std_logic;
	signal fifo_used_write : std_logic_vector(7 downto 0);
	signal fifo_data : std_logic_vector(7 downto 0);
	signal fifo_write : std_logic;
begin
	fifo : dcfifo
	GENERIC MAP (
		intended_device_family => "MAX 10",
		lpm_numwords => 256,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => 8,
		lpm_widthu => 8,
		overflow_checking => "ON",
		rdsync_delaypipe => 3,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 3
	)
	PORT MAP (
		data => fifo_data,
		rdclk => clk,
		rdreq => pop,
		wrclk => uart_clk,
		wrreq => fifo_write,
		q => received,
		rdusedw => available,
		wrusedw => fifo_used_write
	);

	uart : ieee.uart
		port map (
			clk_clk => uart_clk,
			rs232_0_reset => '0',
			rs232_0_from_uart_ready => '1',
			rs232_0_from_uart_data => fifo_data,
			rs232_0_from_uart_error => receive_error,
			rs232_0_from_uart_valid => receive_valid,
			rs232_0_to_uart_data => data,
			rs232_0_to_uart_error => '0',
			rs232_0_to_uart_valid => valid and not transmit_waiting,
			rs232_0_to_uart_ready => transmit_ready,
			rs232_0_UART_RXD => rx,
			rs232_0_UART_TXD => tx
		);

	full <= not transmit_ready;

	process(uart_clk, valid)
	begin
		if uart_clk'event and uart_clk='1' then
			transmit_waiting <= valid;
		end if;
	end process;

	process(fifo_used_write, receive_error, receive_valid)
	begin
		if receive_error='0' and receive_valid='1' and fifo_used_write/=x"FD" then
			fifo_write <= '1';
		else
			fifo_write <= '0';
		end if;
	end process;
end architecture;
