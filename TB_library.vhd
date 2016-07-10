----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
----------------------------------------------------------------------
package TB_library is
  constant N : integer := 2;
  type test_vector is record
    node1 : std_logic_vector(N-1 downto 0);
    node2 : std_logic_vector(N-1 downto 0);
    ctrl  : std_logic_vector(1 downto 0);
  end record test_vector;

  function slv2test (slv : std_logic_vector) return test_vector;
  ------------------------------------------------------------------
  -- compare two signals and write an error message
  -- if circuit outputs are not as expected
  ------------------------------------------------------------------
  procedure compare_vectors (constant result   : in std_logic_vector;
                             constant expected : in std_logic_vector;
                             constant test_nr  : in integer);

  procedure compare_vectors (constant result     : in    std_logic_vector;
                             constant expected   : in    std_logic_vector;
                             constant test_nr    : in    integer;
                             signal failed_tests : inout integer);

  ------------------------------------------------------------------
  -- read input and expected output from a file
  ------------------------------------------------------------------
  procedure read_input_output_pair (
    file test_file    :     text;
    variable input    : out std_logic_vector;
    variable expected : out std_logic_vector);

end TB_library;


package body TB_library is
  function slv2test (slv : std_logic_vector) return test_vector is
    variable test : test_vector;
  begin
    test.node1 := slv(2*N + 1 downto N+2);
    test.node2 := slv(N+1 downto 2);
    test.ctrl  := slv(1 downto 0);
    return test;
  end;

  ------------------------------------------------------------------
  -- compare two vectors and write an error message
  -- if circuit outputs are not as expected
  ------------------------------------------------------------------
  procedure compare_vectors (
    constant result   : in std_logic_vector;
    constant expected : in std_logic_vector;
    constant test_nr  : in integer) is
    variable was_error : boolean;
  begin
    if result /= expected then
      print("");
      print("ERROR in test #" & integer'image(test_nr) &
            ": got " & hstr(result) & ", expected: " & hstr(expected));
      print("--------------------------------------------------------------------------");
    end if;
  end procedure compare_vectors;


  ------------------------------------------------------------------
  -- compare two vectors and write an error message
  -- if circuit outputs are not as expected
  -- increment the number of failed tests
  ------------------------------------------------------------------
  procedure compare_vectors (
    constant result     : in    std_logic_vector;
    constant expected   : in    std_logic_vector;
    constant test_nr    : in    integer;
    signal failed_tests : inout integer) is
    variable was_error : boolean;
  begin
    if result /= expected then
      print("");
      print("ERROR in test #" & integer'image(test_nr) &
            ": got " & hstr(result) & ", expected: " & hstr(expected));
      print("--------------------------------------------------------------------------");
      failed_tests <= failed_tests + 1;
    end if;
  end procedure compare_vectors;

  ------------------------------------------------------------------
  -- read input and expected output from a file
  ------------------------------------------------------------------
  procedure read_input_output_pair (
    file test_file    :     text;
    variable input    : out std_logic_vector;
    variable expected : out std_logic_vector) is
    variable L : line;
    variable str : string (input'left-1 downto input'right);
  begin
    readline(test_file, L);
    str_read (L, str);
    print("hex_read input");
    std_read (L, expected);
  end procedure read_input_output_pair;


end TB_library;
