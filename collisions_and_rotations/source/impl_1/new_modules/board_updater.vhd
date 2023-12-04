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

entity board_updater is
  	port(
		clk : in std_logic;
		valid_update : in std_logic;
		score : in unsigned(23 downto 0);
		piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape: in std_logic_vector(15 downto 0);
		stable_board : in board_type;
		new_board : out board_type;
		new_score : out unsigned(23 downto 0)
	);
end board_updater;

architecture synth of board_updater is

	component board_overlap is
		port(
			clk : in std_logic;
			union_or_intersection : in std_logic;
			piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			piece_shape: in std_logic_vector(15 downto 0);
			piece_bottom_row : out unsigned(1 downto 0);
			overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : out std_logic_vector(3 downto 0);
		);
	end component;

	signal overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4 : std_logic_vector(3 downto 0);
	signal temp_board_shadow : board_type;
	signal temp_board : board_type;
begin
	board_overlap_portmap : board_overlap port map(clk, '0', piece_loc, piece_shape, piece_bottom_row, overlap_row_1, overlap_row_2, overlap_row_3, overlap_row_4);

	overlap_row_1 <= board_shadow_row_1 or piece_row_1;
	overlap_row_2 <= board_shadow_row_2 or piece_row_2;
	overlap_row_3 <= board_shadow_row_3 or piece_row_3;
	overlap_row_4 <= board_shadow_row_4 or piece_row_4;

	temp_board_shadow(to_integer(piece_loc(1)) + 0)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_1;
	temp_board_shadow(to_integer(piece_loc(1)) + 1)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_2 when (piece_bottom_row >= 2d"1") else 4b"0";
	temp_board_shadow(to_integer(piece_loc(1)) + 2)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_3 when (piece_bottom_row >= 2d"2") else 4b"0";
	temp_board_shadow(to_integer(piece_loc(1)) + 3)(to_integer(piece_loc(0)) to to_integer(piece_loc(0)) + 3) <= overlap_row_4 when (piece_bottom_row = 2d"3") else 4b"0";

	temp_board <= temp_board_shadow or stable board; -- MAY NOT WORK !!!
	-- new_board <= temp_board when valid_update = '1' else stable_board;

	process(clk) begin
		if rising_edge(clk) then
			if valid_update = '1' then
				for i in 15 downto 0 loop
					if (temp_board(i) = "1111111111" and i /= 0) then
						new_score <= score + 1;
						for j in i downto 1 loop
							new_board(j) <= temp_board(j - 1);
						end loop;
					elsif (temp_board(i) = "1111111111" and i = 0) then
						new_board(i) <= "0000000000";
					else
						new_board(i) <= temp_board(i);
					end if;
				end loop;
			end if;
		end if;
	end process;

end;
