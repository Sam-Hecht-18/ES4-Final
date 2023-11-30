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
		piece_output <= "0100010001000100" when piece_code = "000" else -- I-shape
						"0100010001100000" when piece_code = "001" else -- L-shape
						"0010001001100000" when piece_code = "010" else -- J-shape
						"0110110000000000" when piece_code = "011" else -- S-shape
						"0110001100000000" when piece_code = "100" else -- Z-shape
						"1110010000000000" when piece_code = "101" else -- T-shape
						"0110011000000000" when piece_code = "110" else -- O-shape
						"1111111111111111";								-- BLOCK shape for testing purposes
	-- end if;

end;