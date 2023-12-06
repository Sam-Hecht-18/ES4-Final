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

	signal piece_loc_x : integer := 0;
	signal piece_loc_y : integer := 0;

	signal blank_board : board_type;
	signal stable_board : board_type;
	signal temp_board_shadow : board_type := (others => (others => '0'));
	signal temp_board : board_type;

	type piece_rows_type is array (0 to 3) of std_logic_vector(0 to 3);
	signal piece_rows : piece_rows_type;

	signal piece_row_1, piece_row_2, piece_row_3, piece_row_4 : std_logic_vector(3 downto 0);
begin

	piece_loc_x <= to_integer(piece_loc(0));
	piece_loc_y <= to_integer(piece_loc(1));

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

	-- Get the four rows of the current piece
	piece_row_1 <= piece_shape(15 downto 12);
	piece_row_2 <= piece_shape(11 downto 8);
	piece_row_3 <= piece_shape(7 downto 4);
	piece_row_4 <= piece_shape(3 downto 0);
	piece_rows(0) <= piece_row_1;
	piece_rows(1) <= piece_row_2;
	piece_rows(2) <= piece_row_3;
	piece_rows(3) <= piece_row_4;

	-- THIS GEN STATEMENT IS VERIFIED TO WORK, i.e. it does what it says
	generate_board_row_out: for y in 0 to 15 generate
		temp_board(y) <= temp_board_shadow(y) or blank_board(y);
	end generate;

	new_board <= temp_board;

	process(game_clock) begin
		if rising_edge(game_clock) then

			--for y in 0 to 3 loop
				--for x in 0 to 3 loop
					--temp_board_shadow(y + piece_loc_y)(x + piece_loc_x) <= piece_rows(y)(x);
				--end loop;
			--end loop;
			
			temp_board_shadow(piece_loc_y + 0)(piece_loc_x to piece_loc_x + 3) <= piece_rows(0);
			temp_board_shadow(piece_loc_y + 1)(piece_loc_x to piece_loc_x + 3) <= piece_rows(1);
			temp_board_shadow(piece_loc_y + 2)(piece_loc_x to piece_loc_x + 3) <= piece_rows(2);
			temp_board_shadow(piece_loc_y + 3)(piece_loc_x to piece_loc_x + 3) <= piece_rows(3);

		end if;
	end process;


	--process(game_clock) begin
		--if rising_edge(game_clock) then

			--for y in 0 to piece_loc_y - 1 loop
				--temp_board_shadow(y) <= (others => '0');
			--end loop;

			--for y in piece_loc_y + 4 to 18 loop
				--temp_board_shadow(y) <= (others => '0');
			--end loop;

			--for y in piece_loc_y + 0 to piece_loc_y + 3 loop
				--for x in 0 to piece_loc_x - 1 loop
					--temp_board_shadow(y)(x) <= '0';
				--end loop;

				--for x in piece_loc_x to piece_loc_x + 3 loop
					--temp_board_shadow(y)(x) <= piece_rows(y - piece_loc_y)(x - piece_loc_x);
				--end loop;

				--for x in piece_loc_y + 4 to 15 loop
					--temp_board_shadow(y)(x) <= '0';
				--end loop;
			--end loop;

			--new_board <= temp_board;

		--end if;
	--end process;

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
