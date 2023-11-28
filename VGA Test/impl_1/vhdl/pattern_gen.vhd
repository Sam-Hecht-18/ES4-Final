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
	signal rgb_temp : std_logic_vector(5 downto 0);
	--signal rgb_temp2 : std_logic_vector(9 downto 0);
	--signal intermediate : std_logic_vector(9 downto 0);
begin
	--intermediate <= std_logic_vector(col) xor std_logic_vector(row);
	--rgb_temp <= unsigned(intermediate) mod 10b"11";
	--rgb_temp2 <= std_logic_vector(rgb_temp);
	--rgb_temp <= "111111" when col < 320 or col > 600 else "000000";
	rgb_temp <= "110000" when col <= 320 and row <= 240 else "001100" when col > 320 and row <= 240 else "000011" when col <= 320 and row > 240 else "000000";
	rgb <= rgb_temp when valid = '1' else "000000";
end;
