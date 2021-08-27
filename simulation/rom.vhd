-- ROM component that uses a Memory Initialization File to optimize build times

library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity rom is
	port
	(
		Address : in std_logic_vector (14 downto 0);
		Clock	: in std_logic;
		Data : out std_logic_vector (7 downto 0)
	);
end rom;

architecture impl of rom is
begin
	altsyncram_component : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "rom.mif",
		intended_device_family => "MAX 10",
		lpm_hint => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=prgm",
		lpm_type => "altsyncram",
		numwords_a => 32768,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 15,
		width_a => 8,
		width_byteena_a => 1
	)
	port map (
		address_a => Address,
		clock0 => Clock,
		q_a => Data
	);

end impl;
