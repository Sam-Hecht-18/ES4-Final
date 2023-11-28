library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity temp_grid is
	port(
		--new_grid: in std_logic_vector(5 downto 0);
		current_grid: out board_type
	);
end temp_grid;

architecture synth of pattern_gen is
	type board_type is array (9 downto 0, 15 downto 0) of std_logic_vector(5 downto 0);
	signal board : board_type;
begin
	board(0, 0) <= 6d"0";
	board(1, 0) <= 6d"1";
	board(2, 0) <= 6d"2";
	board(3, 0) <= 6d"3";
	board(4, 0) <= 6d"4";
	board(5, 0) <= 6d"5";
	board(6, 0) <= 6d"6";
	board(7, 0) <= 6d"7";
	board(8, 0) <= 6d"8";
	board(9, 0) <= 6d"9";

	board(0, 1) <= 6d"10";
	board(1, 1) <= 6d"11";
	board(2, 1) <= 6d"12";
	board(3, 1) <= 6d"13";
	board(4, 1) <= 6d"14";
	board(5, 1) <= 6d"15";
	board(6, 1) <= 6d"16";
	board(7, 1) <= 6d"17";
	board(8, 1) <= 6d"18";
	board(9, 1) <= 6d"19";
end;
