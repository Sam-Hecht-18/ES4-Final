library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of unsigned(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (15 downto 0) of std_logic_vector(0 to 9);
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_types_package.all;

entity bottom_check is
  	port(
		clk : in std_logic;
		turn : in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
		piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape : in std_logic_vector(15 downto 0);
		stable_board : in board_type;
		collision : out std_logic
	);
end bottom_check;

architecture synth of bottom_check is
	signal future_piece_loc : piece_loc_type;
	signal piece_bottom_row : unsigned(1 downto 0);
	signal piece_bottom_row_loc : unsigned(5 downto 0);
	signal board_shadow_row_1, board_shadow_row_2, board_shadow_row_3, board_shadow_row_4 : std_logic_vector(3 downto 0);
	signal piece_row_1, piece_row_2, piece_row_3, piece_row_4 : std_logic_vector(3 downto 0);
	signal overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : std_logic_vector(3 downto 0);
	signal collision_temp : std_logic := '0';
	signal hit_bottom : std_logic := '0';
begin

	future_piece_loc(0) <= piece_loc(0);
	future_piece_loc(1) <= piece_loc(1) + 1;

	-- HERE: check if we have hit bottom !!!

	-- Get the four rows of the current piece
	piece_row_1 <= piece_shape(15 downto 12);
	piece_row_2 <= piece_shape(11 downto 8);
	piece_row_3 <= piece_shape(7 downto 4);
	piece_row_4 <= piece_shape(3 downto 0);

	piece_bottom_row <= 2d"3" when (piece_row_4 /= 4b"0") else 2d"2" when (piece_row_3 /= 4b"0") else 2d"1" when (piece_row_2 /= 4b"0") else 2d"0";
	piece_bottom_row_loc <= 6b"0" + piece_loc(1) + piece_bottom_row;
	hit_bottom <= '1' when (piece_bottom_row_loc = 5d"15") else '0';

	-- HERE: check if we have hit a piece BEFORE 4x4 hits bottom !!!

	-- Get the four rows of stable grid in piece shadow:
	board_shadow_row_1 <= stable_board(to_integer(future_piece_loc(1)) + 0)(to_integer(future_piece_loc(0)) to to_integer(future_piece_loc(0)) + 3);
	board_shadow_row_2 <= stable_board(to_integer(future_piece_loc(1)) + 1)(to_integer(future_piece_loc(0)) to to_integer(future_piece_loc(0)) + 3) when (piece_bottom_row >= 2d"1") else 4b"0";
	board_shadow_row_3 <= stable_board(to_integer(future_piece_loc(1)) + 2)(to_integer(future_piece_loc(0)) to to_integer(future_piece_loc(0)) + 3) when (piece_bottom_row >= 2d"2") else 4b"0";
	board_shadow_row_4 <= stable_board(to_integer(future_piece_loc(1)) + 3)(to_integer(future_piece_loc(0)) to to_integer(future_piece_loc(0)) + 3) when (piece_bottom_row = 2d"3") else 4b"0";

	overlap_row_1 <= board_shadow_row_1 and piece_row_1;
	overlap_row_2 <= board_shadow_row_2 and piece_row_2;
	overlap_row_3 <= board_shadow_row_3 and piece_row_3;
	overlap_row_4 <= board_shadow_row_4 and piece_row_4;

	collision_temp <= '1' when (overlap_row_1 & overlap_row_2 & overlap_row_3 & overlap_row_4 /= 16b"0") else '0';

	collision <= collision_temp or hit_bottom;

end;
