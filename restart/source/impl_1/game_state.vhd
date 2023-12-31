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
	piece_code : in unsigned(2 downto 0);
	
	game_over : in std_logic;
	curr_state: out State
	
  );
end game_state;

architecture synth of game_state is

	component welcome_screen is
		port(
			clk : in std_logic;
			x_coordinate: in unsigned(7 downto 0);
		    y_coordinate: in unsigned(6 downto 0);
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
		piece_code: unsigned(2 downto 0)
	);
	end component;
	
	component game_over_screen is
		port(
			clk : in std_logic;
			-- final_score : in unsigned(16 downto 0); -- allows maximum score of 2^17 - 1 = 131,071
			x_coordinate: in unsigned(7 downto 0);
			y_coordinate: in unsigned(6 downto 0);
			rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	
	signal rgb_welcome : std_logic_vector(5 downto 0);
	signal rgb_gameplay : std_logic_vector(5 downto 0);
	signal rgb_gameover : std_logic_vector(5 downto 0);
	signal first_time : std_logic;
	signal welcome_delay: unsigned(25 downto 0);

begin

	welcome_portmap : welcome_screen port map(
		clk  => clk,
		x_coordinate => rgb_col(9 downto 2),
		y_coordinate => rgb_row(8 downto 2),
		rgb => rgb_welcome
	);
		
	renderer_portmap : renderer port map(
		rgb_row => rgb_row,
		rgb_col => rgb_col,
		rgb => rgb_gameplay,
		piece_loc => piece_loc,
		piece_shape => piece_shape,
		board => board,
		piece_code => piece_code
	);
		
	game_over_portmap : game_over_screen port map(
		clk => clk,
		x_coordinate => rgb_col(9 downto 2),
		y_coordinate => rgb_row(8 downto 2),
		rgb => rgb_gameover
	);
		
-- port mappings
	process(clk) begin
		if rising_edge(clk) then
			if first_time = '0' then
				curr_state <= WELCOME_STATE;
				first_time <= '1';
			elsif curr_state = WELCOME_STATE and start = '1' and welcome_delay = 26d"0" then
				curr_state <= GAMEPLAY_STATE;
			elsif curr_state = GAMEPLAY_STATE and game_over = '1' then
				curr_state <= GAMEOVER_STATE;
			elsif curr_state = GAMEOVER_STATE and start = '1' then
				welcome_delay <= welcome_delay + 1;
				curr_state <= WELCOME_STATE;
			else
				curr_state <= curr_state;
			end if;
			if (welcome_delay > 26d"0") then
				welcome_delay <= welcome_delay + 1;
			end if;
			-- possible reset if we want
			
		end if;
	end process;
	
	
	rgb <= rgb_welcome when curr_state = WELCOME_STATE and valid_rgb = '1' else
		   rgb_gameplay when curr_state = GAMEPLAY_STATE and valid_rgb = '1' else
		   rgb_gameover when curr_state = GAMEOVER_STATE and valid_rgb = '1' else "000000";
		   
end;



	