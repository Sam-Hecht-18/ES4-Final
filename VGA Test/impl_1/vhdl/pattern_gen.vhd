library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pattern_gen is
	port(
		valid: in std_logic;
		row: in unsigned(9 downto 0);
		col: in unsigned(9 downto 0);
		rgb: out std_logic_vector(5 downto 0)
	);
end pattern_gen;

architecture synth of pattern_gen is

	component piece is 
    port(
        piece_code : in std_logic_vector(2 downto 0);
		piece_rotation : in std_logic_vector(1 downto 0);
		
        piece_output : out std_logic_vector(15 downto 0)
    );
	end component;
	
	component clock is
	port(
		myClock : out std_logic
	  );
	end component;
		

	type board_type is array (9 downto 0, 15 downto 0) of std_logic_vector(5 downto 0);
	signal board : board_type;
	signal rgb_temp : std_logic_vector(5 downto 0);
	signal top_left_row : unsigned(3 downto 0) := 4d"0";
	signal top_left_col : unsigned(3 downto 0) := 4d"3";
	signal curr_piece_shape : std_logic_vector(15 downto 0);
	signal row_board_index : unsigned(3 downto 0);
	signal col_board_index : unsigned(3 downto 0);
	signal index_in_piece_shape : unsigned(3 downto 0);
	signal game_clock : std_logic := '1';  
begin
	
	piece_drop_clock : clock port map(myClock => game_clock);
	
	piece_device : piece port map("011", "00", curr_piece_shape);
	--top_left_row <= 4d"0";
	--top_left_col <= 4d"3";
	
	generate_board_row: for ROW in 0 to 9 generate
		generate_board_col: for COL in 0 to 15 generate
			board(ROW, COL) <= 6d"19";
		end generate;
	end generate;
	
	row_board_index <= row(7 downto 4);
	col_board_index <= col(7 downto 4);
	
	-- index_in_piece_shape <= 15 - (((TO_INTEGER(shift_right(row, 4)) - top_left_row) * 4) + (TO_INTEGER(shift_right(col, 4)) - top_left_col));
	
	
	rgb_temp <= 6b"111111" when (TO_INTEGER(col_board_index) >= top_left_col     and 
							     TO_INTEGER(col_board_index) < top_left_col + 4  and 
								 TO_INTEGER(row_board_index) >= top_left_row     and 
							     TO_INTEGER(row_board_index) < top_left_row + 4  and
								 row <= 256 and col < 160                         and
								 curr_piece_shape(15 - ((TO_INTEGER(row_board_index) - TO_INTEGER(top_left_row)) * 4 + 
												  (TO_INTEGER(col_board_index) - TO_INTEGER(top_left_col)))) = '1')  -- Pixel of piece should be drawn
												  else
		        board(TO_INTEGER(col_board_index), TO_INTEGER(row_board_index)) when (row < 256 and col < 160) else "000000";
	rgb <= rgb_temp when valid = '1' else "000000";
	
	process (game_clock) begin
		if rising_edge(game_clock) then
			if top_left_row < 11 then
				top_left_row <= top_left_row + 1;
			end if;
		end if;
	end process;
		
	
end;
