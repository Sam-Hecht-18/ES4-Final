library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
  port(
	latch : out std_logic;
	ctrlr_clk : out std_logic;
	data : in std_logic;
	up : out std_logic;
	down : out std_logic;
	left : out std_logic;
	right : out std_logic;
	sel : out std_logic;
	start : out std_logic;
	b : out std_logic;
	a : out std_logic
  );
end top;

architecture synth of top is
	
	component nes_controller is
		port(
			latch : out std_logic;
			ctrlr_clk : out std_logic;
			data : in std_logic;
			up : out std_logic;
			down : out std_logic;
			left : out std_logic;
			right : out std_logic;
			sel : out std_logic;
			start : out std_logic;
			b : out std_logic;
			a : out std_logic
		);
	end component;

    begin
	
		nes_controller_device : nes_controller port map
			(latch, ctrlr_clk, data, up, down, left, right, sel, start, b, a);

    end;
    
    
    
    
