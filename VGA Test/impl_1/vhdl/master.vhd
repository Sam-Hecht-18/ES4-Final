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
		test_input : in std_logic;
		test_output : out std_logic;
		rotate_out : out std_logic;
		ctrlr_data : in std_logic
	);
end master;

architecture synth of master is

	component pll_component is
		port(
			ref_clk_i: in std_logic; -- Input clock
			rst_n_i: in std_logic; -- Reset (active low)
			outcore_o: out std_logic; -- Output to pins
			outglobal_o: out std_logic -- Output for clock network
		);
	end component;
	
	component pattern_gen is
		port(
			clk : in std_logic;
			game_clock : in std_logic;
			valid: in std_logic;
			row: in unsigned(9 downto 0);
			col: out unsigned(9 downto 0);
			rgb: out std_logic_vector(5 downto 0);
			rotate : in std_logic;
			down : in std_logic
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
	
	component clock is
	port(
		clk : in std_logic;
		game_clock : out std_logic;
		counter : out unsigned(31 downto 0);
		NEScount : out unsigned(7 downto 0);
		NESclk : out std_logic
	  );
	end component;

	signal outcore_o : std_logic;
	signal outglobal_o : std_logic;
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

	clock_device : clock port map(outglobal_o, game_clock, counter, NEScount, NESclk); 

	my_pll : pll_component 
	port map (
		ref_clk_i => osc, 
		rst_n_i => '1', 
		outcore_o => outcore_o, 
		outglobal_o => outglobal_o
	);
	
	my_pattern_gen : pattern_gen port map(
		clk => outglobal_o,
		game_clock => game_clock,
		valid => valid,
		row => row,
		col => col,
		rgb => rgb,
		rotate => rotate,
		down => down_button);
	
	my_vga : vga port map(outglobal_o, valid, row, col, hsync, vsync);

	my_nes_controller : nes_controller port map
	(ctrlr_latch, 
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
	NESclk);
	
	rotate_out <= rotate;
	clk_test <= outcore_o;
	test_output <= test_input;
	
end;
