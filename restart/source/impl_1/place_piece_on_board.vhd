library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.my_types_package.all;

entity place_piece_on_board is
  	port(
		piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape: in std_logic_vector(15 downto 0);
		curr_board : in board_type;
		new_board : out board_type
	);
end place_piece_on_board;

architecture synth of place_piece_on_board is

	--component board_overlap is
		--port(
			--clk : in std_logic;
			--union_or_intersection : in std_logic;
			--piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			--piece_shape: in std_logic_vector(15 downto 0);
			--piece_bottom_row : out unsigned(1 downto 0);
			--overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : out std_logic_vector(3 downto 0)
		--);
	--end component;

	signal piece_bottom_row : unsigned(1 downto 0);
	signal piece_bottom_row_loc : unsigned(5 downto 0);

	signal board_shadow_row_1, board_shadow_row_2, board_shadow_row_3, board_shadow_row_4 : std_logic_vector(3 downto 0);
	signal piece_row_1, piece_row_2, piece_row_3, piece_row_4 : std_logic_vector(3 downto 0);
	signal overlap_board: board_type;
	signal overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : std_logic_vector(3 downto 0);
	signal full_overlap_row_1, full_overlap_row_2, full_overlap_row_3, full_overlap_row_4 : std_logic_vector(15 downto 0);
	signal shifted_full_overlap_row_1, shifted_full_overlap_row_2, shifted_full_overlap_row_3, shifted_full_overlap_row_4 : std_logic_vector(15 downto 0);


