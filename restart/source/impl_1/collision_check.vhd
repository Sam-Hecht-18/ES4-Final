library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.my_types_package.all;

entity collision_check is
  	port(
		piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape : in std_logic_vector(15 downto 0);
		next_piece_rotation: in std_logic_vector(15 downto 0);
		stable_board : in board_type;
		press_left : in std_logic;
		press_right : in std_logic;
		press_down : in std_logic;
		press_rotate : in std_logic;
		move_down_auto : in std_logic;
		collision_left : out std_logic;
		collision_right : out std_logic;
		collision_down : out std_logic;
		collision_rotate: out std_logic
);
end collision_check;

architecture synth of collision_check is

	signal future_piece_loc : piece_loc_type;

	signal piece_bottom_row : unsigned(1 downto 0);
	signal piece_bottom_row_loc : unsigned(5 downto 0);

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

	signal piece_right_col_loc : unsigned(3 downto 0);
	signal piece_left_col_loc : unsigned(3 downto 0);
	signal shape_to_compare : std_logic_vector(15 downto 0);

begin

	-- Invariant - You cannot update future_piece_loc to be different from piece_loc when trying to rotate
	-- Invariant - only 1 of future_piece_loc(1) and future_piece_loc(0) can update at once
	--		In fact, future_piece_loc(1) takes precedence
	
	future_piece_loc(1) <= piece_loc(1) + 1 when (press_down = '1' or move_down_auto = '1') else piece_loc(1);
	
	shape_to_compare <= piece_shape when (press_down = '1' or move_down_auto = '1' or press_rotate = '0') else next_piece_rotation;

	future_piece_loc(0) <= piece_loc(0) + press_right when (press_left = '0' and move_down_auto = '0' and press_down = '0' and press_rotate = '0') else
						   piece_loc(0) - press_left  when (move_down_auto = '0' and press_down = '0' and press_rotate = '0') else
						   piece_loc(0);


	-- HERE: check if we have hit right or left board edge !!!

	piece_col_1 <= shape_to_compare(15) & shape_to_compare(11) & shape_to_compare(7) & shape_to_compare(3);
	piece_col_2 <= shape_to_compare(14) & shape_to_compare(10) & shape_to_compare(6) & shape_to_compare(2);
	piece_col_3 <= shape_to_compare(13) & shape_to_compare(9)  & shape_to_compare(5) & shape_to_compare(1);
	piece_col_4 <= shape_to_compare(12) & shape_to_compare(8)  & shape_to_compare(4) & shape_to_compare(0);
	piece_left_col <= 2d"0" when (piece_col_1 /= 4b"0") else 2d"1" when (piece_col_2 /= 4b"0") else 2d"2" when (piece_col_3 /= 4b"0") else 2d"3";
	piece_right_col <= 2d"3" when (piece_col_4 /= 4b"0") else 2d"2" when (piece_col_3 /= 4b"0") else 2d"1" when (piece_col_2 /= 4b"0") else 2d"0";

	piece_left_col_loc <= piece_loc(0) + piece_left_col;
	piece_right_col_loc <= piece_loc(0) + piece_right_col;
	
	-- We've hit right if we're rotating and we're gonna be off the screen
	-- We've hit right if we're not rotating and we're on the far right column
	hit_right <= '1' when (piece_right_col_loc >= 4d"13" and press_rotate = '1' and press_down = '0' and move_down_auto = '0') else
				 '1' when (piece_right_col_loc = 4d"12" and press_rotate = '0') else '0';	
	
	-- We've hit left if we're rotating and we're gonna be off the screen
	-- We've hit left if we're not rotating and we're on the far left column
	hit_left <= '1' when (piece_left_col_loc <= 4d"2" and press_rotate = '1' and press_down = '0' and move_down_auto = '0') else
				'1' when (piece_left_col_loc = 4d"3" and press_rotate = '0') else '0';

	-- HERE: check if we have hit bottom !!!

	-- Get the four rows of the current piece
	piece_row_1 <= shape_to_compare(15 downto 12);
	piece_row_2 <= shape_to_compare(11 downto 8);
	piece_row_3 <= shape_to_compare(7 downto 4);
	piece_row_4 <= shape_to_compare(3 downto 0);

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

	hit_piece <= '1' when (overlap_row_1 & overlap_row_2 & overlap_row_3 & overlap_row_4 /= 16b"0") else '0';

	-- You are colliding on the left if
		-- You are hitting a piece or the left wall and pressing left
		-- You are trying to move down or rotate in some manner
	collision_left <= ((hit_piece or hit_left) and press_left) or move_down_auto or press_down or press_rotate;

	-- You are colliding on the right if
		-- You are hitting a piece or the right wall and pressing right and not pressing left
		-- You are trying to move down or rotate in some manner
	 collision_right <= ((hit_piece or hit_right) and press_right and not press_left) or move_down_auto or press_down or press_rotate;
	
	-- You are colliding trying to rotate if
		-- You are pressing rotate and you hit piece or hit right or hit left or hit down
		-- You are trying to move down in some manner
	collision_rotate <= (press_rotate and (hit_piece or hit_right or hit_left or hit_bottom)) or move_down_auto or press_down;
	-- You are colliding on the bottom if
		-- You are hitting a piece or hitting the bottom of the board and you're trying to move down
	collision_down <= (hit_piece or hit_bottom) and (press_down or move_down_auto);
	

end;
