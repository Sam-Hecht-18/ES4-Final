library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.my_types_package.all;

entity master is
	port(
		osc : in std_logic;
		rgb: out std_logic_vector(5 downto 0);
		hsync: out std_logic;
		vsync: out std_logic;
		ctrlr_latch: out std_logic;
		ctrlr_clk: out std_logic;
		rotate_out: out std_logic;
		ctrlr_data: in std_logic
	);
end master; 

architecture synth of master is
		
	component clock_manager is
		port(
			-- Input osc for the PLL
			osc: in std_logic;
			
			-- Output 25.125 Hz clock for pixel drawing on VGA
			clk: out std_logic;
			
			-- Clocks for game logic
			game_clock: out std_logic;
			game_clock_ctr: out unsigned(15 downto 0);
			
			-- Clocks for NES controller
			NEScount: out unsigned(7 downto 0);
			NESclk: out std_logic
		);
	end component;
		
	component vga_sync is
		port(
			clk: in std_logic;
			valid_rgb: out std_logic;
			rgb_row: out unsigned(9 downto 0);
			rgb_col: out unsigned(9 downto 0);
			hsync: out std_logic;
			vsync: out std_logic
		);
	end component;
	
	component nes_controller is
		port(
			latch : out std_logic;
			ctrlr_clk : out std_logic;
			data : in std_logic;
			up : out std_logic;
			down : out std_logic;
			left : out std_logic;
			right : out std_logic;
			sel : out std_logic;
			start : out std_logic;
			b : out std_logic;
			a : out std_logic;
			NEScount : in unsigned(7 downto 0);
			NESclk : in std_logic
		);
	end component;


	component game_state is
	  port(
		clk : in std_logic;
		
		-- for welcome and gameover states
		start : in std_logic;
		
		-- for render state
		valid_rgb : in std_logic;
		rgb_row : in unsigned(9 downto 0);
		rgb_col : in unsigned(9 downto 0);
		rgb : out std_logic_vector(5 downto 0);

		piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape : in std_logic_vector(15 downto 0);
		board : in board_type;
		piece_code : out unsigned(2 downto 0);
		
		game_over : in std_logic;
		curr_state: out State
	  );
	end component;
	
	component game_logic is
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
			piece_code : out unsigned(2 downto 0);
			game_over: out std_logic;
			curr_state: in State
		);
	end component;
	
		
	-- Signals for the clock manager portmap
	signal clk: std_logic;
	signal game_clock: std_logic;
	signal game_clock_ctr: unsigned(15 downto 0);
	signal NEScount: unsigned(7 downto 0);
	signal NESclk: std_logic;
	
	-- Signals for the vga_sync portmap
	signal valid_rgb: std_logic;
	signal rgb_row: unsigned(9 downto 0);
	signal rgb_col: unsigned(9 downto 0);
	
	-- Signals for the nes controller
	signal up: std_logic;
	signal down: std_logic;
	signal left: std_logic;
	signal right: std_logic;
	signal sel: std_logic;
	signal start: std_logic;
	signal a: std_logic;
	signal b: std_logic;
	
	-- Signals for the game state
	signal curr_state: State;
	signal piece_code: unsigned(2 downto 0);
	signal game_over: std_logic;
		-- Signals for the renderer
		signal piece_loc: piece_loc_type;
		signal piece_shape: std_logic_vector(15 downto 0);
		signal board: board_type;



begin
	
	clock_manager_portmap: clock_manager port map(
		osc => osc,
		clk => clk,
		game_clock => game_clock,
		game_clock_ctr => game_clock_ctr,
		NEScount => NEScount,
		NESclk => NESclk	
	);
	
	vga_sync_portmap: vga_sync port map(
		clk => clk,
		valid_rgb => valid_rgb,
		rgb_row => rgb_row,
		rgb_col => rgb_col,
		hsync => hsync,
		vsync => vsync
	);
	
	nes_controller_portmap: nes_controller port map(
		ctrlr_latch,
		ctrlr_clk,
		ctrlr_data,
		up,
		down,
		left,
		right,
		sel,
		start,
		b,
		a,
		NEScount,
		NESclk
	);
	
	game_state_portmap: game_state port map(
		clk => clk,
		
		-- for welcome and gameover states
		start => start,
		
		-- for render state
		valid_rgb => valid_rgb,
		rgb_row => rgb_row,
		rgb_col => rgb_col,
		rgb => rgb,

		piece_loc => piece_loc,
		piece_shape => piece_shape,
		board => board,
		piece_code => piece_code,
		
		game_over => game_over,
		curr_state => curr_state
	 );
	 
	 game_logic_portmap : game_logic port map(
		-- Timing inputs
		game_clock => game_clock,
		game_clock_ctr => game_clock_ctr,

		-- Button inputs
		press_rotate => a,
		press_swap => b,
		press_down => down,
		press_left => left,
		press_right => right,
		press_sel => sel,
		press_up => up,

		-- Output to the game state module for rendering purposes
		piece_loc => piece_loc,
		piece_shape => piece_shape,
		board => board,
		piece_code => piece_code,
		game_over => game_over,
		
		-- Taken as input from the game state module
		curr_state => curr_state
	);
	
	
	rotate_out <= up;
end;
		