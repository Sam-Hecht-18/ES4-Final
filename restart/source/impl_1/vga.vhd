library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_sync is
  	port(
		clk: in std_logic;
		valid_rgb: out std_logic;
		rgb_row: out unsigned(9 downto 0);
		rgb_col: out unsigned(9 downto 0);
		hsync: out std_logic;
		vsync: out std_logic
	);
end vga_sync;

architecture synth of vga_sync is
begin
    process(clk) begin
        if rising_edge(clk) then

			if rgb_col = 799 then
				rgb_col <= 10b"0";

				if rgb_row = 524 then
					rgb_row <= 10b"0";
				else
					rgb_row <= rgb_row + 1;
				end if;

			else
				rgb_col <= rgb_col + 1;
			end if;

        end if;
    end process;

	hsync <= '1' when rgb_col < 656 or rgb_col >= 752 else '0'; -- 656 = visible + front porch, 752 = visible + front porch + sync
	vsync <= '1' when rgb_row < 490 or rgb_row >= 492 else '0'; -- 490 = visible + front porch, 492 = visible + front porch + sync

	valid_rgb <= '1' when rgb_col < 640 and rgb_row < 480 else '0';

end;
