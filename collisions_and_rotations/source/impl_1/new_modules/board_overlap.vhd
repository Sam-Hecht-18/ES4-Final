library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of unsigned(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (15 downto 0) of std_logic_vector(0 to 12);
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_types_package.all;

entity board_overlap is
  	port(
		clk : in std_logic;
		union_or_intersection : in std_logic;
		piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape: in std_logic_vector(15 downto 0);
		piece_bottom_row : out unsigned(1 downto 0);
		overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : out std_logic_vector(3 downto 0)
	);
end board_overlap;

architecture synth of board_overlap is
	signal piece_bottom_row_loc : unsigned(5 downto 0);
	signal board_shadow_row_1, board_shadow_row_2, board_shadow_row_3, board_shadow_row_4 : std_logic_vector(3 downto 0);
	signal piece_row_1, piece_row_2, piece_row_3, piece_row_4 : std_logic_vector(3 downto 0);
begin
	piece_row_1 <= piece_shape(15 downto 12);
	piece_row_2 <= piece_shape(11 downto 8);
	piece_row_3 <= piece_shape(7 downto 4);
	piece_row_4 <= piece_shape(3 downto 0);

	piece_bottom_row <= 2d"3" when (piece_row_4 /= 4b"0") else 2d"2" when (piece_row_3 /= 4b"0") else 2d"1" when (piece_row_2 /= 4b"0") else 2d"0";
	piece_bottom_row_loc <= 6b"0" + piece_loc(1) + piece_bottom_row;

	board_shadow_row_1 <= stable_board(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3);
	board_shadow_row_2 <= stable_board(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row >= 2d"1") else 4b"0";
	board_shadow_row_3 <= stable_board(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row >= 2d"2") else 4b"0";
	board_shadow_row_4 <= stable_board(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row = 2d"3") else 4b"0";

	overlap_row_1 <= board_shadow_row_1 or piece_row_1 when union_or_intersection = '0' else board_shadow_row_1 and piece_row_1;
	overlap_row_1 <= board_shadow_row_2 or piece_row_2 when union_or_intersection = '0' else board_shadow_row_2 and piece_row_2;
	overlap_row_1 <= board_shadow_row_3 or piece_row_3 when union_or_intersection = '0' else board_shadow_row_3 and piece_row_3;
	overlap_row_1 <= board_shadow_row_4 or piece_row_4 when union_or_intersection = '0' else board_shadow_row_4 and piece_row_4;
end;
