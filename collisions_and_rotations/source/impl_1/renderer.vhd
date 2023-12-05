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

entity renderer is
	port(
		clk : in std_logic;
		valid_rgb : in std_logic;
		rgb_row : in unsigned(9 downto 0);
		rgb_col : in unsigned(9 downto 0);
		rgb : out std_logic_vector(5 downto 0);

		piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape : in std_logic_vector(15 downto 0);
		board : in board_type;
		special_background : in unsigned(4 downto 0)
	);
end renderer;

architecture synth of renderer is

	signal rgb_temp: std_logic_vector(5 downto 0); -- the rgb signal we want to send out
	signal board_index_y: unsigned(3 downto 0);
	signal board_index_x: unsigned(3 downto 0);
	signal board_index_x_real : integer;
begin

	board_index_y <= rgb_row(7 downto 4);
	board_index_x <= rgb_col(7 downto 4);
	board_index_x_real <= to_integer(board_index_x) + 3;

	rgb_temp <= 6b"101111" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row <= 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 )  -- Pixel of piece should be drawn
							else
		        "101010"    when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '0' and special_background = 5d"0") -- regular gray background
							else
				"110000"    when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '0' and special_background = 5d"1") -- bright red
							else
				"001100"    when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '0' and special_background = 5d"2") -- bright green
							else
				"000011"    when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '0' and special_background = 5d"3") -- bright blue
							else
				"111010"	when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '0' and special_background = 5d"4") -- tan ?
							else
				"010101"	when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '0') -- light gray?
							else
				"111111"	when (rgb_row < 256 and rgb_col < 160) -- white
							else
				"000000"; -- black

	rgb <= rgb_temp when valid_rgb = '1' else "000000";

end;
