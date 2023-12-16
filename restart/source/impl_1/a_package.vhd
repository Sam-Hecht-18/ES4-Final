library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package my_types_package is
	type piece_loc_type is array(1 downto 0) of unsigned(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (15 downto 0) of std_logic_vector(0 to 15);
	type State is (WELCOME_STATE, GAMEPLAY_STATE, GAMEOVER_STATE);

end package;