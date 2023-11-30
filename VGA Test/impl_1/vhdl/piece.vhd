library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity piece is 
    port(
        piece_code : in std_logic_vector(2 downto 0);
		piece_rotation : in std_logic_vector(1 downto 0);
		
        piece_output : out std_logic_vector(15 downto 0)

    );
end piece;

architecture synth of piece is 
    type piece_array is array (3 downto 0, 3 downto 0) of std_logic;
	signal piece_arr : piece_array;
	
	
begin
	-- piece_output(3 downto 0) <= piece_output(0, 0) & piece_output(0, 1) & piece_output(0, 2) & piece_output(0, 3);
	--  x then --I block
		if piece_rotation = "00" then
			piece_output <= "0100010001000100" when piece_code = "000" else -- I-shape
							"1110100000000000" when piece_code = "001" else -- L-shape
							"1110001000000000" when piece_code = "010" else -- J-shape
							"0011011000000000" when piece_code = "011" else -- S-shape
							"1100011000000000" when piece_code = "100" else -- Z-shape
							"0000111001000000" when piece_code = "101" else -- T-shape
							"0110011000000000" when piece_code = "110" else -- O-shape
							"1111111111111111";								
		elsif piece_rotation = "01" then
			piece_output <= "0000111100000000" when piece_code = "000" else -- I-shape
							"1100010001000000" when piece_code = "001" else -- L-shape
							"0100010011000000" when piece_code = "010" else -- J-shape
							"0100011000100000" when piece_code = "011" else -- S-shape
							"0010011001000000" when piece_code = "100" else -- Z-shape
							"0100110001000000" when piece_code = "101" else -- T-shape
							"0110011000000000" when piece_code = "110" else -- O-shape
							"1111111111111111";		
							
		elsif piece_rotation = "10" then
			piece_output <= "0100010001000100" when piece_code = "000" else -- I-shape
							"0010111000000000" when piece_code = "001" else -- L-shape
							"1000111000000000" when piece_code = "010" else -- J-shape
							"0011011000000000" when piece_code = "011" else -- S-shape
							"1100011000000000" when piece_code = "100" else -- Z-shape
							"0100111000000000" when piece_code = "101" else -- T-shape
							"0110011000000000" when piece_code = "110" else -- O-shape
							"1111111111111111";		
		elsif piece_rotation = "11" then
			piece_output <= "0000111100000000" when piece_code = "000" else -- I-shape
							"1000100011000000" when piece_code = "001" else -- L-shape
							"1100100010000000" when piece_code = "010" else -- J-shape
							"0100011000100000" when piece_code = "011" else -- S-shape
							"0010011001000000" when piece_code = "100" else -- Z-shape
							"0010011000100000" when piece_code = "101" else -- T-shape
							"0110011000000000" when piece_code = "110" else -- O-shape
							"1111111111111111";	




end;