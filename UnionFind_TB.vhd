-----------------------------------------------------------------------------
-- Title      : Testbench for the union find algorithm
-----------------------------------------------------------------------------
-- File       : UnionFind_TB
-- Author     : Peter Samarin <peter.samarin@smail.inf.h-brs.de>
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------------------
entity UnionFind_TB is
end UnionFind_TB;
------------------------------------------------------------------------
architecture Testbench of UnionFind_TB is
  constant N    : integer := 3;
  constant T    : time    := 20 ns;     -- clk period
  signal result : std_logic_vector(N - 1 downto 0);
  signal clk    : std_logic;
  signal rst    : std_logic;
  signal id1  : std_logic_vector(N-1 downto 0);
  signal id2  : std_logic_vector(N-1 downto 0);
  signal root   : std_logic_vector(N-1 downto 0);
  signal ready  : std_logic;
  signal ctrl   : std_logic_vector(1 downto 0);
  signal test   : integer := 0;
begin

  ---- Design Under Verification -----------------------------------------
  DUV : entity work.UnionFind
    generic map (
      N => N)
    port map (
      id1 => id1,
      id2 => id2,
      ctrl  => ctrl,
      root  => root,
      ready => ready,
      clk   => clk);

  ---- Clock running forever ---------------------------------------------
  process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;

  ---- Reset asserted for T/2 --------------------------------------------
  rst <= '1', '0' after T/2;

  ----- Test vector generation -------------------------------------------
  TESTS : process is
  begin
    ------------------------------------------------------------------
    -- reset and assign default values
    ------------------------------------------------------------------
    rst  <= '1';
    wait until rising_edge(clk);
    rst  <= '0';

    ------------------------------------------------------------------
    -- read the file with inputs and compare with the outputs
    ------------------------------------------------------------------
    
    test <= 1;
    print("test: " & integer'image(test+1));
    id1 <= "010"; id2 <= "010";  ctrl <= "00";
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    assert false report "Simulation completed" severity failure;
  end process;
end Testbench;
