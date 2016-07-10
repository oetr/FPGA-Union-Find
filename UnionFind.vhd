------------------------------------------------------------
-- Title      : Testbench for the union find algorithm
------------------------------------------------------------
-- File       : UnionFind_TB
-- Author     : Peter Samarin <peter.samarin@gmail.com>
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity UnionFind is
  generic (
    N : integer := 3);
  port (
    id1   : in  std_logic_vector(N-1 downto 0) := (others => '0');
    id2   : in  std_logic_vector(N-1 downto 0) := (others => '0');
    ctrl  : in  std_logic_vector(1 downto 0)   := (others => '0');
    -- outputs
    root  : out std_logic_vector(N-1 downto 0) := (others => '0');
    ready : out std_logic                      := '0';
    -- other
    clk   : in  std_logic                      := '0');
end UnionFind;
------------------------------------------------------------
architecture arch of UnionFind is
  type node is record
    parent : integer range 0 to 2**N-1;
    weight : integer range 0 to 2**N-1;
  end record node;
  type node_vector is array (natural range <>) of node;
  type state_type is (idle, find);
  -- signals
  signal state            : state_type                := idle;
  signal nodes            : node_vector (0 to 2**N-1) := (others => (1, 1));
  signal id1_int, id2_int : integer range 0 to 2**N-1 := 0;
  signal root_int         : integer range 0 to 2**N-1 := 0;
  signal counter          : integer range 0 to 2**N-1 := 0;
begin

  process (clk) is
  begin
    if rising_edge(clk) then

    end if;
  end process;

  id1_int <= to_integer(unsigned(id1));
  id2_int <= to_integer(unsigned(id2));
  root    <= std_logic_vector(to_unsigned(root_int, N));

end arch;

