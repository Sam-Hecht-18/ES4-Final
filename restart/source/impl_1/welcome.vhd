library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity welcome_screen is
  port(
	clk : in std_logic;
	rgb_row : in unsigned(9 downto 0);
    rgb_col : in unsigned(9 downto 0);
	rgb : out std_logic_vector(5 downto 0)
  );
end welcome_screen;

architecture synth of welcome_screen is


begin
	-- simple for testing
	rgb <= "110000" when rgb_col < 320 else "000000";

end;