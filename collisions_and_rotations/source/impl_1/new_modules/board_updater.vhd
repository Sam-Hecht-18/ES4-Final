library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of unsigned(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (0 to 18) of std_logic_vector(0 to 15);
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_types_package.all;

entity board_updater is
  	port(
		game_clock : in std_logic;
		board_update_enable : in std_logic;
		score : in unsigned(23 downto 0);
		piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape: in std_logic_vector(15 downto 0);
		--stable_board : in board_type;
		new_board : out board_type;
		new_score : out unsigned(23 downto 0)
	);
end board_updater;

architecture synth of board_updater is

	signal blank_board : board_type;
	signal stable_board : board_type;
<<<<<<< HEAD
	signal temp_board_shadow : board_type;
=======
	signal temp_board_shadow : board_type := (others => (others => '0'));;
>>>>>>> fe1bb7f (new idea for board updater - use process instead of generate [untested])
	signal temp_board : board_type;

	signal piece_bottom_row : unsigned(1 downto 0);
	signal piece_bottom_row_loc : unsigned(5 downto 0);
	type piece_rows_type is array (0 to 3) of std_logic_vector(0 to 3);
	signal piece_rows : piece_rows_type;
	-- signal piece_rows : std_logic_vector(3 downto 0);

	signal board_shadow_row_1, board_shadow_row_2, board_shadow_row_3, board_shadow_row_4 : std_logic_vector(3 downto 0);
	signal piece_row_1, piece_row_2, piece_row_3, piece_row_4 : std_logic_vector(3 downto 0);
	signal overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : std_logic_vector(3 downto 0);

<<<<<<< HEAD
	constant START_ROW_ABOVE : integer := 0;
	constant END_ROW_ABOVE   : integer := to_integer(piece_loc(1)) - 1;

	constant START_ROW_BELOW : integer := to_integer(piece_loc(1)) + 4;
	constant END_ROW_BELOW   : integer := 18;

	constant START_ROW_BETWEEN : integer := to_integer(piece_loc(1)) + 0;
	constant END_ROW_BETWEEN   : integer := to_integer(piece_loc(1)) + 3;

	constant START_COL_LEFT  : integer := 0;
	constant END_COL_LEFT    : integer := to_integer(piece_loc(0)) - 1;

	constant START_COL_BETWEEN  : integer := to_integer(piece_loc(0));
	constant END_COL_BETWEEN    : integer := to_integer(piece_loc(0)) + 3;

	constant START_COL_RIGHT : integer := to_integer(piece_loc(1)) + 4;
	constant END_COL_RIGHT   : integer := 15;
=======
	-- constant START_ROW_ABOVE : integer := 0;
	-- constant END_ROW_ABOVE   : integer := to_integer(piece_loc(1)) - 1;

	-- constant START_ROW_BELOW : integer := to_integer(piece_loc(1)) + 4;
	-- constant END_ROW_BELOW   : integer := 18;

	-- constant START_ROW_BETWEEN : integer := to_integer(piece_loc(1)) + 0;
	-- constant END_ROW_BETWEEN   : integer := to_integer(piece_loc(1)) + 3;

	-- constant START_COL_LEFT  : integer := 0;
	-- constant END_COL_LEFT    : integer := to_integer(piece_loc(0)) - 1;

	-- constant START_COL_BETWEEN  : integer := to_integer(piece_loc(0));
	-- constant END_COL_BETWEEN    : integer := to_integer(piece_loc(0)) + 3;

	-- constant START_COL_RIGHT : integer := to_integer(piece_loc(1)) + 4;
	-- constant END_COL_RIGHT   : integer := 15;
>>>>>>> fe1bb7f (new idea for board updater - use process instead of generate [untested])

begin

	generate_board_row: for y in 0 to 11 generate
		blank_board(y) <= 16b"0";-- when first_time = '0' else new_board(y);
	end generate;

	blank_board(12) <= "0001010000000000";--  when first_time = '0' else new_board(12);
	blank_board(13) <= "0001010000000000";-- when first_time = '0' else new_board(13);
	blank_board(14) <= "0001010101110000";-- when first_time = '0' else new_board(14);
	blank_board(15) <= "0001111111111000";-- when first_time = '0' else new_board(15);

	blank_board(16) <= 16b"0";-- when first_time = '0' else new_board(y);
	blank_board(17) <= 16b"0";-- when first_time = '0' else new_board(y);
	blank_board(18) <= 16b"0";-- when first_time = '0' else new_board(y);

	--generate_board_row: for y in 0 to 15 generate
		--stable_board(y) <= 16b"0"; when first_time = '0' else new_board(y);
	--end generate;

	-- Get the four rows of the current piece
	piece_row_1 <= piece_shape(15 downto 12);
	piece_row_2 <= piece_shape(11 downto 8);
	piece_row_3 <= piece_shape(7 downto 4);
	piece_row_4 <= piece_shape(3 downto 0);
	piece_rows(0) <= piece_row_1;
	piece_rows(1) <= piece_row_2;
	piece_rows(2) <= piece_row_3;
	piece_rows(3) <= piece_row_4;

	piece_bottom_row <= 2d"3" when (piece_row_4 /= 4b"0") else 2d"2" when (piece_row_3 /= 4b"0") else 2d"1" when (piece_row_2 /= 4b"0") else 2d"0";
	piece_bottom_row_loc <= 6b"0" + piece_loc(1) + piece_bottom_row;
	-- hit_bottom <= '1' when (piece_bottom_row_loc = 5d"15") else '0';

	-- piece_rows <= (piece_row_4 /= "0000") & (piece_row_3 /= "0000") & (piece_row_2 /= "0000") & (piece_row_1 /= "0000");

	-- HERE: check if we have hit a piece BEFORE 4x4 hits bottom !!!

	-- Get the four rows of stable grid in piece shadow:
	--board_shadow_row_1 <= stable_board(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3);
	--board_shadow_row_2 <= stable_board(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row >= 2d"1") else 4b"0";
	--board_shadow_row_3 <= stable_board(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row >= 2d"2") else 4b"0";
	--board_shadow_row_4 <= stable_board(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row = 2d"3") else 4b"0";

	--overlap_row_1 <= board_shadow_row_1 or piece_row_1;
	--overlap_row_2 <= board_shadow_row_2 or piece_row_2;
	--overlap_row_3 <= board_shadow_row_3 or piece_row_3;
	--overlap_row_4 <= board_shadow_row_4 or piece_row_4;

	--temp_board_shadow(0) <= 16b"0" when piece_loc(1) > 0;

	-- generate_temp_board_shadow_row_above_piece: for y in 0 to to_integer(piece_loc(1)) generate
	-- 	temp_board_shadow(y) <= 16b"0";
	-- end generate;
	-- generate_temp_board_shadow_row_below_piece: for y in to_integer(piece_bottom_row_loc) + 1 to 15 generate
	-- 	temp_board_shadow(y) <= 16b"0";
	-- end generate;

	-- generate_temp_board_shadow_row_right_of_piece: for y in to_integer(piece_loc(1)) to to_integer(piece_loc(1)) + 3 generate
	-- 	for x in 0 to to_integer(piece_loc(0)) - 1 generate
	-- 		temp_board_shadow(y)(x) <= '0';
	-- 	end generate;
	-- 	for x in to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3 generate
	-- 		temp_board_shadow(y)(x) <= piece_rows(y - to_integer(piece_loc(1)))(x - to_integer(piece_loc(0)));
	-- 	end generate;
	-- 	for x in to_integer(piece_loc(0)) + 4 generate
	-- 		temp_board_shadow(y)(x) <= '0';
	-- 	end generate;
	-- end generate;
	-- Constants to define the range

	-- Generate statements using constants
	-- SOMETHING IS NOT WORKING HERE -- IT SEEMS TO MAKE ALL ZEROS
<<<<<<< HEAD
	generate_temp_board_shadow_row_above_piece : for y in START_ROW_ABOVE to END_ROW_ABOVE generate
		temp_board_shadow(y) <= (others => '0');
	end generate;

	generate_temp_board_shadow_row_below_piece : for y in START_ROW_BELOW to END_ROW_BELOW generate
		temp_board_shadow(y) <= (others => '0');
	end generate;

	generate_temp_board_shadow_around_piece : for y in START_ROW_BETWEEN to END_ROW_BETWEEN generate
		left_of_piece : for x in START_COL_LEFT to END_COL_LEFT generate
			temp_board_shadow(y)(x) <= '0';
		end generate;

		through_piece : for x in START_COL_BETWEEN to END_COL_BETWEEN generate
			temp_board_shadow(y)(x) <= piece_rows(y - to_integer(piece_loc(1)))(x - to_integer(piece_loc(0)));
		end generate;

		right_of_piece : for x in START_COL_RIGHT to END_COL_RIGHT generate
			temp_board_shadow(y)(x) <= '0';
		end generate;
	end generate;


	--temp_board_shadow(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_1;
	--temp_board_shadow(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_2 when (piece_bottom_row >= 2d"1") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_3 when (piece_bottom_row >= 2d"2") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_4 when (piece_bottom_row = 2d"3") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_1;
	--temp_board_shadow(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_2 when (piece_bottom_row >= 2d"1") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_3 when (piece_bottom_row >= 2d"2") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_4 when (piece_bottom_row = 2d"3") else 4b"0";

	-- THIS GEN STATEMENT IS VERIFIED TO WORK, i.e. it does what it says
	generate_board_row_out: for y in 0 to 15 generate
		temp_board(y) <= temp_board_shadow(y) or blank_board(y);
	end generate;

	--new_board <= temp_board when board_update_enable = '1' else stable_board;
	process(game_clock) begin
		if rising_edge(game_clock) then
			if board_update_enable = '0' then
				new_board <= temp_board;
			--else
				--new_board <= stable_board;
			end if;
=======
	-- generate_temp_board_shadow_row_above_piece : for y in START_ROW_ABOVE to END_ROW_ABOVE generate
	-- 	temp_board_shadow(y) <= (others => '0');
	-- end generate;

	-- generate_temp_board_shadow_row_below_piece : for y in START_ROW_BELOW to END_ROW_BELOW generate
	-- 	temp_board_shadow(y) <= (others => '0');
	-- end generate;

	-- generate_temp_board_shadow_around_piece : for y in START_ROW_BETWEEN to END_ROW_BETWEEN generate
	-- 	left_of_piece : for x in START_COL_LEFT to END_COL_LEFT generate
	-- 		temp_board_shadow(y)(x) <= '0';
	-- 	end generate;

	-- 	through_piece : for x in START_COL_BETWEEN to END_COL_BETWEEN generate
	-- 		temp_board_shadow(y)(x) <= piece_rows(y - to_integer(piece_loc(1)))(x - to_integer(piece_loc(0)));
	-- 	end generate;

	-- 	right_of_piece : for x in START_COL_RIGHT to END_COL_RIGHT generate
	-- 		temp_board_shadow(y)(x) <= '0';
	-- 	end generate;
	-- end generate;

	process(game_clock) begin
		if rising_edge(game_clock) then

			for y in 0 to to_integer(piece_loc(1)) - 1 loop
				temp_board_shadow(y) <= (others => '0');
			end loop;

			for y in to_integer(piece_loc(1)) + 4 to 18 loop
				temp_board_shadow(y) <= (others => '0');
			end loop;

			for y in to_integer(piece_loc(1)) + 0 to to_integer(piece_loc(1)) + 3 loop			loop
				for x in 0 to to_integer(piece_loc(0)) - 1 loop
					temp_board_shadow(y)(x) <= '0';
				end generate;

				for x in to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3 loop
					temp_board_shadow(y)(x) <= piece_rows(y - to_integer(piece_loc(1)))(x - to_integer(piece_loc(0)));
				end loop;

				for x in to_integer(piece_loc(1)) + 4 to 15 loop
					temp_board_shadow(y)(x) <= '0';
				end loop;
			end loop;

			new_board <= temp_board;

>>>>>>> fe1bb7f (new idea for board updater - use process instead of generate [untested])
		end if;
	end process;

	--temp_board_shadow(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_1;
	--temp_board_shadow(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_2 when (piece_bottom_row >= 2d"1") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_3 when (piece_bottom_row >= 2d"2") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= piece_row_4 when (piece_bottom_row = 2d"3") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_1;
	--temp_board_shadow(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_2 when (piece_bottom_row >= 2d"1") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_3 when (piece_bottom_row >= 2d"2") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_4 when (piece_bottom_row = 2d"3") else 4b"0";

	-- THIS GEN STATEMENT IS VERIFIED TO WORK, i.e. it does what it says
	generate_board_row_out: for y in 0 to 15 generate
		temp_board(y) <= temp_board_shadow(y) or blank_board(y);
	end generate;

	--new_board <= temp_board when board_update_enable = '1' else stable_board;
	-- process(game_clock) begin
	-- 	if rising_edge(game_clock) then
	-- 		if board_update_enable = '0' then
	-- 			new_board <= temp_board;
	-- 		--else
	-- 			--new_board <= stable_board;
	-- 		end if;
	-- 	end if;
	-- end process;

	-- temp_board <= temp_board_shadow or stable_board; -- MAY NOT WORK !!!
	-- new_board <= temp_board when board_update_enable = '1' else stable_board;

	-- process(game_clock) begin
	-- 	if rising_edge(game_clock) then
	--process(board_update_enable) begin
		--if rising_edge(board_update_enable) then
			----for index in 0 to 15 loop
			---- if board_update_enable = '1' then
				--for i in 15 downto 1 loop
					--if (temp_board(i)(3 to 12) = "1111111111" and i /= 0) then
						--new_score <= score + 1;
						--for j in i downto 1 loop
							--new_board(j) <= temp_board(j - 1);
						--end loop;
						--new_board(0) <= "0000000000000000";
					--elsif (temp_board(i)(3 to 12) = "1111111111" and i = 0) then
						--new_board(i) <= "0000000000000000";
					--else
						--new_board(i) <= temp_board(i);
					--end if;
				--end loop;
			----end loop;

			---- end if;
		--end if;
	--end process;

end;
