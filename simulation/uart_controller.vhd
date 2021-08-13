-- DE10-Lite UART implementation

library ieee;
use ieee.std_logic_1164.all;

architecture impl of UART_dummy is
	signal waiting : std_logic;
	signal receive_data : std_logic_vector(7 downto 0);
	signal receive_error : std_logic;
	signal receive_valid : std_logic;
begin
	uart : ieee.uart
		port map (
			clk_clk=>clk,
			rs232_0_reset=>'0',
			rs232_0_from_uart_ready=>'1',
			rs232_0_from_uart_data=>receive_data,
			rs232_0_from_uart_error=>receive_error,
			rs232_0_from_uart_valid=>receive_valid,
			rs232_0_to_uart_data=>data,
			rs232_0_to_uart_error=>'0',
			rs232_0_to_uart_valid=>valid and not waiting,
			rs232_0_to_uart_ready=>ready,
			rs232_0_UART_RXD=>rx,
			rs232_0_UART_TXD=>tx
		);

	process(clk, valid)
	begin
		if clk'event and clk='1' then
			waiting <= valid;
		end if;
	end process;

	process(clk, receive_data, receive_error, receive_valid)
	begin
		if clk'event and clk='1' and receive_error='0' and receive_valid='1' then
			received <= receive_data;
		end if;
	end process;
end architecture;
