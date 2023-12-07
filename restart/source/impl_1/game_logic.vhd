library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.my_types_package.all;

entity game_logic is
	port(
		game_clock : in std_logic; -- Game clock (ticks once per frame when it finishes drawing on screen, 60 Hz)
		game_clock_ctr : in unsigned(15 downto 0); -- Game clock counter (increments once with each game_clock tick)

		press_rotate : in std_logic;
		press_swap : in std_logic;
		press_down : in std_logic;
		press_left : in std_logic;
		press_right : in std_logic;
		press_sel : in std_logic;
		press_up : in std_logic;


		piece_loc : out piece_loc_type; -- (y,x) from top left of grid to top left of piece 4x4
		piece_shape : out std_logic_vector(15 downto 0);
		board : out board_type;
		special_background : out unsigned(4 downto 0);
		curr_state: in State
);
end game_logic;

architecture synth of game_logic is

	component piece_library is
		port(
			game_clock : in std_logic;
			piece_code : in std_logic_vector(2 downto 0);
			piece_rotation : in std_logic_vector(1 downto 0);
			piece_output : out std_logic_vector(15 downto 0)
		);
	end component;

	--component piece_picker is
		--port(
		  --game_clock : in std_logic;
		  --game_clock_ctr : in unsigned(15 downto 0);
		  --new_piece_code : out unsigned(2 downto 0);
		  --new_piece_rotation : out unsigned(1 downto 0)
	  --);
	--end component;

	--component turn_manager is
		--port(
		  --clk : in std_logic;
		  --turn : in unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
		  --advance_turn : in std_logic;
		  --next_turn : out unsigned(7 downto 0)
	  --);
	--end component;

	component place_piece_on_board is
		port(
			piece_loc: in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			piece_shape: in std_logic_vector(15 downto 0);
			curr_board : in board_type;
			new_board : out board_type
		);
	end component;

	component collision_check is
		port(
			piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			piece_shape : in std_logic_vector(15 downto 0);
			curr_piece_next_rotation : in std_logic_vector(15 downto 0);
			stable_board : in board_type;
			press_left : in std_logic;
			press_right : in std_logic;
			press_down : in std_logic;
			press_rotate : in std_logic;
			move_down_auto : in std_logic;
			collision_left : out std_logic;
			collision_right : out std_logic;
			collision_down : out std_logic;
			collision_rotate: out std_logic
		);
	end component;
	
	component row_clearer is
		port(
			game_clock: in std_logic;
			game_clock_ctr: in unsigned(15 downto 0);
			board: in board_type;
			new_board: out board_type;
			update_board: out std_logic
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

	--signal new_board : board_type;

	--signal turn : unsigned(7 downto 0); -- a number representing the number of times a piece has been added to the grid. starts at 0
	--signal score : unsigned(23 downto 0) := 24d"0";
	--signal new_score : unsigned(23 downto 0);
	-- signal piece_loc: piece_loc_type := (4d"2", 4d"0");
	-- signal piece_shape: std_logic_vector(15 downto 0);
	-- signal board: board_type; -- the tetris board

	--signal counter : unsigned(31 downto 0);
	--signal frame_counter : unsigned(15 downto 0);
	
	signal next_rotation: unsigned(1 downto 0);
	signal curr_piece_next_rotation: std_logic_vector(15 downto 0);
	signal piece_code : unsigned(2 downto 0);
	signal curr_rotation : unsigned(1 downto 0);
	signal next_piece_code : unsigned(2 downto 0);
	signal next_piece_rotation : unsigned(1 downto 0);

	signal rotate_delay : unsigned(2 downto 0);
	signal swap_delay : unsigned(2 downto 0);
	signal right_delay : unsigned(2 downto 0);
	signal left_delay : unsigned(2 downto 0);
	signal down_delay : unsigned(2 downto 0);
	signal up_delay : unsigned(2 downto 0);

	signal collision: std_logic;
	signal collision_left : std_logic;
	signal collision_right : std_logic;
	signal collision_down : std_logic;
	signal collision_rotate : std_logic;

	signal move_down_auto : std_logic;
	signal advance_turn : std_logic;
	-- signal board_update_enable : std_logic;

	signal first_time : std_logic;
	
	-- New board (has the current piece 'embedded')
	signal new_board_embedded: board_type;
	
	signal new_board_cleared_rows: board_type;
	signal clear_rows: std_logic;


begin
	--turn_manager_portmap : turn_manager port map(
		--clk => clk,
		--turn => turn,
		--advance_turn => advance_turn,
		--next_turn => turn -- WILL THIS WORK ???
	--);

	curr_piece_library_portmap : piece_library port map(
		game_clock,
		std_logic_vector(piece_code),
		std_logic_vector(curr_rotation),
		piece_shape
	);
	
	curr_piece_next_rotation_portmap : piece_library port map(
		game_clock,
		std_logic_vector(piece_code),
		std_logic_vector(next_rotation),
		curr_piece_next_rotation
	);

	 place_piece_on_board_portmap : place_piece_on_board port map(
		piece_loc,
		piece_shape,
		board,
		new_board_embedded
	);

	 collision_check_portmap : collision_check port map(
	 	piece_loc,
	 	piece_shape,
		curr_piece_next_rotation,
	 	board,
	 	press_left,
	 	press_right,
	 	press_down,
	 	press_rotate,
	 	move_down_auto,
	 	collision_left,
	 	collision_right,
	 	collision_down,
		collision_rotate
	 );
	 
	 row_clearer_portmap : row_clearer port map(
		game_clock => game_clock,
		game_clock_ctr => game_clock_ctr,
		board => board,
		new_board => new_board_cleared_rows,
		update_board => clear_rows
	);

	--  collision_check_portmap_down : collision_check port map(
	-- 	piece_loc,
	-- 	piece_shape,
	-- 	board,
	-- 	'0',
	-- 	'0',
	-- 	'1',
	-- 	'0,
	-- 	'0',
	-- 	hit_piece_down,
	-- 	hit_edge_down
	-- );

	-- row_check_portmap : row_check port map(
	-- 	clk => clk,
	-- 	score => score,
	-- 	stable_board => board,
	-- 	new_board => board,
	-- 	new_score => score
	-- );
	next_piece_code <= game_clock_ctr(8 downto 6);
	next_piece_rotation <= "00";

	collision <= collision_down or collision_left or collision_right;
	special_background <= 5d"0" when collision = '0' else 
									      5d"1" when collision_down = '1' else
										  5d"2" when collision_left = '1' else 
										  5d"3" when collision_right = '1' else 
										  5d"4";
	-- The next rotation of the current piece
	next_rotation <= curr_rotation + 1;
	
	--board <= new_board_embedded when advance_turn = '1' else board;

	process(game_clock) begin
		if rising_edge(game_clock) then
			if curr_state = WELCOME_STATE then
				first_time <= '0';
			elsif curr_state = GAMEPLAY_STATE then
				-- Initialize Board and piece locations
				if first_time = '0' then
				
					board(0) <= "0001111111111000";
					for y in 1 to 11 loop
						board(y) <= 16b"0";
					end loop;
					
					board(12) <= "0001010000000000";
					board(13) <= "0001010000000000";
					board(14) <= "0001010101110000";
					board(15) <= "0001111111111000";

					piece_loc(0) <= 4d"5";
					piece_loc(1) <= 4d"0";
					
					piece_code <= "000";
					curr_rotation <= "00";
					
					rotate_delay <= "000";
					swap_delay <= "000";
					left_delay <= "000";
					right_delay <= "000";
					down_delay <= "000";
					up_delay <= "000";					
										  
					move_down_auto <= '0';
					first_time <= '1';
					
				-- Not initializing the game - all other game logic
				else
					
					-- Tried to move down but collided - put on boards
					-- Happens on "111111"
					if move_down_auto = '1' and collision_down = '1' then
						advance_turn <= '1';
						
						
						board <= new_board_embedded;
						piece_code <= next_piece_code;
						curr_rotation <= next_rotation;
						piece_loc(0) <= 4d"5";
						piece_loc(1) <= 4d"0";
					
					--elsif clear_rows = '1' then
						--board <= new_board_cleared_rows;
						--clear_rows <= '0';
					elsif game_clock_ctr(4 downto 0) = "00000" then
						board(0) <= "0000000000000000" when board(0) = "0001111111111000" else board(0);
					elsif game_clock_ctr(4 downto 0) = "00001" then
						board(0) <= "0000000000000000" when board(1) = "0001111111111000" else board(0);
						board(1) <= board(0) when board(1) = "0001111111111000" else board(1);
					elsif game_clock_ctr(4 downto 0) = "00010" then
						board(0) <= "0000000000000000" when board(2) = "0001111111111000" else board(0);
						for i in 1 to 2 loop
							board(i) <= board(i - 1) when board(2) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "00011" then
						board(0) <= "0000000000000000" when board(3) = "0001111111111000" else board(0);
						for i in 1 to 3 loop
							board(i) <= board(i - 1) when board(3) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "00100" then
						board(0) <= "0000000000000000" when board(4) = "0001111111111000" else board(0);
						for i in 1 to 4 loop
							board(i) <= board(i - 1) when board(4) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "00101" then
						board(0) <= "0000000000000000" when board(5) = "0001111111111000" else board(0);
						for i in 1 to 5 loop
							board(i) <= board(i - 1) when board(5) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "00110" then
						board(0) <= "0000000000000000" when board(6) = "0001111111111000" else board(0);
						for i in 1 to 6 loop
							board(i) <= board(i - 1) when board(6) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "00111" then
						board(0) <= "0000000000000000" when board(7) = "0001111111111000" else board(0);
						for i in 1 to 7 loop
							board(i) <= board(i - 1) when board(7) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01000" then
						board(0) <= "0000000000000000" when board(8) = "0001111111111000" else board(0);
						for i in 1 to 8 loop
							board(i) <= board(i - 1) when board(8) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01001" then
						board(0) <= "0000000000000000" when board(9) = "0001111111111000" else board(0);
						for i in 1 to 9 loop
							board(i) <= board(i - 1) when board(9) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01010" then
						board(0) <= "0000000000000000" when board(10) = "0001111111111000" else board(0);
						for i in 1 to 10 loop
							board(i) <= board(i - 1) when board(10) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01011" then
						board(0) <= "0000000000000000" when board(11) = "0001111111111000" else board(0);
						for i in 1 to 11 loop
							board(i) <= board(i - 1) when board(11) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01100" then
						board(0) <= "0000000000000000" when board(12) = "0001111111111000" else board(0);
						for i in 1 to 12 loop
							board(i) <= board(i - 1) when board(12) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01101" then
						board(0) <= "0000000000000000" when board(13) = "0001111111111000" else board(0);
						for i in 1 to 13 loop
							board(i) <= board(i - 1) when board(13) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01110" then
						board(0) <= "0000000000000000" when board(14) = "0001111111111000" else board(0);
						for i in 1 to 14 loop
							board(i) <= board(i - 1) when board(14) = "0001111111111000" else board(i);
						end loop;
					elsif game_clock_ctr(4 downto 0) = "01111" then
						board(0) <= "0000000000000000" when board(15) = "0001111111111000" else board(0);
						for i in 1 to 15 loop
							board(i) <= board(i - 1) when board(15) = "0001111111111000" else board(i);
						end loop;
					-- Automatic movement down
					elsif move_down_auto = '1' and collision_down = '0' then
						piece_loc(1) <= piece_loc(1) + 1;
						move_down_auto <= '0';
					
					-- Move down auto (has the most precedence)
					elsif game_clock_ctr(5 downto 0) = "111110" then
						move_down_auto <= '1';
						
					-- Rotates piece
					elsif press_rotate = '1' and rotate_delay = 0 and collision_rotate = '0' then
						curr_rotation <= curr_rotation + 1;
						rotate_delay <= rotate_delay + 1;

					-- Swaps falling piece (for testing)
					elsif press_swap = '1' and swap_delay = 0 then
						piece_code <= piece_code + 1;
						swap_delay <= swap_delay + 1;

					-- Movement down
					elsif press_down = '1' and down_delay = 0 and collision_down = '0' then
						piece_loc(1) <= piece_loc(1) + 1;
						down_delay <= down_delay + 1;

					-- Movement left
					elsif press_left = '1' and left_delay = 0 and collision_left = '0' then
						piece_loc(0) <= piece_loc(0) - 1;
						left_delay <= left_delay + 1;
					
					-- Movement right
					elsif press_right = '1' and right_delay = 0 and collision_right = '0' then
						piece_loc(0) <= piece_loc(0) + 1;
						right_delay <= right_delay + 1;
					
					-- Movement up
					elsif press_up = '1' and up_delay = 0 then
						piece_loc(1) <= piece_loc(1) - 1;
						up_delay <= up_delay + 1;
					end if;
						


					-- Movement delays
					if rotate_delay > 0 then
						rotate_delay <= rotate_delay + 1;
					end if;
					if left_delay > 0 then
						left_delay <= left_delay + 1;
					end if;
					if right_delay > 0 then
						right_delay <= right_delay + 1;
					end if;
					if down_delay > 0 then
						down_delay <= down_delay + 1;
					end if;
					if swap_delay > 0 then
						swap_delay <= swap_delay + 1;
					end if;
					if up_delay > 0 then
						up_delay <= up_delay + 1;
					end if;
					 
				--if game_clock_ctr(5 downto 0) = "111110" then
					--move_down_auto <= '1';
				--elsif (collision_down = '0' and game_clock_ctr(5 downto 0) = "111111") then
					--move_down_auto <= '0';
					--piece_loc(1) <= piece_loc(1) + 1;
					--advance_turn <= '0';
				--elsif (collision_down = '1' and game_clock_ctr(5 downto 0) = "111111") then
					--advance_turn <= '1';
				end if;
			end if;
		end if;
	end process;

end;
