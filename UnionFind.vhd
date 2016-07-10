------------------------------------------------------------
-- Title      : Testbench for the union find algorithm
------------------------------------------------------------
-- Description: ctrl: 00 - nothing
--                    01 - union
--                    10 - find
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
  type state_type is (init, idle, find, union);
  -- signals
  signal state            : state_type                := init;
  signal nodes            : node_vector (0 to 2**N-1) := (others => (N-1, 1));
  signal id1_int, id2_int : integer range 0 to 2**N-1 := 0;
  signal root_int         : integer range 0 to 2**N-1 := 0;
  signal counter          : integer range 0 to 2**N-1 := 0;

  -- output signals
  signal ready_reg : std_logic := '0';
begin

  process (clk) is
  begin
    if rising_edge(clk) then
      ready_reg <= '0';
      case state is

        when init =>
          if counter = 2**N-1 then
            state     <= idle;
            ready_reg <= '1';
            counter   <= 0;
          else
            counter <= counter + 1;
          end if;
          nodes(counter).parent <= counter;
          nodes(counter).weight <= 1;

        when idle =>
          -- waiting for commands
          case ctrl is
            when "00" => null;
            when "01" =>                -- union
              state <= union;
            when "10" =>                -- find
              state <= find;
            when "11"   => null;
            when others => null;
          end case;

        when union =>
          ready_reg <= '1';
          state     <= idle;

        when find =>
          ready_reg <= '1';
          state     <= idle;


        when others => null;
      end case;

    end if;
  end process;

  -- find root of id1
  process is
  begin
    
  end process;

  -- find root of id2
  process is
  begin

  end process;

  id1_int <= to_integer(unsigned(id1));
  id2_int <= to_integer(unsigned(id2));
  root    <= std_logic_vector(to_unsigned(root_int, N));

  ----------------------------------------------------------
  -- Outputs
  ----------------------------------------------------------
  ready <= ready_reg;

end arch;

