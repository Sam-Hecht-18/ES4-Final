library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of unsigned(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (15 downto 0) of std_logic_vector(0 to 15);
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_types_package.all;

entity row_check is
  	port(
		clk : in std_logic;
		score : in unsigned(23 downto 0);
		stable_board : in board_type;
		new_board : out board_type;
		new_score : out unsigned(23 downto 0)
	);
end row_check;

architecture synth of row_check is
begin

	process(clk) begin
		if rising_edge(clk) then
			for i in 15 downto 0 loop
				if (stable_board(i)(12 downto 3) = "1111111111" and i /= 0) then
					new_score <= score + 1;
					for j in i downto 1 loop
						new_board(j) <= stable_board(j - 1);
					end loop;
				elsif (stable_board(i) = "1111111111" and i = 0) then
					new_board(i) <= "0000000000";
				else
					new_board(i) <= stable_board(i);
				end if;
			end loop;
		end if;
	end process;

end;
