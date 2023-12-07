library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_over_screen is
  port(
	clk : in std_logic;
	--final_score : in unsigned(16 downto 0); -- allows maximum score of 2^17 - 1 = 131,071
	rgb_row : in unsigned(9 downto 0);
	rgb_col : in unsigned(9 downto 0);
	rgb : out std_logic_vector(5 downto 0)
  );
end game_over_screen;


architecture synth of game_over_screen is


begin
	-- simple for testing
	rgb <= "000011" when rgb_col < 320 else "111111";

end;