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

entity pattern_gen is
	port(
		clk : in std_logic;
		game_clock : in std_logic;
		valid: in std_logic;
		row: in unsigned(9 downto 0);
		col: in unsigned(9 downto 0);
		rgb: out std_logic_vector(5 downto 0);
		rotate : in std_logic;
		down : in std_logic
	);
end pattern_gen;

architecture synth of pattern_gen is

	component piece is
    port(
		clk : in std_logic;
        	piece_code : in std_logic_vector(2 downto 0);
		piece_rotation : in std_logic_vector(1 downto 0);
        	piece_output : out std_logic_vector(15 downto 0)
    );
	end component;

	component bottom_check is
		port(
			clk: in std_logic;
			turn: in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
			piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			piece_shape: in std_logic_vector(15 downto 0);
			stable_board: in board_type;
			collision: out std_logic
		);
	end component;

	signal board: board_type; -- the tetris board
	signal rgb_temp: std_logic_vector(5 downto 0); -- the rgb signal we want to send out
	signal piece_loc_y: unsigned(3 downto 0) := 4d"0";
	signal piece_loc_x: unsigned(3 downto 0) := 4d"2";

	signal piece_loc: piece_loc_type;
	signal piece_shape: std_logic_vector(15 downto 0);

	signal board_index_y: unsigned(3 downto 0);
	signal board_index_x: unsigned(3 downto 0);


	signal counter : unsigned(31 downto 0);
	signal frame_counter : unsigned(15 downto 0);

	signal piece_rotation : unsigned(1 downto 0);
	signal piece_code : unsigned(2 downto 0);
	signal rotate_delay : unsigned(2 downto 0);
	signal down_delay : unsigned(2 downto 0);


	signal game_clock: std_logic := '1';
	signal collision: std_logic;

begin
	piece_loc(0) <= piece_loc_x;
	piece_loc(1) <= piece_loc_y;
	bottom_check_portmap: bottom_check port map(clk, 8d"0", piece_loc, piece_shape, board, collision);

	piece_device : piece port map(clk, std_logic_vector(piece_code), std_logic_vector(piece_rotation), curr_piece_shape);
	-- piece_shape <= "1110010000000000";

	generate_board_row: for y in 0 to 11 generate
		board(y) <= 10b"0";
	end generate;

	board(12) <= "1010000000";
	board(13) <= "1010000000";
	board(14) <= "1010101110";
	board(15) <= "1111111111";

	board_index_y <= row(7 downto 4);
	board_index_x <= col(7 downto 4);


	rgb_temp <= 6b"111111" when (to_integer(board_index_x) >= piece_loc_x     and
							     to_integer(board_index_x) <= piece_loc_x + 3 and
								 to_integer(board_index_y) >= piece_loc_y     and
								 to_integer(board_index_y) <= unsigned('0' & std_logic_vector(piece_loc_y)) + to_unsigned(3, 5)  and
								 row <= 256 and col < 160                     and

								 piece_shape(
									15 - (    ((to_integer(board_index_y)) - to_integer(piece_loc_y)) * 4
											+ ((to_integer(board_index_x)) - to_integer(piece_loc_x))
										 )
									) = '1'
								 )  -- Pixel of piece should be drawn
							else
		        "101010"    when (row < 256 and col < 160 and board(to_integer(board_index_y))(to_integer(board_index_x)) = '0' and collision = '0')
							else
				"111010"	when (row < 256 and col < 160 and board(to_integer(board_index_y))(to_integer(board_index_x)) = '0')
							else
				"111111"	when (row < 256 and col < 160)
							else
				"000000";

	rgb <= rgb_temp when valid = '1' else "000000";


	process (clk) begin

		if rising_edge(clk) then
			if row = 480 and col = 640 and frame_counter(2) = '1' then
				if rotate = '1' and rotate_delay = 0 then
					piece_rotation <= piece_rotation + 1;
					rotate_delay <= rotate_delay + 1;
				end if;
				if rotate_delay > 0 then
					rotate_delay <= rotate_delay + 1;
				end if;
				if down = '1' and down_delay = 0 then
					piece_code <= piece_code + 1;
					down_delay <= down_delay + 1;
				end if;
				if down_delay > 0 then
					down_delay <= down_delay + 1;
				end if;

				if  = '1' then

			elsif row = 480 and col = 640 then
				frame_counter <= frame_counter + 1;

			elsif rising_edge(game_clock) then
				if not collision then
					piece_loc_y <= piece_loc_y + 1;
				end if;
			end if;
		end if;
	end process;

end;
