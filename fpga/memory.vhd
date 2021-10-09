library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity memory is
	port (
		address_a : in std_logic_vector(15 downto 0);
		address_b : in std_logic_vector(15 downto 0);
		data_in_a : in std_logic_vector(7 downto 0);
		data_in_b : in std_logic_vector(7 downto 0);
		write_en : in std_logic;
		clock : in std_logic;
		data_out_a : out std_logic_vector(7 downto 0);
		data_out_b : out std_logic_vector(7 downto 0)
	);
end memory;

architecture impl of memory is
	signal address_low_a : std_logic_vector(14 downto 0);
	signal address_low_b : std_logic_vector(14 downto 0);
	signal data_out_rom_a : std_logic_vector(7 downto 0);
	signal data_out_rom_b : std_logic_vector(7 downto 0);
	signal data_out_ram_a : std_logic_vector(7 downto 0);
	signal data_out_ram_b : std_logic_vector(7 downto 0);
begin
	address_low_a <= address_a(14 downto 0);
	address_low_b <= address_b(14 downto 0);
	
	data_out_a <= data_out_rom_a when address_a(15)='0' else data_out_ram_a;
	data_out_b <= data_out_rom_b when address_b(15)='0' else data_out_ram_b;

	rom : altsyncram
		generic map (
			address_reg_b => "CLOCK0",
			clock_enable_input_a => "BYPASS",
			clock_enable_input_b => "BYPASS",
			clock_enable_output_a => "BYPASS",
			clock_enable_output_b => "BYPASS",
			indata_reg_b => "CLOCK0",
			init_file => "rom.mif",
			intended_device_family => "MAX 10",
			lpm_type => "altsyncram",
			numwords_a => 32768,
			numwords_b => 32768,
			operation_mode => "BIDIR_DUAL_PORT",
			outdata_aclr_a => "NONE",
			outdata_aclr_b => "NONE",
			outdata_reg_a => "UNREGISTERED",
			outdata_reg_b => "UNREGISTERED",
			power_up_uninitialized => "FALSE",
			widthad_a => 15,
			widthad_b => 15,
			width_a => 8,
			width_b => 8,
			width_byteena_a => 1,
			width_byteena_b => 1,
			wrcontrol_wraddress_reg_b => "CLOCK0"
		)
		port map (
			address_a => address_low_a,
			address_b => address_low_b,
			clock0 => clock,
			data_a => data_in_a,
			data_b => data_in_b,
			wren_a => '0',
			wren_b => '0',
			q_a => data_out_rom_a,
			q_b => data_out_rom_b
		);

	-- Comment out port B ports and operation_mode to disable peripheral memory access for memory debugging
	-- Uncomment lpm_hint and SINGLE_PORT operation_mode 
	ram : altsyncram
		generic map (
			address_reg_b => "CLOCK0",
			clock_enable_input_a => "BYPASS",
			clock_enable_input_b => "BYPASS",
			clock_enable_output_a => "BYPASS",
			clock_enable_output_b => "BYPASS",
			indata_reg_b => "CLOCK0",
			intended_device_family => "MAX 10",
			--lpm_hint => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=ram",
			lpm_type => "altsyncram",
			numwords_a => 32768,
			numwords_b => 32768,
			--operation_mode => "SINGLE_PORT",
			operation_mode => "BIDIR_DUAL_PORT",
			outdata_aclr_a => "NONE",
			outdata_aclr_b => "NONE",
			outdata_reg_a => "UNREGISTERED",
			outdata_reg_b => "UNREGISTERED",
			power_up_uninitialized => "FALSE",
			read_during_write_mode_mixed_ports => "DONT_CARE",
			read_during_write_mode_port_a => "NEW_DATA_WITH_NBE_READ",
			read_during_write_mode_port_b => "NEW_DATA_WITH_NBE_READ",
			widthad_a => 15,
			widthad_b => 15,
			width_a => 8,
			width_b => 8,
			width_byteena_a => 1,
			width_byteena_b => 1,
			wrcontrol_wraddress_reg_b => "CLOCK0"
		)
		port map (
			address_a => address_low_a,
			address_b => address_low_b,
			clock0 => clock,
			data_a => data_in_a,
			data_b => data_in_b,
			wren_a => write_en,
			wren_b => '0',
			q_a => data_out_ram_a,
			q_b => data_out_ram_b
		);
end impl;