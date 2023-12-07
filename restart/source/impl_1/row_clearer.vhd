library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.my_types_package.all;

entity row_clearer is
	port(
		game_clock: in std_logic;
		game_clock_ctr: in unsigned(15 downto 0);
		board: in board_type;
		new_board: out board_type;
		update_board: out std_logic
	);
end row_clearer;


architecture synth of row_clearer is

begin

	
	process(game_clock) begin
		if rising_edge(game_clock) then
			if game_clock_ctr(5 downto 1) = "00000" and board(0) = "0001111111111000" then
				new_board(0) <= "0000000000000000";
				for i in 1 to 15 loop
					new_board(i) <= board(i);
				end loop;
				update_board <= '1';
			end if;
		end if;
	end process;
end;