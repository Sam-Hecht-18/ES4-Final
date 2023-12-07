library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity welcome_screen is
  port(
        clk : in std_logic;
        --final_score : in unsigned(16 downto 0); -- allows maximum score of 2^17 - 1 = 131,071
        --rgb_row : in unsigned(9 downto 0);
        --rgb_col : in unsigned(9 downto 0);
        x_coordinate : in unsigned(7 downto 0);
        y_coordinate : in unsigned(6 downto 0);
        rgb : out std_logic_vector(5 downto 0)
  );
end welcome_screen;

architecture synth of welcome_screen is



begin

	rgb <= "111100" when ((x_coordinate >= 40 and x_coordinate < 60 and y_coordinate >= 20 and y_coordinate < 40) or
						  (x_coordinate >= 100 and x_coordinate < 120 and y_coordinate >= 20 and y_coordinate < 40) or
						  (x_coordinate >= 30 and x_coordinate < 50 and y_coordinate >= 80 and y_coordinate < 100) or
						  (x_coordinate >= 110 and x_coordinate < 130 and y_coordinate >= 80 and y_coordinate < 100) or
						  (x_coordinate >= 70 and x_coordinate < 90 and y_coordinate >= 95 and y_coordinate < 115) or
						  (x_coordinate >= 50 and x_coordinate < 70 and y_coordinate >= 90 and y_coordinate < 110) or
						  (x_coordinate >= 90 and x_coordinate < 110 and y_coordinate >= 90 and y_coordinate < 110)) else
			"000000";
end;
