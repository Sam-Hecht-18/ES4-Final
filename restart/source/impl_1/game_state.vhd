library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.my_types_package.all;

entity game_state is
  port(
	clk : in std_logic;
	
	-- for welcome and gameover states
	start : in std_logic;
	
	-- for render state
	valid_rgb : in std_logic;
	rgb_row : in unsigned(9 downto 0);
	rgb_col : in unsigned(9 downto 0);
	rgb : out std_logic_vector(5 downto 0);

	piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
	piece_shape : in std_logic_vector(15 downto 0);
	board : in board_type;
	special_background : in unsigned(4 downto 0);
	
	game_over : in std_logic
	
  );
end game_state;

architecture synth of game_state is

	component welcome_screen is
		port(
			clk : in std_logic;
			rgb_row: in unsigned(9 downto 0);
			rgb_col: in unsigned(9 downto 0);
			rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	
	component renderer is
	port(
		rgb_row : in unsigned(9 downto 0);
		rgb_col : in unsigned(9 downto 0);
		rgb : out std_logic_vector(5 downto 0);

		piece_loc : in piece_loc_type; -- (x, y) from top left of grid to top left of piece 4x4
		piece_shape : in std_logic_vector(15 downto 0);
		board : in board_type;
		special_background : in unsigned(4 downto 0)
	);
	end component;
	
	component game_over_screen is
		port(
			clk : in std_logic;
			--final_score : in unsigned(16 downto 0); -- allows maximum score of 2^17 - 1 = 131,071
			rgb_row: in unsigned(9 downto 0);
			rgb_col: in unsigned(9 downto 0);
			rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	signal s : State;
	
	signal rgb_welcome : std_logic_vector(5 downto 0);
	signal rgb_gameplay : std_logic_vector(5 downto 0);
	signal rgb_gameover : std_logic_vector(5 downto 0);
	signal first_time : std_logic;
	signal welcome_delay: unsigned(25 downto 0);

begin

	welcome_portmap : welcome_screen port map(
		clk  => clk,
		rgb_row => rgb_row,
		rgb_col => rgb_col,
		rgb => rgb_welcome
	);
		
	renderer_portmap : renderer port map(
		rgb_row => rgb_row,
		rgb_col => rgb_col,
		rgb => rgb_gameplay,
		piece_loc => piece_loc,
		piece_shape => piece_shape,
		board => board,
		special_background => special_background
	);
		
	game_over_portmap : game_over_screen port map(
		clk => clk,
		rgb_row => rgb_row,
		rgb_col => rgb_col,
		rgb => rgb_gameover
	);
		
-- port mappings
	process(clk) begin
		if rising_edge(clk) then
			if first_time = '0' then
				s <= WELCOME_STATE;
				first_time <= '1';
			elsif s = WELCOME_STATE and start = '1' and welcome_delay = 26d"0" then
				s <= GAMEPLAY_STATE;
			elsif s = GAMEPLAY_STATE and game_over = '1' then
				s <= GAMEOVER_STATE;
			elsif s = GAMEOVER_STATE and start = '1' then
				welcome_delay <= welcome_delay + 1;
				s <= WELCOME_STATE;
			else
				s <= s;
			end if;
			if (welcome_delay > 26d"0") then
				welcome_delay <= welcome_delay + 1;
			end if;
			-- possible reset if we want
			
		end if;
	end process;
	
	
	rgb <= rgb_welcome when s = WELCOME_STATE and valid_rgb = '1' else
		   rgb_gameplay when s = GAMEPLAY_STATE and valid_rgb = '1' else
		   rgb_gameover when s = GAMEOVER_STATE and valid_rgb = '1' else "000000";
		   

end;



	