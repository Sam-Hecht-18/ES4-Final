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
		valid_test : out std_logic
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
			clk: in std_logic;
			valid: in std_logic;
			row: in unsigned(9 downto 0);
			col: out unsigned(9 downto 0);
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

	signal outcore_o : std_logic;
	signal outglobal_o : std_logic;
	signal clk : std_logic;
	signal valid: std_logic;
	signal row: unsigned(9 downto 0);
	signal col: unsigned(9 downto 0);

begin

	my_pll : pll_component
	port map (
		ref_clk_i => osc,
		rst_n_i => '1',
		outcore_o => outcore_o,
		outglobal_o => outglobal_o
	);

	my_pattern_gen : pattern_gen port map(outglobal_o, valid, row, col, rgb);

	my_vga : vga port map(outglobal_o, valid, row, col, hsync, vsync);

	clk_test <= outcore_o;
	valid_test <= valid;
end;
