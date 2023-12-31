library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
  	port(
		clk: in std_logic;
		valid: out std_logic;
		row: out unsigned(9 downto 0);
		col: out unsigned(9 downto 0);
		hsync: out std_logic;
		vsync: out std_logic 
	);
end vga;

architecture synth of vga is
	signal next_col : unsigned(9 downto 0) := 10b"0"; -- 10 bits, 2^10 = 1,024, 1,024 > 800 > 512
	signal next_row : unsigned(9 downto 0) := 10b"0"; -- 10 bits, 2^10 = 1,024, 1,024 > 525 > 512
	signal col_temp : unsigned(9 downto 0) := 10b"0";
	signal row_temp : unsigned(9 downto 0) := 10b"0";
begin
    process(clk) begin
        if rising_edge(clk) then

			if col_temp = 800 then
				col_temp <= 10b"0";

				if row_temp = 525 then
					row_temp <= 10b"0";
				else
					row_temp <= next_row;
				end if;

			else
				col_temp <= next_col;
			end if;

        end if;
    end process;

    next_col <= col_temp + 1;
    next_row <= row_temp + 1;

	hsync <= '1' when col_temp < 656 or col_temp >= 752 else '0'; -- 656 = visible + front porch, 752 = visible + front porch + sync
	vsync <= '1' when row_temp < 490 or row_temp >= 492 else '0'; -- 490 = visible + front porch, 492 = visible + front porch + sync

	valid <= '1' when col_temp <= 640 and row_temp <= 480 else '0';
	
	col <= col_temp;
	row <= row_temp; 

end;
