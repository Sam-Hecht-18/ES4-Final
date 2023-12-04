library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_types_package is
	type piece_loc_type is array(1 downto 0) of signed(3 downto 0);  -- (x, y) from top left of grid to top left of piece 4x4
	type board_type is array (15 downto 0) of std_logic_vector(0 to 9);
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_types_package.all;

entity master is
	port(
		osc : in std_logic;
		rgb: out std_logic_vector(5 downto 0);
		hsync: out std_logic;
		vsync: out std_logic;
		ctrlr_latch : out std_logic;
		ctrlr_clk : out std_logic;
		rotate_out : out std_logic;
		ctrlr_data : in std_logic
	);
end master;

architecture synth of master is

	component game_logic is
		port(
			clk : in std_logic;
			game_clock : in std_logic;
			valid_input : in std_logic;
			valid_rgb: in std_logic;
			press_rotate : in std_logic;
			press_down : in std_logic;
			press_left : in std_logic;
			press_right : in std_logic;
			press_sel : in std_logic

			piece_loc : out piece_loc_type := (4d"2", 4d"0"); -- (x, y) from top left of grid to top left of piece 4x4
			piece_shape : out std_logic_vector(15 downto 0);
			board : out board_type;
			special_background : out unsigned(4 downto 0)
		);
	end component;

	component renderer is
		port(
			clk : in std_logic;
			valid_rgb : in std_logic;
			row : in unsigned(9 downto 0);
			col : in unsigned(9 downto 0);
			rgb : out std_logic_vector(5 downto 0);

			piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
			piece_shape : in std_logic_vector(15 downto 0);
			board : in board_type;
			special_background : in unsigned(4 downto 0)
		);
	end component;

	component vga_sync is
		port(
			clk: in std_logic;
			valid_rgb: out std_logic;
			row: out unsigned(9 downto 0);
			col: out unsigned(9 downto 0);
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

	component clock_manager is
		port(
			osc : in std_logic;
			clk : out std_logic;
			game_clock : out std_logic;
			counter : out unsigned(31 downto 0);
			NEScount : out unsigned(7 downto 0);
			NESclk : out std_logic;
			valid_input : out std_logic
		);
	end component;

	signal valid_rgb: std_logic;
	signal row: unsigned(9 downto 0);
	signal col: unsigned(9 downto 0);

	signal press_rotate : std_logic;
	signal down_button : std_logic;
	signal left_button : std_logic;
	signal right_button : std_logic;
	signal sel : std_logic;
	signal start : std_logic;
	signal a : std_logic;
	signal b : std_logic;

	signal clk : std_logic;
	signal game_clock : std_logic;
	signal counter : unsigned(31 downto 0);
	signal NEScount : unsigned(7 downto 0);
	signal NESclk : std_logic;
	signal valid_input : std_logic;

	signal piece_loc : piece_loc_type;
	signal piece_shape : std_logic_vector(15 downto 0);
	signal board : board_type;
	signal special_background : unsigned(4 downto 0);

begin

	clock_manager_portmap : clock_manager port map(osc, clk, game_clock, counter, NEScount, NESclk, valid_input);

	game_logic_portmap : game_logic port map(
		clk => clk,
		game_clock => game_clock,
		valid_input => valid_input,
		valid_rgb => valid_rgb,
		press_rotate => press_rotate,
		press_down => down_button,
		press_left => left_button,
		press_right => right_button,
		press_sel => sel,
		piece_loc => piece_loc,
		piece_shape => piece_shape,
		board => board,
		special_background => special_background
	);

	renderer_portmap : renderer port map(
		clk => clock,
		valid_rgb => valid_rgb,
		row => row,
		col => col,
		rgb => rgb,
		piece_loc => piece_loc,
		piece_shape => piece_shape,
		board => board,
		special_background => special_background
	);

	vga_sync_portmap : vga_sync port map(clk, valid_rgb, row, col, hsync, vsync);

	nes_controller_portmap : nes_controller port map(
		ctrlr_latch,
		ctrlr_clk,
		ctrlr_data,
		press_rotate,
		down_button,
		left_button,
		right_button,
		sel,
		start,
		a,
		b,
		NEScount,
		NESclk
	);

	rotate_out <= press_rotate;

end;
