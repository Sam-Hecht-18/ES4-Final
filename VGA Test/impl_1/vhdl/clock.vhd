library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock is
  port(
 myClock : out std_logic
  );
end clock;

architecture synth of clock is

signal clk : std_logic;
signal counter : unsigned(25 downto 0) := 26b"0";  

    component HSOSC is
        generic (
        CLKHF_DIV : String := "0b00");
        port(
        CLKHFPU : in std_logic := '1'; -- Set to 1 to power up
        CLKHFEN : in std_logic := '1'; -- Set to 1 to enable output
        CLKHF : out std_logic := '0'); -- Clock output
    end component;
   
begin
    osc : HSOSC generic map ( CLKHF_DIV => "0b00")
    port map (CLKHFPU => '1',
    CLKHFEN => '1',
    CLKHF => clk);
     
    myClock <= counter(25);
   
   
    process (clk) begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
           
    end process;
end;