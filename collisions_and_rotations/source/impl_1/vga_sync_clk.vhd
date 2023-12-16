library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_sync_clk is
  port(
	clk : in std_logic;
	clk_counter : in unsigned(31 downto 0);
	rgb_row : in unsigned(9 downto 0);
	rgb_col : in unsigned(9 downto 0);
	valid_rgb : in std_logic;
	valid_input : out std_logic;
	valid_output : out std_logic;
	valid_output_ctr : out unsigned(15 downto 0) := 16b"0"
  );
end vga_sync_clk;

architecture synth of vga_sync_clk is
	signal validity_ctr : unsigned(31 downto 0);
begin

	valid_input <= '1' when rgb_row > 481 and rgb_row < 520 else '0';
	valid_output <= '1' when rgb_row > 520 and rgb_row < 525 else '0';

    process (rgb_row) begin
        if rising_edge(valid_output) then
			valid_output_ctr <= valid_output_ctr + 1;
		end if;
    end process;

end;