library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity peripherals is
	port (
		clock	: in std_logic;
		memory : in std_logic_vector(7 downto 0);
		io_port : in std_logic_vector(7 downto 0);
		port_in : in std_logic_vector(7 downto 0);
		hl : in std_logic_vector(15 downto 0);
		port_write : in std_logic;
		reset : in std_logic;
		buttons : in std_logic_vector(1 downto 0);
		switches : in std_logic_vector(9 downto 0);
		gpio : inout std_logic_vector(35 downto 0);
		arduino : inout std_logic_vector(15 downto 0);
		leds : out std_logic_vector(9 downto 0);
		hex0 : out std_logic_vector(7 downto 0);
		hex1 : out std_logic_vector(7 downto 0);
		hex2 : out std_logic_vector(7 downto 0);
		hex3 : out std_logic_vector(7 downto 0);
		hex4 : out std_logic_vector(7 downto 0);
		hex5 : out std_logic_vector(7 downto 0);
		vga_r : out std_logic_vector(3 downto 0);
		vga_g : out std_logic_vector(3 downto 0);
		vga_b : out std_logic_vector(3 downto 0);
		vga_hs : out std_logic;
		vga_vs : out std_logic;
		port_out : out std_logic_vector(7 downto 0);
		address : out std_logic_vector(15 downto 0);
		freeze : out std_logic
	);
end entity;

