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

entity piece_picker is
  	port(
		game_clock : in std_logic;
		game_clock_ctr : in unsigned(15 downto 0);
		new_piece_code : out unsigned(2 downto 0) := "000";
		new_piece_rotation : out unsigned(1 downto 0) := "00"
	);
end piece_picker;

architecture synth of piece_picker is

begin
	process(game_clock) begin
		new_piece_code <= game_clock_ctr(2 downto 0);
		new_piece_rotation <= game_clock_ctr(4 downto 3);
	end process;
end;
