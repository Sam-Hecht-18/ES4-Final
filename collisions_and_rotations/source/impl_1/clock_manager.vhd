library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_manager is
  port(
    osc : in std_logic;

	clk : out std_logic; -- VGA clock

	game_clock : out std_logic := '0'; -- Game clock
	game_clock_ctr : out unsigned(15 downto 0) := 16d"0"; -- Game clock counter

	NEScount : out unsigned(7 downto 0);
	NESclk : out std_logic

  );
end clock_manager;

architecture synth of clock_manager is

    component mypll is
		port(
			ref_clk_i: in std_logic; -- Input clock
			rst_n_i: in std_logic; -- Reset (active low)
			outcore_o: out std_logic; -- Output to pins
			outglobal_o: out std_logic -- Output for clock network
		);
	end component;

    signal outcore_o : std_logic;
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
			-- At pixel row 481 column 0, game_clock goes high
			if (clk_counter = 19d"384001") then
				game_clock <= '1';
				game_clock_ctr <= game_clock_ctr + 1;
			else
				game_clock <= '0';
			end if;
			
			-- When we've seen a full frame, reset the clk_counter to 0
			if (clk_counter = 19d"420000") then
				clk_counter <= 19d"0";
			else
				clk_counter <= clk_counter + 1;
			end if;
		end if;
	end process;

end;