library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_manager is
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
end clock_manager;

architecture synth of clock_manager is

	component mypll is
		port(
			ref_clk_i: in std_logic;
			rst_n_i: in std_logic;
			outcore_o: out std_logic;
			outglobal_o: out std_logic
		);
	end component;
	
	
	signal outcore_o: std_logic;
	signal clk_counter : unsigned(18 downto 0);
	
	
begin
	pll_portmap : mypll port map(
		ref_clk_i => osc,
		rst_n_i => '1',
		outcore_o => outcore_o,
		outglobal_o => clk
	);
	
	NEScount <= clk_counter(15 downto 8);
	NESclk <= clk_counter(7);
	
	process (clk) begin
		if rising_edge(clk) then
			-- On the 1st pixel outside the screen, tick the game_clock
			if (clk_counter = 19d"384001") then
				game_clock <= '1';
				game_clock_ctr <= game_clock_ctr + 1;
			else
				game_clock <= '0';
			end if;
			
			-- For every pixel in 525 x 800 display, add one to clk_counter so we know when to reset
			if (clk_counter = 19d"419999") then
				clk_counter <= 19d"0";
			else
				clk_counter <= clk_counter + 1;
			end if;
		end if;
	end process;

end;
	
	
	