architecture impl of peripherals is
	component seg7 is
		port (
			digit : in std_logic_vector(3 downto 0);
			segments: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component uart_controller is
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
	end component;

	component timer is
		port (
			clock	: in std_logic;
			reset : in std_logic;
			clear : in std_logic;
			unit : in std_logic_vector(2 downto 0);
			multiplier : in std_logic_vector(7 downto 0);
			triggered : out std_logic
		);
	end component;
	
	component adc_driver is
	   port (
		  clock : in std_logic;
		  reset : in std_logic;
		  ch0 : out std_logic_vector(7 downto 0);
		  ch1 : out std_logic_vector(7 downto 0);
		  ch2 : out std_logic_vector(7 downto 0);
		  ch3 : out std_logic_vector(7 downto 0);
		  ch4 : out std_logic_vector(7 downto 0);
		  ch5 : out std_logic_vector(7 downto 0)
		 );
	end component;
	
	component pwm_driver is
		port (
			clock	: in std_logic;
			reset : in std_logic;
			duty_cycle : in std_logic_vector(7 downto 0);
			modulated : out std_logic
		);
	end component;
	
	component random is
		port (
			clock	: in std_logic;
			reset : in std_logic;
			seed : in std_logic_vector(7 downto 0);
			seed_write : in std_logic;
			rand : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component gpu is
		port (
			clock : in std_logic;
			reset : in std_logic;
			hl : in std_logic_vector(15 downto 0);
			swap : in std_logic;
			draw_pixel : in std_logic;
			draw_sprite : in std_logic;
			clear : in std_logic;
			param : in std_logic_vector(7 downto 0);
			x : in std_logic_vector(7 downto 0);
			y : in std_logic_vector(7 downto 0);
			memory : in std_logic_vector(7 downto 0);
			address : out std_logic_vector(15 downto 0);
			freeze : out std_logic;
			vga_hs : out std_logic;
			vga_vs : out std_logic;
			vga_r: out std_logic_vector(3 downto 0);
			vga_g : out std_logic_vector(3 downto 0);
			vga_b : out std_logic_vector(3 downto 0)
		);
	end component;
	
	type seg7_array is array (0 to 5) of std_logic_vector(3 downto 0);
	type adc_array is array (0 to 5) of std_logic_vector(7 downto 0);
	type pwm_array is array (0 to 5) of std_logic_vector(7 downto 0);
	
	signal seg7_states : seg7_array;
	signal led_states : std_logic_vector(9 downto 0);
	signal adc_states : adc_array;
	
	signal pwm_duty_cycles : pwm_array;
	signal pwm_enabled : std_logic_vector(5 downto 0);
	signal pwm_states : std_logic_vector(5 downto 0);
	
	signal arduino_states : std_logic_vector(15 downto 0);
	signal arduino_modes : std_logic_vector(15 downto 0);
	signal gpio_states : std_logic_vector(35 downto 0);
	signal gpio_modes : std_logic_vector(35 downto 0);
	
	signal uart_state : std_logic;
	signal uart_write : std_logic;
	signal uart_pop : std_logic;
	signal uart_full : std_logic;
	signal uart_tx : std_logic;
	signal uart_received : std_logic_vector(7 downto 0);
	signal uart_available : std_logic_vector(7 downto 0);
	
	signal timer_0_unit, timer_1_unit : std_logic_vector(2 downto 0);
	signal timer_0_multiplier, timer_1_multiplier : std_logic_vector(7 downto 0);
	signal timer_0_triggered, timer_1_triggered : std_logic;
	signal timer_0_clear, timer_1_clear : std_logic;
	
	signal random_value : std_logic_vector(7 downto 0);
	signal random_seed_write : std_logic;
	
	signal gpu_swap : std_logic;
	signal gpu_draw_sprite : std_logic;
	signal gpu_draw_pixel : std_logic;
	signal gpu_clear : std_logic;
	signal gpu_freeze : std_logic;
	signal gpu_color : std_logic_vector(7 downto 0);
	signal gpu_x : std_logic_vector(7 downto 0);
	signal gpu_y : std_logic_vector(7 downto 0);
begin
	seg7_0 : seg7 port map(seg7_states(0), hex0);
	seg7_1 : seg7 port map(seg7_states(1), hex1);
	seg7_2 : seg7 port map(seg7_states(2), hex2);
	seg7_3 : seg7 port map(seg7_states(3), hex3);
	seg7_4 : seg7 port map(seg7_states(4), hex4);
	seg7_5 : seg7 port map(seg7_states(5), hex5);
	
	timer_0 : timer 
		port map(
			clock => clock,
			reset => reset,
			clear => timer_0_clear,
			unit => timer_0_unit,
			multiplier => timer_0_multiplier,
			triggered => timer_0_triggered
		);
	timer_1 : timer 
		port map(
			clock => clock,
			reset => reset,
			clear => timer_1_clear,
			unit => timer_1_unit,
			multiplier => timer_1_multiplier,
			triggered => timer_1_triggered
		);
	
	uart : uart_controller
		port map (
			clock => clock,
			reset => reset,
			write_en => uart_write,
			data => port_in,
			rx => arduino(0),
			pop => uart_pop,
			full => uart_full,
			tx => uart_tx,
			received => uart_received,
			available => uart_available
		);
	
	adc : adc_driver
		port map (
			clock => clock,
			reset => reset,
			ch0 => adc_states(0),
			ch1 => adc_states(1),
			ch2 => adc_states(2),
			ch3 => adc_states(3),
			ch4 => adc_states(4),
			ch5 => adc_states(5)
		);
	
	pwm_0 : pwm_driver
		port map (
			clock => clock,
			reset => reset,
			duty_cycle => pwm_duty_cycles(0),
			modulated => pwm_states(0)
		);
	pwm_1 : pwm_driver
		port map (
			clock => clock,
			reset => reset,
			duty_cycle => pwm_duty_cycles(1),
			modulated => pwm_states(1)
		);
	pwm_2 : pwm_driver
		port map (
			clock => clock,
			reset => reset,
			duty_cycle => pwm_duty_cycles(2),
			modulated => pwm_states(2)
		);
	pwm_3 : pwm_driver
		port map (
			clock => clock,
			reset => reset,
			duty_cycle => pwm_duty_cycles(3),
			modulated => pwm_states(3)
		);
	pwm_4 : pwm_driver
		port map (
			clock => clock,
			reset => reset,
			duty_cycle => pwm_duty_cycles(4),
			modulated => pwm_states(4)
		);
	pwm_5 : pwm_driver
		port map (
			clock => clock,
			reset => reset,
			duty_cycle => pwm_duty_cycles(5),
			modulated => pwm_states(5)
		);
		
	rand : random
		port map(
			clock => clock,
			reset => reset,
			seed => port_in,
			seed_write => random_seed_write,
			rand => random_value
		);
	
	gfx : gpu
		port map(
			clock => clock,
			reset => reset,
			hl => hl,
			swap => gpu_swap,
			draw_pixel => gpu_draw_pixel,
			draw_sprite => gpu_draw_sprite,
			clear => gpu_clear,
			param => port_in,
			x => gpu_x,
			y => gpu_y,
			memory => memory,
			address => address,
			freeze => gpu_freeze,
			vga_hs => vga_hs,
			vga_vs => vga_vs,
			vga_r => vga_r,
			vga_g => vga_g,
			vga_b => vga_b
		);
	
	uart_write <= '1' when port_write = '1' and io_port = x"00" else '0';
	uart_pop <= '1' when port_write = '1' and io_port = x"01" else '0';
	
	timer_0_clear <= '1' when port_write = '1' and unsigned(io_port) = 112 else '0';
	timer_1_clear <= '1' when port_write = '1' and unsigned(io_port) = 113 else '0';
	
	random_seed_write <= '1' when port_write = '1' and unsigned(io_port) = 93 else '0';
	
	gpu_draw_pixel <= '1' when port_write = '1' and unsigned(io_port) = 32 else '0';
	gpu_draw_sprite <= '1' when port_write = '1' and unsigned(io_port) = 33 else '0';
	gpu_clear <= '1' when port_write = '1' and unsigned(io_port) = 34 else '0';
	gpu_swap <= '1' when port_write = '1' and unsigned(io_port) = 94 else '0';
	
	leds <= led_states;
	
	freeze <= gpu_freeze or (uart_full and uart_write);
	
	-- Port IO read logic
	process(all)
		variable index : integer range 0 to 255;
		variable sub_index : integer range 0 to 35;
	begin
		index := to_integer(unsigned(io_port));
		if index = 0 then
			port_out <= uart_received;
		elsif index = 1 then
			port_out <= uart_available;
		elsif index >= 2 and index <= 7 then
			port_out <= x"0" & seg7_states(index - 2);
		elsif index >= 8 and index <= 9 then
			port_out <= "0000000" & not buttons(index - 8);
		elsif index >= 10 and index <= 19 then
			port_out <= "0000000" & led_states(index - 10);
		elsif index >= 20 and index <= 29 then
			port_out <= "0000000" & not switches(index - 20);
		elsif index = 30 then
			port_out <= gpu_x;
		elsif index = 31 then
			port_out <= gpu_y;
		elsif index >= 35 and index <= 70 then
			sub_index := index - 35;
			if gpio_modes(sub_index) = '0' then
				port_out <= "0000000" & gpio(sub_index);
			else
				port_out <= "0000000" & gpio_states(sub_index);
			end if;
		elsif index >= 71 and index <= 86 then
			sub_index := index - 71;
			if arduino_modes(sub_index) = '0' then
				port_out <= "0000000" & arduino(sub_index);
			else
				port_out <= "0000000" & arduino_states(sub_index);
			end if;
		elsif index >= 87 and index <= 92 then
			port_out <= adc_states(index - 87);
		elsif index = 93 then
			port_out <= random_value;
		elsif index >= 101 and index <= 106 then
			port_out <= pwm_duty_cycles(index - 101);
		elsif index = 107 then
			port_out <= "0000000" & uart_state;
		elsif index = 108 then
			port_out <= "00000" & timer_0_unit;
		elsif index = 109 then
			port_out <= "00000" & timer_1_unit;
		elsif index = 110 then
			port_out <= timer_0_multiplier;
		elsif index = 111 then
			port_out <= timer_1_multiplier;
		elsif index = 112 then
			port_out <= "0000000" & timer_0_triggered;
		elsif index = 113 then
			port_out <= "0000000" & timer_1_triggered;
		else
			port_out <= x"00";
		end if;
	end process;
	
	-- Port IO write logic
	process(all)
		variable index : integer range 0 to 255;
		variable bool : std_logic;
	begin
		if port_in=x"00" then
			bool := '0';
		else
			bool := '1';
		end if;

		index := to_integer(unsigned(io_port));
		if reset='1' then
			for i in 0 to 5 loop
				seg7_states(i) <= x"0";
				pwm_duty_cycles(i) <= x"00";
			end loop;
			pwm_enabled <= "000000";
			led_states <= "0000000000";
			uart_state <= '0';
			arduino_states <= x"0000";
			arduino_modes <= x"0000";
			gpio_states <= x"000000000";
			gpio_modes <= x"000000000";
			timer_0_unit <= "000";
			timer_1_unit <= "000";
			timer_0_multiplier <= x"00";
			timer_1_multiplier <= x"00";
			gpu_x <= x"00";
			gpu_y <= x"00";
		elsif port_write='1' and rising_edge(clock) then
			if index >= 2 and index <= 7 then
				seg7_states(index - 2) <= port_in(3 downto 0);
			elsif index >= 10 and index <= 19 then
				led_states(index - 10) <= bool;
			elsif index = 30 then
				gpu_x <= port_in;
			elsif index = 31 then
				gpu_y <= port_in;
			elsif index >= 35 and index <= 70 then
				gpio_states(index - 35) <= bool;
			elsif index >= 71 and index <= 86 then
				arduino_states(index - 71) <= bool;
			elsif index = 95 and unsigned(port_in) <= 35 then
				gpio_modes(to_integer(unsigned(port_in))) <= '1';
			elsif index = 96 and unsigned(port_in) <= 35 then
				gpio_modes(to_integer(unsigned(port_in))) <= '0';
			elsif index = 97 and unsigned(port_in) <= 15 then
				arduino_modes(to_integer(unsigned(port_in))) <= '1';
			elsif index = 98 and unsigned(port_in) <= 15 then
				arduino_modes(to_integer(unsigned(port_in))) <= '0';
			elsif index = 99 then
				if unsigned(port_in) = 3 then
					pwm_enabled(0) <= '1';
				elsif unsigned(port_in) = 5 then
					pwm_enabled(1) <= '1';
				elsif unsigned(port_in) = 6 then
					pwm_enabled(2) <= '1';
				elsif unsigned(port_in) = 9 then
					pwm_enabled(3) <= '1';
				elsif unsigned(port_in) = 10 then
					pwm_enabled(4) <= '1';
				elsif unsigned(port_in) = 11 then
					pwm_enabled(5) <= '1';
				end if;
			elsif index = 100 then
				if unsigned(port_in) = 3 then
					pwm_enabled(0) <= '0';
				elsif unsigned(port_in) = 5 then
					pwm_enabled(1) <= '0';
				elsif unsigned(port_in) = 6 then
					pwm_enabled(2) <= '0';
				elsif unsigned(port_in) = 9 then
					pwm_enabled(3) <= '0';
				elsif unsigned(port_in) = 10 then
					pwm_enabled(4) <= '0';
				elsif unsigned(port_in) = 11 then
					pwm_enabled(5) <= '0';
				end if;
			elsif index >= 101 and index <= 106 then
				pwm_duty_cycles(index - 101) <= port_in;
			elsif index = 107 then
				uart_state <= bool;
			elsif index = 108 then
				timer_0_unit <= port_in(2 downto 0);
			elsif index = 109 then
				timer_1_unit <= port_in(2 downto 0);
			elsif index = 110 then
				timer_0_multiplier <= port_in;
			elsif index = 111 then
				timer_1_multiplier <= port_in;
			end if;
		end if;
	end process;
	
	-- Arduino/GPIO logic
	process(all)
	begin
		for i in 0 to 15 loop
			if arduino_modes(i) = '1' then
				if i = 1 and uart_state = '1' then
					arduino(i) <= uart_tx;
				elsif i = 3 and pwm_enabled(0) = '1' then
					arduino(i) <= pwm_states(0);
				elsif i = 5 and pwm_enabled(1) = '1' then
					arduino(i) <= pwm_states(1);
				elsif i = 6 and pwm_enabled(2) = '1' then
					arduino(i) <= pwm_states(2);
				elsif i = 9 and pwm_enabled(3) = '1' then
					arduino(i) <= pwm_states(3);
				elsif i = 10 and pwm_enabled(4) = '1' then
					arduino(i) <= pwm_states(4);
				elsif i = 11 and pwm_enabled(5) = '1' then
					arduino(i) <= pwm_states(5);
				else
					arduino(i) <= arduino_states(i);
				end if;
			else
				arduino(i) <= 'Z';
			end if;
		end loop;
		
		for i in 0 to 35 loop
			if gpio_modes(i) = '1' then
				gpio(i) <= gpio_states(i);
			else
				gpio(i) <= 'Z';
			end if;
		end loop;
	end process;
end architecture;
