library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of unsigned(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (0 to 18) of std_logic_vector(0 to 15);
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_types_package.all;

entity turn_manager is
  	port(
		clk : in std_logic;
		turn : in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
		advance_turn : in std_logic;
		next_turn : out unsigned(7 downto 0)
	);
end turn_manager;

architecture synth of turn_manager is
begin
	process(advance_turn) begin
		if rising_edge(advance_turn) then
			next_turn <= turn + 1;
		end if;
	end process;
end;
