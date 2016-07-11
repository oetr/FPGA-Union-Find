------------------------------------------------------------
-- Title      : Testbench for the union find algorithm
------------------------------------------------------------
-- Description: ctrl: 000 - nothing
--                    001 - union
--                    010 - find
--                    011 - init (or reset)
--                    100 - are 2 nodes connected?
------------------------------------------------------------
-- File       : UnionFind_TB
-- Author     : Peter Samarin <peter.samarin@gmail.com>
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.UFlib.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------
entity UnionFind is
  generic (
    N     : integer := 3;
    DEBUG : boolean := false);
  port (
    -- debug
    all_nodes    : out node_vector (0 to 2**N-1)      := (others => (N-1, 1));
    -- user interface
    id1          : in  std_logic_vector(N-1 downto 0) := (others => '0');
    id2          : in  std_logic_vector(N-1 downto 0) := (others => '0');
    ctrl         : in  std_logic_vector(2 downto 0)   := (others => '0');
    ctrl_valid   : in  std_logic                      := '0';
    -- outputs
    root         : out std_logic_vector(N-1 downto 0) := (others => '0');
    is_connected : out std_logic                      := '0';
    ready        : out std_logic                      := '0';
    -- other
    clk          : in  std_logic                      := '0');

end UnionFind;
------------------------------------------------------------
architecture arch of UnionFind is
  type state_type is (init, idle, find, union, union1, connected1, connected);
  -- signals
  signal state                    : state_type                := init;
  signal return_to_state          : state_type                := init;
  signal nodes                    : node_vector (0 to 2**N-1) := (others => (N-1, 1));
  signal id1_int, id2_int         : integer range 0 to 2**N-1 := 0;
  signal id1_int_reg, id2_int_reg : integer range 0 to 2**N-1 := 0;
  signal find_start_id            : integer range 0 to 2**N-1 := 0;
  signal xRoot, yRoot             : integer range 0 to 2**N-1 := 0;
  signal current_id               : integer range 0 to 2**N-1 := 0;
  signal root_int                 : integer range 0 to 2**N-1 := 0;
  signal counter                  : integer range 0 to 2**N-1 := 0;
  -- output signals
  signal ready_reg                : std_logic                 := '0';
  signal is_connected_reg         : std_logic                 := '0';
begin

  process (clk) is
    variable s : line;
  begin
    if rising_edge(clk) then
      ready_reg        <= '0';
      is_connected_reg <= '0';
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
          if ctrl_valid = '1' then
            case ctrl is
              when "000" =>
                state <= idle;

              when "001" =>             -- union
                id2_int_reg     <= id2_int;
                state           <= find;
                current_id      <= nodes(id1_int).parent;
                return_to_state <= union1;
                -- path compression
                find_start_id   <= id1_int;

              when "010" =>             -- find
                find_start_id   <= id1_int;
                state           <= find;
                current_id      <= nodes(id1_int).parent;
                -- path compression
                return_to_state <= idle;

              when "011" =>             -- init
                state   <= init;
                counter <= 0;

              when "100" =>             -- connected
                id2_int_reg     <= id2_int;
                state           <= find;
                current_id      <= nodes(id1_int).parent;
                return_to_state <= connected1;
                -- path compression
                find_start_id   <= id1_int;

              when others => null;
            end case;
          end if;

        when union1 =>
          id1_int_reg     <= root_int;
          current_id      <= nodes(id2_int_reg).parent;
          return_to_state <= union;
          state           <= find;
          -- path compression
          find_start_id   <= id2_int_reg;

        when union =>
          if nodes(xRoot).parent /= yRoot then
            if nodes(xRoot).weight < nodes(yRoot).weight then
              nodes(xRoot).parent <= yRoot;
              nodes(yRoot).weight <= nodes(yRoot).weight + nodes(xRoot).weight;
            else
              nodes(yRoot).parent <= xRoot;
              nodes(xRoot).weight <= nodes(xRoot).weight + nodes(yRoot).weight;
            end if;
          end if;
          ready_reg <= '1';
          state     <= idle;

        when connected1 =>
          id1_int_reg     <= root_int;
          current_id      <= nodes(id2_int_reg).parent;
          return_to_state <= connected;
          state           <= find;
          -- path compression
          find_start_id   <= id2_int_reg;

        when connected =>
          ready_reg <= '1';
          state     <= idle;
          if nodes(xRoot).parent = yRoot then
            is_connected_reg <= '1';
          end if;

        when find =>
          current_id <= nodes(current_id).parent;
          if nodes(current_id).parent = current_id then
            if return_to_state = idle then
              ready_reg <= '1';
            end if;
            root_int                    <= current_id;
            state                       <= return_to_state;
            -- path compression
            nodes(find_start_id).parent <= current_id;
          end if;

        when others => null;
      end case;
    end if;
  end process;

  id1_int <= to_integer(unsigned(id1));
  id2_int <= to_integer(unsigned(id2));
  root    <= std_logic_vector(to_unsigned(root_int, N));
  xRoot   <= id1_int_reg;
  yRoot   <= root_int;

  ----------------------------------------------------------
  -- Outputs
  ----------------------------------------------------------
  ready        <= ready_reg;
  is_connected <= is_connected_reg;

  -- debug
  all_nodes <= nodes;
end arch;
