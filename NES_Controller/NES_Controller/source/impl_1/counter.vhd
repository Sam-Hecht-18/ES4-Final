library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
  port(
	  NEScount : out unsigned(7 downto 0);
	  NESclk : out std_logic
  );
end counter;

architecture synth of counter is
    component HSOSC is
    generic (CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2^N (0-3)
    port(
        CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
        CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
        CLKHF : out std_logic := 'X'); -- Clock output
    end component;
    
    signal clk : std_logic;
	signal count : unsigned(19 downto 0);

	
    begin
        osc : HSOSC generic map (CLKHF_DIV => "0b00")
                port map (CLKHFPU => '1',
                          CLKHFEN => '1',
                          CLKHF => clk);
						  
		NEScount <= count(16 downto 9);
		NESclk <= count(8);
        process (clk)
        begin
            -- report to_string(firstTime);
            if rising_edge(clk) then
                count <= count + 1;
                -- report "count: " & to_string(count);
            end if;
        
        end process;
    end;
    
    
    
    
