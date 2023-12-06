library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score is 
    port(
		game_clock : in std_logic;

        --Binary representation of score
        score_binary : in std_logic_vector(10 downto 0);

        --Display of digits we use
		digit_1 : in std_logic_vector(24 downto 0);
        digit_2 : in std_logic_vector(24 downto 0);
        digit_3 : in std_logic_vector(24 downto 0)

    );
end score;

architecture synth of score is 

signal ones_binary : std_logic_vector(10 downto 0);
signal tens_binary : std_logic_vector(10 downto 0);
signal hundreds_binary : std_logic_vector(10 downto 0);

begin
--extract value of each place in binary
ones_binary <= score_binary mod 11b"10";
tens_binary <= score_binary mod 11b"100" - ones_binary;
hundreds_binary <= score_binary - tens_binary - ones_binary;

process(game_clock) begin
    if rising_edge(game_clock) then
        case ones_binary is
        --ones digit
            when "00000000000" => digit_1 <= "0111001010010100101001110";
            when "00000000001" => digit_1 <= "0110000100001000010001110";
            when "00000000010" => digit_1 <= "0111000010001000100001110";
            when "00000000011" => digit_1 <= "0111000010001100001001110";
            when "00000000100" => digit_1 <= "0101001010011100001000010";
            when "00000000101" => digit_1 <= "0111001000001000001001110";
            when "00000000110" => digit_1 <= "0111001000011100101001110";
            when "00000000111" => digit_1 <= "0111000010001000100001000";
            when "00000001000" => digit_1 <= "0111001010011100101001110";
            when "00000001001" => digit_1 <= "0111001010011100001000010";
            when others => digit_1 <= "1111111111111111111111111";
        end case;

        case tens_binary is
        --tens digit
            when "00000000000" => digit_2 <= "0111001010010100101001110";
            when "00000000001" => digit_2 <= "0110000100001000010001110";
            when "00000000010" => digit_2 <= "0111000010001000100001110";
            when "00000000011" => digit_2 <= "0111000010001100001001110";
            when "00000000100" => digit_2 <= "0101001010011100001000010";
            when "00000000101" => digit_2 <= "0111001000001000001001110";
            when "00000000110" => digit_2 <= "0111001000011100101001110";
            when "00000000111" => digit_2 <= "0111000010001000100001000";
            when "00000001000" => digit_2 <= "0111001010011100101001110";
            when "00000001001" => digit_2 <= "0111001010011100001000010";
            when others => digit_2 <= "1111111111111111111111111";
        end case;
        
        case hundreds_binary is
        --tens digit
            when "00000000000" => digit_3 <= "0111001010010100101001110";
            when "00000000001" => digit_3 <= "0110000100001000010001110";
            when "00000000010" => digit_3 <= "0111000010001000100001110";
            when "00000000011" => digit_3 <= "0111000010001100001001110";
            when "00000000100" => digit_3 <= "0101001010011100001000010";
            when "00000000101" => digit_3 <= "0111001000001000001001110";
            when "00000000110" => digit_3 <= "0111001000011100101001110";
            when "00000000111" => digit_3 <= "0111000010001000100001000";
            when "00000001000" => digit_3 <= "0111001010011100101001110";
            when "00000001001" => digit_3 <= "0111001010011100001000010";
            when others => digit_3 <= "1111111111111111111111111";
        end case;
    
    end process;

end;

