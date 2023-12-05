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

entity game_logic is
	port(
		clk : in std_logic;
		clk_counter : in unsigned(31 downto 0);
		game_clock : in std_logic;

		valid_input : in std_logic;
		valid_rgb: in std_logic;
		press_rotate : in std_logic;
		press_down : in std_logic;
		press_left : in std_logic;
		press_right : in std_logic;
		press_sel : in std_logic;

		piece_loc : out piece_loc_type := (4d"2", 4d"0"); -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape : out std_logic_vector(15 downto 0);
		board : out board_type;
		special_background : out unsigned(4 downto 0)
);
end game_logic;

architecture synth of game_logic is

	component piece_library is
		port(
			clk : in std_logic;
			piece_code : in std_logic_vector(2 downto 0);
			piece_rotation : in std_logic_vector(1 downto 0);
			piece_output : out std_logic_vector(15 downto 0)
		);
	end component;

	component piece_picker is
		port(
		  clk : in std_logic;
		  clk_counter : in unsigned(31 downto 0);
		  turn: in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
		  new_piece_code : out unsigned(2 downto 0) := "000";
		  new_piece_rotation : out unsigned(1 downto 0) := "00"
	  );
	end component;

	component turn_manager is
		port(
		  clk : in std_logic;
		  turn : in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
		  advance_turn : in std_logic;
		  next_turn : out unsigned(7 downto 0)
	  );
	end component;

	component board_updater is
		port(
		  clk : in std_logic;
		  valid_update : in std_logic;
		  piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		  piece_shape: in std_logic_vector(15 downto 0);
		  stable_board : in board_type;
		  new_board : out board_type
	  );
	end component;

	component collision_check is
		port(
			clk : in std_logic;
			turn : in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
			piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			piece_shape : in std_logic_vector(15 downto 0);
			stable_board : in board_type;
			move_left : in std_logic;
			move_right : in std_logic;
			move_down : in std_logic;
			press_rotate : in std_logic;
			move_down_auto : in std_logic;
			collision_left : out std_logic;
			collision_right : out std_logic;
			collision_down : out std_logic;
			collision_rotate : out std_logic
		);
	end component;

	component row_check is
		port(
		  clk : in std_logic;
		  score : in unsigned(23 downto 0);
		  stable_board : in board_type;
		  new_board : out board_type;
		  new_score : out unsigned(23 downto 0)
	  );
	end component;

	signal rgb_temp : std_logic_vector(5 downto 0); -- the rgb signal we want to send out

	signal turn : unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0

	-- signal piece_loc: piece_loc_type := (4d"2", 4d"0");
	-- signal piece_shape: std_logic_vector(15 downto 0);
	-- signal board: board_type; -- the tetris board

	signal counter : unsigned(31 downto 0);
	signal frame_counter : unsigned(15 downto 0);

	signal piece_rotation : unsigned(1 downto 0);
	signal piece_code : unsigned(2 downto 0);
	signal rotate_delay : unsigned(2 downto 0);
	signal sel_delay : unsigned(2 downto 0);
	signal right_delay : unsigned(2 downto 0);
	signal left_delay : unsigned(2 downto 0);
	signal down_delay : unsigned(2 downto 0);

	signal collision: std_logic;
	signal collision_left : std_logic;
	signal collision_right : std_logic;
	signal collision_down : std_logic;
	signal collision_rotate : std_logic;
	signal move_down_auto : std_logic;

	signal advance_turn : std_logic;
	signal valid_update : std_logic;

begin
	turn_manager_portmap : turn_manager port map(
		clk => clk,
		turn => turn,
		advance_turn => advance_turn,
		next_turn => turn -- WILL THIS WORK ???
	);

	piece_library_portmap : piece_library port map(
		clk,
		std_logic_vector(piece_code),
		std_logic_vector(piece_rotation),
		piece_shape
	);

	-- piece_picker_portmap : piece_picker port map(
	-- 	clk => clk,
	-- 	clk_counter => clk_counter,
	-- 	turn => turn,
	-- 	new_piece_code => piece_code,
	-- 	new_piece_rotation => piece_rotation
	-- );

	-- board_updater_portmap : board_updater port map(
	-- 	clk => clk,
	-- 	valid_update => valid_update,
	-- 	piece_loc => piece_loc,
	-- 	piece_shape => piece_shape,
	-- 	stable_board => board,
	-- 	new_board => board ---- WILL THIS WORK ???
	-- );

	-- collision_check_portmap : collision_check port map(
	-- 	clk,
	-- 	8d"0",
	-- 	piece_loc,
	-- 	piece_shape,
	-- 	board,
	-- 	press_left,
	-- 	press_right,
	-- 	press_down,
	-- 	press_rotate,
	-- 	move_down_auto,
	-- 	collision_left,
	-- 	collision_right,
	-- 	collision_down,
	-- 	collision_rotate
	-- );

	-- row_check_portmap : row_check port map(
	-- 	clk => clk,
	-- 	score => score,
	-- 	stable_board => board,
	-- 	new_board => board,
	-- 	new_score => score
	-- );

	generate_board_row: for y in 0 to 11 generate
		board(y) <= 10b"0";
	end generate;

	board(12) <= "1010000000";
	board(13) <= "1010000000";
	board(14) <= "1010101110";
	board(15) <= "1111111111";

	collision <= collision_down or collision_left or collision_rotate or collision_right;

	move_down_auto <= not valid_input;

	special_background <= 5d"0" when collision = '0' else 5d"1" when collision_down = '1' else 5d"2" when collision_left = '1' else 5d"3" when collision_right = '1' else 5d"3" when collision_rotate = '1';

	process (clk) begin
		if rising_edge(clk) then
			if falling_edge(valid_rgb) then
				if frame_counter(2) = '1' then -- WHAT is frame counter, how does it ever increment? doesnt it get stuck once it hits third bit as 1?

					-- Rotates piece (TODO: check that rotation is valid, i.e., doesn't overlap on anything after rotation)
					if press_rotate = '1' and rotate_delay = 0 then
						piece_rotation <= piece_rotation + 1;
						rotate_delay <= rotate_delay + 1;
					end if;
					if rotate_delay > 0 then
						rotate_delay <= rotate_delay + 1;
					end if;

					-- Swaps falling piece (for testing)
					if press_sel = '1' and sel_delay = 0 then
						piece_code <= piece_code + 1;
						sel_delay <= sel_delay + 1;
					end if;
					if sel_delay > 0 then
						sel_delay <= sel_delay + 1;
					end if;

					-- Movement left
					if press_left = '1' and left_delay = 0 and collision_left = '0' then
						piece_loc(0) <= piece_loc(0) - 1;
						left_delay <= left_delay + 1;
					end if;
					if left_delay > 0 then
						left_delay <= left_delay + 1;
					end if;

					-- Movement right
					if press_right = '1' and right_delay = 0 and collision_right = '0' then
						piece_loc(0) <= piece_loc(0) + 1;
						right_delay <= right_delay + 1;
					end if;
					if right_delay > 0 then
						right_delay <= right_delay + 1;
					end if;

					-- Movement down
					if press_down = '1' and down_delay = 0 then
						piece_loc(1) <= piece_loc(1) + 1;
						down_delay <= down_delay + 1;
					end if;
					if down_delay > 0 then
						down_delay <= down_delay + 1;
					end if;

				else
					frame_counter <= frame_counter + 1;
				end if;
			end if;

			if rising_edge(game_clock) then
				if not falling_edge(valid_rgb) then
					if not collision_down then
						piece_loc(1) <= piece_loc(1) + 1;
						advance_turn <= '0';
					else
						advance_turn <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

end;
