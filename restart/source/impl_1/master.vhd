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
	
	
	--component renderer is
		--port(
			--valid_rgb : in std_logic;
			--rgb_row : in unsigned(9 downto 0);
			--rgb_col : in unsigned(9 downto 0);
			--rgb : out std_logic_vector(5 downto 0);

			--piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			--piece_shape : in std_logic_vector(15 downto 0);
			--board : in board_type;
			--special_background : in unsigned(4 downto 0)
		--);
	--end component;
	
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
	special_background : in unsigned(4 downto 0);
	
	game_over : in std_logic
	
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
	
	signal draw_white: std_logic;
	
	-- Signals for the renderer
	signal piece_loc: piece_loc_type;
	signal piece_shape: std_logic_vector(15 downto 0);
	signal board: board_type;
	signal special_background: unsigned(4 downto 0);
	

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
	
	--renderer_portmap: renderer port map(
		--valid_rgb,
		--rgb_row,
		--rgb_col,
		--rgb,
		--piece_loc,
		--piece_shape,
		--board,
		--special_background
	--);
	
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
		special_background => special_background,
		
		game_over => sel
		
	 );
	
	piece_loc(0) <= 4d"3";
	piece_loc(1) <= 4d"0";
	piece_shape <= "0100010001000100";
	board(0) <= "0000000000000000";
	board(1) <= "0000000000000000";
	board(2) <= "0000000000000000";
	board(3) <= "0000000000000000";
	board(4) <= "0000000000000000";
	board(5) <= "0000000000000000";
	board(6) <= "0000000000000000";
	board(7) <= "0000000000000000";
	board(8) <= "0000000000000000";
	board(9) <= "0000000000000000";
	board(10) <= "0000000000000000";
	board(11) <= "0000000000000000";
	board(12) <= "0001010000000000";
	board(13) <= "0001010000000000";
	board(14) <= "0001010101110000";
	board(15) <= "0001111111111000";
	
	special_background <= 5d"0";
	
	process (game_clock) begin
		if rising_edge(game_clock) then
			if (up = '1') then
				draw_white <= '1';
			else
				draw_white <= '0';
			end if;
		end if;
	end process;
	
	rotate_out <= up;
end;
		