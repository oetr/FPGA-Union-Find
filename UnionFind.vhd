------------------------------------------------------------
-- Title      : Union find algorithm
------------------------------------------------------------
-- Description: ctrl: 000 - nothing
--                    001 - union
--                    010 - find
--                    011 - init (or reset)
--                    100 - are 2 nodes connected?
-- only the features stored in the root noded are important
-- we don't waste resources to keep the features of non-root
-- nodes up to date
------------------------------------------------------------
-- File       : UnionFind
-- Author     : Peter Samarin <peter.samarin@gmail.com>
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.UFlib.all;
------------------------------------------------------------
entity UnionFind is
  generic (
    N : integer := 3);
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
  type state_type is (init, idle, find, union, connected);
  -- signals
  signal state            : state_type                := init;
  signal nodes            : node_vector (0 to 2**N-1) := (others => (N-1, 1));
  signal id1_int, id2_int : integer range 0 to 2**N-1 := 0;
  signal find_start_id1   : integer range 0 to 2**N-1 := 0;
  signal find_start_id2   : integer range 0 to 2**N-1 := 0;
  signal xRoot, yRoot     : integer range 0 to 2**N-1 := 0;
  signal xRoot_int        : integer range 0 to 2**N-1 := 0;
  signal yRoot_int        : integer range 0 to 2**N-1 := 0;
  signal counter          : integer range 0 to 2**N-1 := 0;
  -- output registers
  signal ready_reg        : std_logic                 := '0';
  signal is_connected_reg : std_logic                 := '0';
begin

  process (clk) is
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
                state          <= union;
                xRoot          <= nodes(id1_int).parent;
                yRoot          <= nodes(id2_int).parent;
                -- path compression
                find_start_id1 <= id1_int;
                find_start_id2 <= id2_int;

              when "010" =>             -- find
                find_start_id1 <= id1_int;
                state          <= find;
                xRoot          <= nodes(id1_int).parent;
                if id1_int = nodes(id1_int).parent then
                  state     <= idle;
                  ready_reg <= '1';
                end if;
                -- save query node for later path compression
                find_start_id1 <= id1_int;

              when "011" =>             -- init
                state   <= init;
                counter <= 0;

              when "100" =>             -- connected
                state          <= connected;
                xRoot          <= nodes(id1_int).parent;
                yRoot          <= nodes(id2_int).parent;
                -- save query node for later path compression
                find_start_id1 <= id1_int;
                find_start_id2 <= id2_int;

              when others => null;
            end case;
          end if;

        when union =>
          if xRoot = nodes(xRoot).parent and yRoot = nodes(yRoot).parent then
            state     <= idle;
            ready_reg <= '1';

            -- path compression
            nodes(find_start_id1).parent <= xRoot;
            nodes(find_start_id2).parent <= yRoot;

            -- union node, and update weight
            if nodes(xRoot).parent /= yRoot then
              if nodes(xRoot).weight < nodes(yRoot).weight then
                nodes(xRoot).parent <= yRoot;
                nodes(yRoot).weight <= nodes(yRoot).weight + nodes(xRoot).weight;
              else
                nodes(yRoot).parent <= xRoot;
                nodes(xRoot).weight <= nodes(xRoot).weight + nodes(yRoot).weight;
              end if;
            end if;
          end if;

          xRoot <= nodes(xRoot).parent;
          yRoot <= nodes(yRoot).parent;


        when connected =>
          if xRoot = nodes(xRoot).parent and yRoot = nodes(yRoot).parent then
            state     <= idle;
            ready_reg <= '1';
            if xRoot = yRoot then
              is_connected_reg <= '1';
            end if;
            -- path compression
            nodes(find_start_id1).parent <= xRoot;
            nodes(find_start_id2).parent <= yRoot;
          end if;

          xRoot <= nodes(xRoot).parent;
          yRoot <= nodes(yRoot).parent;


        when find =>
          xRoot <= nodes(xRoot).parent;
          if xRoot = nodes(xRoot).parent then
            state                        <= idle;
            ready_reg                    <= '1';
            nodes(find_start_id1).parent <= xRoot;
          end if;

        when others => null;

      end case;
    end if;
  end process;

  -- convenience signals
  id1_int <= to_integer(unsigned(id1));
  id2_int <= to_integer(unsigned(id2));
  root    <= std_logic_vector(to_unsigned(xRoot, N));

  ----------------------------------------------------------
  -- Outputs
  ----------------------------------------------------------
  ready        <= ready_reg;
  is_connected <= is_connected_reg;

  -- debug
  all_nodes <= nodes;
end arch;
