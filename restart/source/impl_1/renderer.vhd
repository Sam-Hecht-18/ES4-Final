library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.my_types_package.all;

entity renderer is
	port(
		rgb_row : in unsigned(9 downto 0);
		rgb_col : in unsigned(9 downto 0);
		rgb : out std_logic_vector(5 downto 0);

		piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape : in std_logic_vector(15 downto 0);
		board : in board_type;
		piece_code: in unsigned(2 downto 0)
	);
end renderer;

architecture synth of renderer is

	signal board_index_y: unsigned(3 downto 0);
	signal board_index_x: unsigned(3 downto 0);
	signal board_index_x_real : integer;
begin

	board_index_y <= rgb_row(7 downto 4);
	board_index_x <= rgb_col(7 downto 4);
	board_index_x_real <= to_integer(board_index_x) + 3;

	rgb <= 6b"000000" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and (rgb_row(3 downto 0) = "0000" or rgb_col(3 downto 0) = "0000" or 
										rgb_row(3 downto 0) = "1111" or rgb_col(3 downto 0) = "1111") else
	
			6b"101111" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "000" else
								 
			6b"101101" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "001" else 
								 
			6b"100011" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "010" else 
								 
			6b"001101" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "011" else 
								 
			6b"111001" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "100" else 
								 
			6b"101011" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "101" else 
								 
			6b"100001" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "110" else 
								 
			6b"100111" when (board_index_x_real >= piece_loc(0)     and
							     board_index_x_real <= piece_loc(0) + 3     and
								 to_integer(board_index_y) >= piece_loc(1)     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc(1))) + to_unsigned(3, 5)  and
								 rgb_row < 256 and rgb_col < 160                      and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc(1))) * 4      -- relative row in piece (board - top row) * 4
											+ ((board_index_x_real) - to_integer(piece_loc(0))) 		        -- relative col in piece (board - left col)
										 )
									) = '1'
								 ) and piece_code = "111" else 								 
		        "101010"    when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '0') else
				"111111"	when (rgb_row < 256 and rgb_col < 160 and board(to_integer(board_index_y))(board_index_x_real) = '1') else
				"000000"; -- black


end;