begin
	-- board_overlap_portmap : board_overlap port map(
	-- 	clk,
	-- 	'0',
	-- 	piece_loc,
	-- 	piece_shape,
	-- 	piece_bottom_row,
	-- 	overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4
	-- );

	-- Get the four rows of the current piece
	piece_row_1 <= piece_shape(15 downto 12);
	piece_row_2 <= piece_shape(11 downto 8);
	piece_row_3 <= piece_shape(7 downto 4);
	piece_row_4 <= piece_shape(3 downto 0);

	piece_bottom_row <= 2d"3" when (piece_row_4 /= 4b"0") else 2d"2" when (piece_row_3 /= 4b"0") else 2d"1" when (piece_row_2 /= 4b"0") else 2d"0";
	piece_bottom_row_loc <= 6b"0" + piece_loc(1) + piece_bottom_row;
	-- hit_bottom <= '1' when (piece_bottom_row_loc = 5d"15") else '0';

	-- piece_rows <= (piece_row_4 /= "0000") & (piece_row_3 /= "0000") & (piece_row_2 /= "0000") & (piece_row_1 /= "0000");

	-- HERE: check if we have hit a piece BEFORE 4x4 hits bottom !!!

	-- Get the four rows of stable grid in piece shadow:
	board_shadow_row_1 <= curr_board(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3);
	board_shadow_row_2 <= curr_board(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row >= 2d"1") else 4b"0";
	board_shadow_row_3 <= curr_board(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row >= 2d"2") else 4b"0";
	board_shadow_row_4 <= curr_board(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) when (piece_bottom_row = 2d"3") else 4b"0";

	
	-- Overlap rows are the combination of the piece and where it would be embedded on the board
	overlap_row_1 <= board_shadow_row_1 or piece_row_1;
	overlap_row_2 <= board_shadow_row_2 or piece_row_2;
	overlap_row_3 <= board_shadow_row_3 or piece_row_3;
	overlap_row_4 <= board_shadow_row_4 or piece_row_4;
	
	-- Full overlap rows are a 16 bit representation of our overlap row
	full_overlap_row_1 <= overlap_row_1 & "000000000000";
	full_overlap_row_2 <= overlap_row_2 & "000000000000";
	full_overlap_row_3 <= overlap_row_3 & "000000000000";
	full_overlap_row_4 <= overlap_row_4 & "000000000000";
	
	-- Shifted overlap rows shift the overlap to the corrcet x position on the board
	--shifted_full_overlap_row_1 <= overlap_row_1 & "000000000000" when piece_loc(0) = 0 else
							       --"0" & overlap_row_1 & "00000000000" when piece_loc(0) = 1 else
							       --"00" & overlap_row_1 & "0000000000" when piece_loc(0) = 2 else
							       --"000" & overlap_row_1 & "000000000" when piece_loc(0) = 3 else
							       --"0000" & overlap_row_1 & "00000000" when piece_loc(0) = 4 else
							       --"00000" & overlap_row_1 & "0000000" when piece_loc(0) = 5 else
							       --"000000" & overlap_row_1 & "000000" when piece_loc(0) = 6 else
							       --"0000000" & overlap_row_1 & "00000" when piece_loc(0) = 7 else
							       --"00000000" & overlap_row_1 & "0000" when piece_loc(0) = 8 else
							       --"000000000" & overlap_row_1 & "000" when piece_loc(0) = 9 else
							       --"0000000000" & overlap_row_1 & "00" when piece_loc(0) = 10 else
							       --"00000000000" & overlap_row_1 & "0" when piece_loc(0) = 11 else
							       --"000000000000" & overlap_row_1;
							   
	--shifted_full_overlap_row_2 <= overlap_row_2 & "000000000000" when piece_loc(0) = 0 else
							      --"0" & overlap_row_2 & "00000000000" when piece_loc(0) = 1 else
							      --"00" & overlap_row_2 & "0000000000" when piece_loc(0) = 2 else
							      --"000" & overlap_row_2 & "000000000" when piece_loc(0) = 3 else
							      --"0000" & overlap_row_2 & "00000000" when piece_loc(0) = 4 else
							      --"00000" & overlap_row_2 & "0000000" when piece_loc(0) = 5 else
							      --"000000" & overlap_row_2 & "000000" when piece_loc(0) = 6 else
							      --"0000000" & overlap_row_2 & "00000" when piece_loc(0) = 7 else
							      --"00000000" & overlap_row_2 & "0000" when piece_loc(0) = 8 else
							      --"000000000" & overlap_row_2 & "000" when piece_loc(0) = 9 else
							      --"0000000000" & overlap_row_2 & "00" when piece_loc(0) = 10 else
							      --"00000000000" & overlap_row_2 & "0" when piece_loc(0) = 11 else
							      --"000000000000" & overlap_row_2;
	
	--shifted_full_overlap_row_3 <= overlap_row_3 & "000000000000" when piece_loc(0) = 0 else
							      --"0" & overlap_row_3 & "00000000000" when piece_loc(0) = 1 else
							      --"00" & overlap_row_3 & "0000000000" when piece_loc(0) = 2 else
							      --"000" & overlap_row_3 & "000000000" when piece_loc(0) = 3 else
							      --"0000" & overlap_row_3 & "00000000" when piece_loc(0) = 4 else
							      --"00000" & overlap_row_3 & "0000000" when piece_loc(0) = 5 else
							      --"000000" & overlap_row_3 & "000000" when piece_loc(0) = 6 else
							      --"0000000" & overlap_row_3 & "00000" when piece_loc(0) = 7 else
							      --"00000000" & overlap_row_3 & "0000" when piece_loc(0) = 8 else
							      --"000000000" & overlap_row_3 & "000" when piece_loc(0) = 9 else
							      --"0000000000" & overlap_row_3 & "00" when piece_loc(0) = 10 else
							      --"00000000000" & overlap_row_3 & "0" when piece_loc(0) = 11 else
							      --"000000000000" & overlap_row_3;
							   
	--shifted_full_overlap_row_4 <= overlap_row_4 & "000000000000" when piece_loc(0) = 0 else
							      --"0" & overlap_row_4 & "00000000000" when piece_loc(0) = 1 else
							      --"00" & overlap_row_4 & "0000000000" when piece_loc(0) = 2 else
							      --"000" & overlap_row_4 & "000000000" when piece_loc(0) = 3 else
							      --"0000" & overlap_row_4 & "00000000" when piece_loc(0) = 4 else
							      --"00000" & overlap_row_4 & "0000000" when piece_loc(0) = 5 else
							      --"000000" & overlap_row_4 & "000000" when piece_loc(0) = 6 else
							      --"0000000" & overlap_row_4 & "00000" when piece_loc(0) = 7 else
							      --"00000000" & overlap_row_4 & "0000" when piece_loc(0) = 8 else
							      --"000000000" & overlap_row_4 & "000" when piece_loc(0) = 9 else
							      --"0000000000" & overlap_row_4 & "00" when piece_loc(0) = 10 else
							      --"00000000000" & overlap_row_4 & "0" when piece_loc(0) = 11 else
							      --"000000000000" & overlap_row_4;
								  
	shifted_full_overlap_row_1 <= std_logic_vector(shift_right(unsigned(full_overlap_row_1), to_integer(piece_loc(0))));
	shifted_full_overlap_row_2 <= std_logic_vector(shift_right(unsigned(full_overlap_row_2), to_integer(piece_loc(0))));
	shifted_full_overlap_row_3 <= std_logic_vector(shift_right(unsigned(full_overlap_row_3), to_integer(piece_loc(0))));
	shifted_full_overlap_row_4 <= std_logic_vector(shift_right(unsigned(full_overlap_row_4), to_integer(piece_loc(0))));


	-- The overlap board is the board as would be after embedding the current piece onto the board
	overlap_board(0) <= shifted_full_overlap_row_1 when (piece_loc(1) = 4d"0") else "0000000000000000";
	
	
	overlap_board(1) <= shifted_full_overlap_row_2 when (piece_loc(1) = 0) else
						shifted_full_overlap_row_1 when (piece_loc(1) = 1) else "0000000000000000";

	overlap_board(2) <= shifted_full_overlap_row_3 when (piece_loc(1) = 0) else
					    shifted_full_overlap_row_2 when (piece_loc(1) = 1) else
						shifted_full_overlap_row_1 when (piece_loc(1) = 2) else "0000000000000000";
						
	generate_overlap_board : for i in 3 to 15 generate
		overlap_board(i) <= shifted_full_overlap_row_4 when (piece_loc(1) = i - 3) else
							shifted_full_overlap_row_3 when (piece_loc(1) = i - 2) else
							shifted_full_overlap_row_2 when (piece_loc(1) = i - 1) else
							shifted_full_overlap_row_1 when (piece_loc(1) = i) else "0000000000000000";
	end generate;
	
	generate_board_row: for y in 0 to 15 generate
		new_board(y) <= overlap_board(y) or curr_board(y);
	end generate;
	--overlap_board(3) <= overlap_row_4 when (piece_loc(1) = 0) else
					    --overlap_row_3 when (piece_loc(1) = 1) else
						--overlap_row_2 when (piece_loc(1) = 2) else
						--overlap_row_1 when (piece_loc(1) = 3) else "0000000000000000";
	
	--overlap_board(4) <= overlap_row_4 when (piece_loc(1) = 1) else
					    --overlap_row_3 when (piece_loc(1) = 2) else
						--overlap_row_2 when (piece_loc(1) = 3) else
						--overlap_row_1 when (piece_loc(1) = 4) else "0000000000000000";
						
	--overlap_board(15) <= overlap_row

	--temp_board_shadow(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_1;
	--temp_board_shadow(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_2 when (piece_bottom_row >= 2d"1") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_3 when (piece_bottom_row >= 2d"2") else 4b"0";
	--temp_board_shadow(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_4 when (piece_bottom_row = 2d"3") else 4b"0";



	-- temp_board <= temp_board_shadow or stable_board; -- MAY NOT WORK !!!
	-- new_board <= temp_board when board_update_enable = '1' else stable_board;

	-- process(game_clock) begin
	-- 	if rising_edge(game_clock) then
	--process(board_update_enable) begin
		--if rising_edge(board_update_enable) then
			-- if board_update_enable = '1' then
				--for i in 15 downto 0 loop
					--if (temp_board(i) = "0001111111111000" and i /= 0) then
						--new_score <= score + 1;
						--for j in i downto 1 loop
							--new_board(j) <= temp_board(j - 1);
						--end loop;
					--elsif (temp_board(i) = "0001111111111000" and i = 0) then
						--new_board(i) <= "0000000000000";
					--else
						--new_board(i) <= temp_board(i);
					--end if;
				--end loop;
			-- end if;
		--end if;
	--end process;

end;
