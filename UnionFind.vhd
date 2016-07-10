------------------------------------------------------------
-- Title      : Testbench for the union find algorithm
------------------------------------------------------------
-- File       : UnionFind_TB
-- Author     : Peter Samarin <peter.samarin@smail.inf.h-brs.de>
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------
entity UnionFind is
  generic (
    N : integer := 3);
  port (
    id1   : in  std_logic_vector(N-1 downto 0);
    id2   : in  std_logic_vector(N-1 downto 0);
    ctrl  : in  std_logic_vector(1 downto 0);
    -- outputs
    root  : out std_logic_vector(N-1 downto 0);
    ready : out std_logic;
    -- other
    clk   : in  std_logic);
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
  signal state_reg, state_next     : state_type                := idle;
  signal reset                     : std_logic;
  signal nodes_reg, nodes_next     : node_vector (0 to 2**N-1) := (others => (1, 1));
  signal id1_int, id2_int          : integer range 0 to 2**N-1;
  signal root_int                  : integer range 0 to 2**N-1;
  signal counter_reg, counter_next : integer range 0 to 2**N-1 := 0;
begin

  process (clk, reset) is
  begin
    if reset = '1' then
      state_reg <= idle;
      nodes_reg <= (others => (1, 1));
    elsif rising_edge(clk) then
      state_reg <= state_next;
      nodes_reg <= nodes_next;
    end if;
  end process;


  id1_int <= to_integer(unsigned(id1));
  id2_int <= to_integer(unsigned(id2));
  root    <= std_logic_vector(to_unsigned(root_int, N));

  process (ctrl, id1_int, nodes_reg, state_reg) is
  begin
    state_next <= state_reg;
    nodes_next <= nodes_reg;

    

    case state_reg is
      when idle
        case ctrl is
        when clear =>
          nodes_next(id1_int).parent <= 1;
          nodes_next(id1_int).weight <= 1;

        ----------------------------------------------------
        -- find the parent
        ----------------------------------------------------
        when "10" =>
          root_int <= nodes_reg(id1_int).parent;



        ----------------------------------------------------
        -- do nothing
        ----------------------------------------------------  
        when others =>
          
          null;
      end case;
        
        => ;
      when others => null;
    end case;
    
  end process;



end arch;

