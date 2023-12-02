library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_manager is
  port(
    osc : in std_logic;
	clk : out std_logic;
	game_clock : out std_logic;
	counter : out unsigned(31 downto 0);
	NEScount : out unsigned(7 downto 0);
	NESclk : out std_logic
  );
end clock_manager;

architecture synth of clock_manager is

    component pll_component is
		port(
			ref_clk_i: in std_logic; -- Input clock
			rst_n_i: in std_logic; -- Reset (active low)
			outcore_o: out std_logic; -- Output to pins
			outglobal_o: out std_logic -- Output for clock network
		);
	end component;

    signal outcore_o : std_logic;
	-- signal outglobal_o : std_logic;

begin

    pll_portmap : pll_component port map (
		ref_clk_i => osc,
		rst_n_i => '1',
		outcore_o => outcore_o,
		outglobal_o => clk
	);

    game_clock <= counter(24);
	NEScount <= counter(15 downto 8);
	NESclk <= counter(7);
    -- clk_test <= outcore_o;

    process (clk) begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;

    end process;
end;