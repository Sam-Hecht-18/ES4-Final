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

architecture synth of vga is
	signal rgb_temp : std_logic_vector(5 downto 0);
begin
	--rgb_temp <= (col xor row) mod 3;
	rgb_temp <= "111111" when col < 320 or col > 600 else "000000";
	rgb <= rgb_temp when valid = '1' else "000000";
end;
