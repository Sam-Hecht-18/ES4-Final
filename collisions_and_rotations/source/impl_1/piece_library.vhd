library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity piece_library is
    port(
		game_clock : in std_logic;
        piece_code : in std_logic_vector(2 downto 0);
		piece_rotation : in std_logic_vector(1 downto 0);
        piece_output : out std_logic_vector(15 downto 0)
    );
end piece_library;

architecture synth of piece_library is
begin
	-- piece_output(3 downto 0) <= piece_output(0, 0) & piece_output(0, 1) & piece_output(0, 2) & piece_output(0, 3);
	--  x then --I block
	process(game_clock) begin
		case piece_code & piece_rotation is
			--I shape
			when "00000" => piece_output <= "0100010001000100";
			when "00001" => piece_output <= "0000111100000000";
			when "00010" => piece_output <= "0100010001000100";
			when "00011" => piece_output <= "0000111100000000";
			--L Shape
			when "00100" => piece_output <= "1110100000000000";
			when "00101" => piece_output <= "1100010001000000";
			when "00110" => piece_output <= "0010111000000000";
			when "00111" => piece_output <= "1000100011000000";
			--J shape
			when "01000" => piece_output <= "1110001000000000";
			when "01001" => piece_output <= "0100010011000000";
			when "01010" => piece_output <= "1000111000000000";
			when "01011" => piece_output <= "1100100010000000";
			--S Shape
			when "01100" => piece_output <= "0011011000000000";
			when "01101" => piece_output <= "0100011000100000";
			when "01110" => piece_output <= "0011011000000000";
			when "01111" => piece_output <= "0100011000100000";
			--Z shape
			when "10000" => piece_output <= "1100011000000000";
			when "10001" => piece_output <= "0010011001000000";
			when "10010" => piece_output <= "1100011000000000";
			when "10011" => piece_output <= "0010011001000000";
			--T Shape
			when "10100" => piece_output <= "0000111001000000";
			when "10101" => piece_output <= "0100110001000000";
			when "10110" => piece_output <= "0100111000000000";
			when "10111" => piece_output <= "0100011001000000";
			--O shape
			when "11000" => piece_output <= "0110011000000000";
			when "11001" => piece_output <= "0110011000000000";
			when "11010" => piece_output <= "0110011000000000";
			when "11011" => piece_output <= "0110011000000000";
			--Other inputs (should not happen)
			when "11100" => piece_output <= "1111111111111111";
			when "11101" => piece_output <= "1111111111111111";
			when "11110" => piece_output <= "1111111111111111";
			when "11111" => piece_output <= "1111111111111111";
			when others => piece_output <= "1111111111111111";
		end case;
	end process;

end;