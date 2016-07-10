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
  constant N      : integer                          := 3;
  constant T      : time                             := 20 ns;
  signal result   : std_logic_vector(N - 1 downto 0) := (others => '0');
  signal clk_test : std_logic;
  signal rst      : std_logic;
  signal id1      : std_logic_vector(N-1 downto 0)   := (others => '0');
  signal id2      : std_logic_vector(N-1 downto 0)   := (others => '0');
  signal root     : std_logic_vector(N-1 downto 0)   := (others => '0');
  signal ready    : std_logic;
  signal ctrl     : std_logic_vector(1 downto 0)     := (others => '0');
  signal test     : integer                          := 0;

  shared variable ENDSIM : boolean := false;
begin

  ---- Design Under Verification -----------------------------------------
  DUV : entity work.UnionFind
    generic map (
      N => N)
    port map (
      id1   => id1,
      id2   => id2,
      ctrl  => ctrl,
      root  => root,
      ready => ready,
      clk   => clk_test);

  ---- Clock running forever ---------------------------------------------
  process
  begin
    if ENDSIM = false then
      clk_test <= '0';
      wait for T/2;
      clk_test <= '1';
      wait for T/2;
    else
      wait;
    end if;
  end process;

  ---- Reset asserted for T/2 --------------------------------------------
  rst <= '1', '0' after T/2;

  ----- Test vector generation -------------------------------------------
  TESTS : process is
  begin
    ------------------------------------------------------------------
    -- reset and assign default values
    ------------------------------------------------------------------
    rst <= '1';
    wait until rising_edge(clk_test);
    rst <= '0';

    ------------------------------------------------------------------
    -- read the file with inputs and compare with the outputs
    ------------------------------------------------------------------

    test   <= 1;
    print("test: " & integer'image(test+1));

    wait until ready = '1';
    id1    <= "111"; id2 <= "010"; ctrl <= "10";
    wait until ready = '1';
    ctrl <= "00";
    
    for i in 0 to 20 loop
      wait until rising_edge(clk_test);
    end loop;
    

    ENDSIM := true;
    print ("----- SIMULATION COMPLETED -----");
    wait;
  end process;
end Testbench;
