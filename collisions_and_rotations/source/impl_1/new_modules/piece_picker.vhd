library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of unsigned(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (15 downto 0) of std_logic_vector(0 to 12);
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_types_package.all;

entity piece_picker is
  	port(
		clk : in std_logic;
		turn: in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
		new_piece_code : out unsigned(2 downto 0) := "000";
		new_piece_rotation : out unsigned(1 downto 0) := "00"
	);
end piece_picker;

architecture synth of piece_picker is

signal clk_counter : unsigned(31 downto 0);

begin
	process(turn) begin
		new_piece_code <= clk_counter(2 downto 0);
		new_piece_rotation <= "00";
	end process;
end;
