library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nes_controller is
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
        a : out std_logic;
        NEScount : in unsigned(7 downto 0);
        NESclk : in std_logic
    );
end nes_controller;

architecture synth of nes_controller is
    -- component counter is
    --         port(
    --                 NEScount : out unsigned(7 downto 0);
    --                 NESclk : out std_logic
    --         );
    -- end component;
    --
    -- signal NEScount : unsigned(7 downto 0);
    -- signal NESclk : std_logic;
    signal shift_reg : unsigned(7 downto 0);
    signal ctrlr_outputs : unsigned(7 downto 0);
begin
    -- counter_device : counter port map (NEScount, NESclk);
    latch <= '1' when (NEScount = 255) else '0';
    ctrlr_clk <= NESclk when (NEScount < 8) else '0';
    ctrlr_outputs <= shift_reg when (NEScount = 8);
    a <= ctrlr_outputs(7);
    b <= ctrlr_outputs(6);
    sel <= ctrlr_outputs(5);
    start <= ctrlr_outputs(4);
    up <= ctrlr_outputs(3);
    down <= ctrlr_outputs(2);
    left <= ctrlr_outputs(1);
    right <= ctrlr_outputs(0);

    process (ctrlr_clk)
    begin
        if rising_edge(ctrlr_clk) then
            shift_reg <= shift_left(shift_reg, 1);
            shift_reg(0) <= not data;
        end if;
    end process;
end;