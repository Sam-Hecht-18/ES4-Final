library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock is
  port(
	clk : in std_logic;
	game_clock : out std_logic;
	NEScount : out unsigned(7 downto 0);
	NESclk : out std_logic
  );
end clock;

architecture synth of clock is

-- signal clk : std_logic;
    signal counter : unsigned(31 downto 0) := 32b"0";  

    -- component HSOSC is
    --     generic (
    --     CLKHF_DIV : String := "0b00");
    --     port(
    --     CLKHFPU : in std_logic := '1'; -- Set to 1 to power up
    --     CLKHFEN : in std_logic := '1'; -- Set to 1 to enable output
    --     CLKHF : out std_logic := '0'); -- Clock output
    -- end component;
   
begin 
    game_clock <= counter(24);
	NEScount <= counter(16 downto 9);
	NESclk <= counter(8);
   
    process (clk) begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
           
    end process;
end;