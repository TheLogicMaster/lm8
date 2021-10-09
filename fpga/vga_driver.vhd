library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_driver is
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
end entity;

architecture impl of vga_driver is
	type COLOR_ARRAY is array (20480 * 2 - 1 downto 0) of std_logic_vector(11 downto 0);
	
	signal h_cnt : unsigned(10 downto 0);
	signal v_cnt : unsigned(9 downto 0);
	signal vga_clk : std_logic;
	signal display_buffer : COLOR_ARRAY;
	signal vga_color : std_logic_vector(11 downto 0);
	signal vga_x : unsigned(10 downto 0);
	signal vga_y : unsigned(9 downto 0);
	signal buffer_index : unsigned(19 downto 0);
	signal buf : std_logic;

	constant DOUBLE_BUFFER : boolean := true;
begin
	clock_divider : process(all)
	begin
		if reset = '1' then
			vga_clk <= '0';
		elsif rising_edge(clock) then
			vga_clk <= not vga_clk;
		end if;
	end process;

	buffer_control : process(all)
	begin
		if reset = '1' then
			buf <= '0';
		elsif rising_edge(clock) and swap = '1' then
         buf <= not buf;
      end if;
	end process;

	process(all)
		variable r, g, b : unsigned(11 downto 0);
		variable index : integer range 0 to 20480 * 2 - 1;
	begin
		index := to_integer(unsigned(x) + unsigned(y) * 160);
		if buf = '1' and DOUBLE_BUFFER then
			index := index + 20480;
		end if;
		if rising_edge(clock) then
			if draw = '1' then
				r := shift_left("000000" & unsigned(color(7 downto 5)) * 255 / 7, 8);
				g := shift_left("000000" & unsigned(color(4 downto 2)) * 255 / 7, 4);
				b := "00000000" & unsigned(color(1 downto 0)) * 255 / 3;
				display_buffer(index) <= std_logic_vector(r or g or b);
			end if;
		end if;
	end process;
	
	process(all)
		variable data : std_logic_vector(11 downto 0);
	begin
		if reset = '1' then
			vga_color <= X"000";
		elsif rising_edge(clock) then
			data := display_buffer(to_integer(buffer_index));
			if vga_x <= 159 and vga_y <= 127 then
				vga_color <= data;
			else
				vga_color <= x"000";
			end if;
		end if;
	end process;
	
	vga : process(all)
	begin
		if reset = '1' then
			h_cnt <= to_unsigned(0, 11);
			v_cnt <= to_unsigned(0, 10);
			vga_x <= to_unsigned(0, 11);
			vga_y <= to_unsigned(0, 10);
		elsif rising_edge(vga_clk) then
			if h_cnt < 784 and h_cnt >= 144 + 3 + 80 and v_cnt < 514 and v_cnt >= 11 then
				vga_r <= vga_color(11 downto 8);
				vga_g <= vga_color(7 downto 4);
				vga_b <= vga_color(3 downto 0);
			else
				vga_r <= x"0";
				vga_g <= x"0";
				vga_b <= x"0";
			end if;
			
			if h_cnt = 799 then
				h_cnt <= to_unsigned(0, 11);
				if v_cnt = 524 then
					v_cnt <= to_unsigned(0, 10);
				else
					v_cnt <= v_cnt + 1;
				end if;
			else
				h_cnt <= h_cnt + 1;
			end if;
			
			if h_cnt < 96 then
				vga_hs <= '1';
			else
				vga_hs <= '0';
			end if;
				
			if v_cnt < 2 then
				vga_vs <= '1';
			else
				vga_vs <= '0';
			end if;
					
			if buf = '0' and DOUBLE_BUFFER then
				 buffer_index <= vga_x + vga_y * 160 + 20480;
			else
				 buffer_index <= vga_x + vga_y * 160;
			end if;
			
			vga_x <= (h_cnt - 144 - 80) / 3;
			vga_y <= (v_cnt - 11 - 48) / 3;
		end if;
	end process;
end impl;
