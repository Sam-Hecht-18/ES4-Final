library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of signed(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
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
		move_left : in std_logic;
		move_right : in std_logic;
		move_down : in std_logic;
		rotate : in std_logic;
		move_down_auto : in std_logic;
		collision_left : out std_logic;
		collision_right : out std_logic;
		collision_down : out std_logic;
		collision_rotate : out std_logic
		-- collision : out std_logic
	);
end bottom_check;

architecture synth of bottom_check is
	signal future_piece_loc : piece_loc_type;
	
	signal piece_bottom_row : signed(1 downto 0);
	signal piece_bottom_row_loc : signed(5 downto 0);
	
	signal board_shadow_row_1, board_shadow_row_2, board_shadow_row_3, board_shadow_row_4 : std_logic_vector(3 downto 0);
	signal piece_row_1, piece_row_2, piece_row_3, piece_row_4 : std_logic_vector(3 downto 0);
	signal overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : std_logic_vector(3 downto 0);
	signal hit_piece : std_logic := '0';
	signal hit_bottom : std_logic := '0';
	signal hit_left : std_logic;
	signal hit_right : std_logic;

	signal piece_col_1 : std_logic_vector(3 downto 0);
	signal piece_col_2 : std_logic_vector(3 downto 0);
	signal piece_col_3 : std_logic_vector(3 downto 0);
	signal piece_col_4 : std_logic_vector(3 downto 0);
	
	signal piece_left_col : unsigned(1 downto 0);
	signal piece_right_col : unsigned(1 downto 0);
	
	signal piece_right_col_loc : signed(3 downto 0);
	signal piece_left_col_loc : signed(3 downto 0);

begin

	future_piece_loc(0) <= piece_loc(0) + move_right - move_left;
	future_piece_loc(1) <= piece_loc(1) + move_down + move_down_auto;

	-- HERE: check if we have hit right or left board edge !!!

	piece_col_1 <= piece_shape(15) & piece_shape(11) & piece_shape(7) & piece_shape(3);
	piece_col_2 <= piece_shape(14) & piece_shape(10) & piece_shape(6) & piece_shape(2);
	piece_col_3 <= piece_shape(13) & piece_shape(9)  & piece_shape(5) & piece_shape(1);
	piece_col_4 <= piece_shape(12) & piece_shape(8)  & piece_shape(4) & piece_shape(0);
	piece_left_col <= 2d"0" when (piece_col_1 /= 4b"0") else 2d"1" when (piece_col_2 /= 4b"0") else 2d"2" when (piece_col_3 /= 4b"0") else 2d"3";
	piece_right_col <= 2d"3" when (piece_col_4 /= 4b"0") else 2d"2" when (piece_col_3 /= 4b"0") else 2d"1" when (piece_col_2 /= 4b"0") else 2d"0";

	piece_left_col_loc <= piece_loc(0) + signed(piece_left_col);
	piece_right_col_loc <= piece_loc(0) + signed(piece_right_col);
	hit_right <= '1' when (piece_right_col_loc = 4d"9") else '0';
	hit_left <= '1' when (piece_left_col_loc = 4d"0") else '0';
	

	-- HERE: check if we have hit bottom !!!

	-- Get the four rows of the current piece
	piece_row_1 <= piece_shape(15 downto 12);
	piece_row_2 <= piece_shape(11 downto 8);
	piece_row_3 <= piece_shape(7 downto 4);
	piece_row_4 <= piece_shape(3 downto 0);

	piece_bottom_row <= 2d"3" when (piece_row_4 /= 4b"0") else 2d"2" when (piece_row_3 /= 4b"0") else 2d"1" when (piece_row_2 /= 4b"0") else 2d"0";
	piece_bottom_row_loc <= 6b"0" + piece_loc(1) + signed(piece_bottom_row);
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

	hit_piece <= '1' when (overlap_row_1 & overlap_row_2 & overlap_row_3 & overlap_row_4 /= 16b"0") else '0';

	--collision <= collision_temp or hit_bottom or hit_left or hit_right;
	collision_down <= hit_piece or hit_bottom;
	collision_left <= hit_piece or hit_left;	
	collision_right <= hit_piece or hit_right;


end;
