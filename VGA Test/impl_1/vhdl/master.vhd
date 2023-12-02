library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity master is
	port(
		osc : in std_logic;
		rgb: out std_logic_vector(5 downto 0);
		hsync: out std_logic;
		vsync: out std_logic;
		clk_test : out std_logic;
		ctrlr_latch : out std_logic;
		ctrlr_clk : out std_logic;
		ctrlr_data : in std_logic
	);
end master;

architecture synth of master is

	component pattern_gen is
		port(
			clk: in std_logic;
			game_clock : in std_logic;
			rotate : in std_logic;
			valid: in std_logic;
			row: in unsigned(9 downto 0);
			col: in unsigned(9 downto 0);
			rgb: out std_logic_vector(5 downto 0)
		);
	end component;

	component vga is
		port(
			clk: in std_logic;
			valid: out std_logic;
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
			NESclk : out std_logic
		  );
	end component;

	signal valid: std_logic;
	signal row: unsigned(9 downto 0);
	signal col: unsigned(9 downto 0);

	signal rotate : std_logic;

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

begin

	clock_manager_portmap : clock_manager port map(osc, clk, game_clock, counter, NEScount, NESclk);

	pattern_gen_portmap : pattern_gen port map(clk, game_clock, rotate, valid, row, col, rgb);

	vga_portmap : vga port map(clk, valid, row, col, hsync, vsync);

	nes_controller_portmap : nes_controller port map(
		ctrlr_latch,
		ctrlr_clk,
		ctrlr_data,
		rotate,
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

end;
