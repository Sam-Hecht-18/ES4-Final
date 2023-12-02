library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock is
  port(
	clk : in std_logic;
	game_clock : out std_logic;
	counter : out unsigned(31 downto 0);
	NEScount : out unsigned(7 downto 0);
	NESclk : out std_logic
  );
end clock;

architecture synth of clock is
   
begin
    game_clock <= counter(24);
	NEScount <= counter(15 downto 8);
	NESclk <= counter(7);
   
    process (clk) begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
           
    end process;
end;