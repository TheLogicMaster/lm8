library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gpu is
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
end entity;

architecture impl of gpu is
	component vga_driver is
		port (
			clock : in std_logic;
			reset : in std_logic;
			swap : in std_logic;
			draw : in std_logic;
			color : in std_logic_vector(7 downto 0);
			x : in std_logic_vector(7 downto 0);
			y : in std_logic_vector(7 downto 0);
			vga_hs : out std_logic;
			vga_vs : out std_logic;
			vga_r: out std_logic_vector(3 downto 0);
			vga_g : out std_logic_vector(3 downto 0);
			vga_b : out std_logic_vector(3 downto 0)
		);
	end component;
	
	signal vga_draw : std_logic;
	signal vga_color : std_logic_vector(7 downto 0);
	signal vga_x : std_logic_vector(7 downto 0);
	signal vga_y : std_logic_vector(7 downto 0);
	signal state : unsigned(14 downto 0);
	signal clearing : std_logic;
	signal drawing_sprite : std_logic;
begin
	vga : vga_driver
		port map(
			clock => clock,
			reset => reset,
			swap => swap,
			draw => vga_draw,
			color => vga_color,
			x => vga_x,
			y => vga_y,
			vga_hs => vga_hs,
			vga_vs => vga_vs,
			vga_r => vga_r,
			vga_g => vga_g,
			vga_b => vga_b
		);

	clearing <= '1' when clear = '1' and state(14 downto 7) < x"A0" else '0';
	drawing_sprite <= '1' when draw_sprite = '1' and state < x"41" else '0';
	vga_draw <= '1' when draw_pixel = '1' or clearing = '1' or (drawing_sprite = '1' and state > 0 and memory /= x"00") else '0';
	freeze <= clearing or drawing_sprite;
	address <= std_logic_vector(unsigned(hl) + resize(state, 16));
	
	process(all)
		variable sub_state : unsigned(14 downto 0);
	begin
		if draw_pixel = '1' then
			vga_color <= param;
			vga_x <= x;
			vga_y <= y;
		elsif draw_sprite = '1' then
			vga_color <= memory;
			sub_state := state - 1;
			vga_x <= std_logic_vector(unsigned(x) + resize(unsigned(sub_state(2 downto 0)), 8));
			vga_y <= std_logic_vector(unsigned(y) + resize(unsigned(sub_state(5 downto 3)), 8));
		elsif clear = '1' then
			vga_color <= param;
			vga_x <= std_logic_vector(state(14 downto 7));
			vga_y <= "0" & std_logic_vector(state(6 downto 0));
		else
			vga_color <= x"00";
			vga_x <= x"00";
			vga_y <= x"00";
		end if;
	end process;
	
	process(all)
	begin
		if reset = '1' then
			state <= to_unsigned(0, 15);
		elsif rising_edge(clock) then
			if draw_sprite = '1' then
				if state < x"41" then
					state <= state + 1;
				else
					state <= to_unsigned(0, 15);
				end if;
			elsif clear = '1' then
				if state(14 downto 7) < x"A0" then
					state <= state + 1;
				else
					state <= to_unsigned(0, 15);
				end if;
			else
				state <= to_unsigned(0, 15);
			end if;
		end if;
	end process;
end impl;
