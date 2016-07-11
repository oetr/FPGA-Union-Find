----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
----------------------------------------------------------------------
package UFlib is
  constant N : integer := 5;
  type node is record
    parent : integer range 0 to 2**N-1;
    weight : integer range 0 to 2**N;
  end record node;
  type node_vector is array (natural range <>) of node;
end UFlib;
