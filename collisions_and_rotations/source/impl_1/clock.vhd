library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_manager is
  port(
    osc : in std_logic;

	rgb_row : in unsigned(9 downto 0);
	rgb_col : in unsigned(9 downto 0);
	valid_rgb : in std_logic;

	clk : out std_logic;
	clk_counter : out unsigned(31 downto 0);
	game_clock : out std_logic;
	NEScount : out unsigned(7 downto 0);
	NESclk : out std_logic;
	valid_input : out std_logic

	valid_output : out std_logic;
	valid_output_ctr : out unsigned(15 downto 0) := 16b"0"
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
begin
	pll_portmap : mypll port map(
		ref_clk_i => osc,
		rst_n_i => '1',
		outcore_o => outcore_o,
		outglobal_o => clk
	);

    game_clock <= not clk_counter(24);
	NEScount <= clk_counter(15 downto 8);
	NESclk <= clk_counter(7);

	--accept input for certain amount of clock cycles and reserve rest for auto piece movement
	valid_input <= '1' when clk_counter(24 downto 0) < 25d"33500000" else '0';

    process (clk) begin
        if rising_edge(clk) then
            clk_counter <= clk_counter + 1;
        end if;
    end process;

	valid_input <= '1' when rgb_row > 481 and rgb_row < 520 else '0';
	valid_output <= '1' when rgb_row > 520 and rgb_row < 525 else '0';

    process (rgb_row) begin
        if rising_edge(valid_output) then
			valid_output_ctr <= valid_output_ctr + 1;
		end if;
    end process;

end;