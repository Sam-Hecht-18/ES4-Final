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
	type board_type is array (9 downto 0, 15 downto 0) of std_logic_vector(5 downto 0);
	signal board : board_type;
	signal rgb_temp : std_logic_vector(5 downto 0);
begin
	board(0, 0) <= 6d"0";
	board(1, 0) <= 6d"0";
	board(2, 0) <= 6d"0";
	board(3, 0) <= 6d"0";
	board(4, 0) <= 6d"3";
	board(5, 0) <= 6d"3";
	board(6, 0) <= 6d"3";
	board(7, 0) <= 6d"12";
	board(8, 0) <= 6d"12";
	board(9, 0) <= 6d"12";

	board(0, 1) <= 6d"48";
	board(1, 1) <= 6d"48";
	board(2, 1) <= 6d"48";
	board(3, 1) <= 6d"48";
	board(4, 1) <= 6d"63";
	board(5, 1) <= 6d"63";
	board(6, 1) <= 6d"63";
	board(7, 1) <= 6d"42";
	board(8, 1) <= 6d"31";
	board(9, 1) <= 6d"17";
	
	rgb_temp <= board(TO_INTEGER(shift_right(col, 4)), TO_INTEGER(shift_right(row, 4))) when (unsigned(shift_right(row, 4)) < 2 and col < 160) else "000000";
	rgb <= rgb_temp when valid = '1' else "000000";
end;
