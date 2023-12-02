library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_clock_manager is
  port(
    clk : in std_logic;
    game_clock : out std_logic
  );
end game_clock_manager;

architecture synth of game_clock_manager is
    signal clk : std_logic;
    signal counter : unsigned(25 downto 0) := 26b"0";
begin

    process (clk) begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    game_clock <= counter(25);

end;