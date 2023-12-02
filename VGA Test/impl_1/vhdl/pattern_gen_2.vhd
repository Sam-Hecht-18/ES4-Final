library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pattern_gen is
	port(
		clk : in std_logic;
		game_clock : in std_logic;
		valid: in std_logic;
		row: in unsigned(9 downto 0);
		col: in unsigned(9 downto 0);
		rgb: out std_logic_vector(5 downto 0);
		rotate : in std_logic
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

	type board_type is array (9 downto 0, 15 downto 0) of std_logic;
	signal board : board_type;
	signal rgb_temp : std_logic_vector(5 downto 0);
	signal top_left_row : unsigned(3 downto 0) := 4d"0";
	signal top_left_col : unsigned(3 downto 0) := 4d"3";
	signal curr_piece_shape : std_logic_vector(15 downto 0);
	signal row_board_index : unsigned(3 downto 0);
	signal col_board_index : unsigned(3 downto 0);
	signal index_in_piece_shape : unsigned(3 downto 0);
	signal counter : unsigned(31 downto 0);
	signal frame_counter : unsigned(15 downto 0);
begin

	piece_device : piece port map(clk, "011", "00", curr_piece_shape);
	--top_left_row <= 4d"0";
	--top_left_col <= 4d"3";

	-- index_in_piece_shape <= 15 - (((TO_INTEGER(shift_right(row, 4)) - top_left_row) * 4) + (TO_INTEGER(shift_right(col, 4)) - top_left_col));
	row_board_index <= row(7 downto 4);
	col_board_index <= col(7 downto 4);
	board(5, 5) <= '1' when (rotate = '1');

	rgb_temp <= 6b"111111" when (TO_INTEGER(col_board_index) >= top_left_col     and
							     TO_INTEGER(col_board_index) < top_left_col + 4  and
								 TO_INTEGER(row_board_index) >= top_left_row     and
							     TO_INTEGER(row_board_index) < unsigned('0' & std_logic_vector(top_left_row)) + to_unsigned(4, 5)  and
								 row <= 256 and col < 160                         and
								 curr_piece_shape(15 - ((TO_INTEGER(row_board_index) - TO_INTEGER(top_left_row)) * 4 +
												  (TO_INTEGER(col_board_index) - TO_INTEGER(top_left_col)))) = '1')  -- Pixel of piece should be drawn
												  else
		        6b"001100" when (board(TO_INTEGER(col_board_index), TO_INTEGER(row_board_index)) = '1' and row < 256 and col < 160) else
				6b"110010" when (board(TO_INTEGER(col_board_index), TO_INTEGER(row_board_index)) = '0' and row < 256 and col < 160) else "000000";
	rgb <= rgb_temp when valid = '1' else "000000";


	process (clk) begin

		report "Sanity";
		if rising_edge(clk) then
			if row = 480 and col = 640 and frame_counter(2) = '1' then
				report "In 1st branch";
				-- for ROW in 1 to 9 loop
				-- 	for COL in 1 to 15 loop
				-- 		board(ROW, COL) <= '0';
				-- 	end loop;
				-- end loop;
				-- board(0, 0) <= '1';
				-- board(1, 0) <= '1';
				-- board(0, 1) <= '1';

			elsif row = 480 and col = 640 then
				report "In 2nd branch";
				frame_counter <= frame_counter + 1;

			elsif rising_edge(game_clock) then
				report "In 3rd branch";
				if top_left_row < 14 then
					top_left_row <= top_left_row + 1;
				end if;
			end if;
		end if;
	end process;


end;
