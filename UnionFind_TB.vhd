-----------------------------------------------------------------------------
-- Title      : Testbench for the union find algorithm
-----------------------------------------------------------------------------
-- File       : UnionFind_TB
-- Author     : Peter Samarin <peter.samarin@smail.inf.h-brs.de>
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.UFlib.all;
use std.textio.all;
use work.txt_util.all;
------------------------------------------------------------------------
entity UnionFind_TB is
end UnionFind_TB;
------------------------------------------------------------------------
architecture Testbench of UnionFind_TB is
  constant T             : time                             := 20 ns;
  signal result          : std_logic_vector(N - 1 downto 0) := (others => '0');
  signal clk_test        : std_logic;
  signal rst             : std_logic;
  signal id1             : std_logic_vector(N-1 downto 0)   := (others => '0');
  signal id2             : std_logic_vector(N-1 downto 0)   := (others => '0');
  signal root            : std_logic_vector(N-1 downto 0)   := (others => '0');
  signal ready           : std_logic;
  signal ctrl            : std_logic_vector(1 downto 0)     := (others => '0');
  signal ctrl_valid      : std_logic                        := '0';
  signal test            : integer                          := 0;
  signal nodes           : node_vector (0 to 2**N-1)        := (others => (N-1, 1));
  shared variable ENDSIM : boolean                          := false;
  shared variable DEBUG  : boolean                          := false;
begin
  ---- Design Under Verification -----------------------------------------
  DUV : entity work.UnionFind
    generic map (
      N => N)
    port map (
      all_nodes  => nodes,
      id1        => id1,
      id2        => id2,
      ctrl       => ctrl,
      ctrl_valid => ctrl_valid,
      root       => root,
      ready      => ready,
      clk        => clk_test);

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
    variable n_errors     : integer := 0;
    variable test_nr      : integer := 1;
    variable main_test_nr : integer := 1;
--    variable DEBUG        : boolean := false;

    procedure insert_empty_space (
      constant i : in integer;
      variable s : inout line) is
    begin
      if i < 10 then
        write(s, string'(" "));
      end if;
    end procedure insert_empty_space;

    procedure print_nodes (
      signal ctrl     : in std_logic_vector(1 downto 0);
      signal id1, id2 :    std_logic_vector(N-1 downto 0)) is
      variable s         : line;
      variable operation : string(1 to 5) := "     ";
    begin
      if DEBUG then
        case ctrl is
          when "00" => operation := "idle ";
          when "01" =>
            operation := "union";
            print("union: " & integer'image(to_integer(unsigned(id1))) & ", " &
                  integer'image(to_integer(unsigned(id2))));
          when "10" =>
            operation := "find ";
            print("find: " & integer'image(to_integer(unsigned(id1))));
          when "11"   => operation := "idle ";
          when others => null;
        end case;

        -- print index
        for i in 0 to 2**N-1 loop
          insert_empty_space(i, s);
          write(s, string'(integer'image(i) & " "));
        end loop;

        writeline(output, s);
        for i in 0 to 2**N-1 loop
          insert_empty_space(nodes(i).parent,s);
          write(s, string'(integer'image(nodes(i).parent) & " "));
        end loop;
        writeline(output, s);
        for i in 0 to 2**N-1 loop
          insert_empty_space(nodes(i).weight,s);
          write(s, string'(integer'image(nodes(i).weight) & " "));
        end loop;
        writeline(output, s);
        if operation = "find " then
          print("----------------- => " & integer'image(to_integer(unsigned(root))));
        else
          print("---------------------");
        end if;
      end if;
    end procedure print_nodes;

    procedure union (
      constant x : in std_logic_vector;
      constant y : in std_logic_vector) is
    begin
      id1        <= x;
      id2        <= y;
      ctrl       <= "01";
      ctrl_valid <= '1';
      wait until rising_edge(clk_test);
      ctrl_valid <= '0';
      wait until ready = '1';
      ctrl       <= "00";
      print_nodes(ctrl, id1, id2);
    end procedure union;


    procedure union (
      constant x : in integer;
      constant y : in integer) is
      variable x_std : std_logic_vector (N-1 downto 0);
      variable y_std : std_logic_vector (N-1 downto 0);
    begin
      x_std := std_logic_vector(to_unsigned(x, N));
      y_std := std_logic_vector(to_unsigned(y, N));
      union(x_std, y_std);
    end procedure union;


    procedure find (
      constant x : in std_logic_vector) is
    begin
      id1        <= x;
      ctrl       <= "10";
      ctrl_valid <= '1';
      wait until rising_edge(clk_test);
      ctrl_valid <= '0';
      wait until ready = '1';
      ctrl       <= "00";
      print_nodes(ctrl, id1, id2);
    end procedure find;

    procedure find (constant x : in integer) is
      variable x_std : std_logic_vector (N-1 downto 0);
    begin
      x_std := std_logic_vector(to_unsigned(x, N));
      find(x_std);
    end procedure find;

    procedure should_find (constant x            : in integer;
                           constant expected     : in integer;
                           constant test_nr      : in integer;
                           constant main_test_nr : in integer
                           ) is
    begin
      find(x);
      if to_integer(unsigned(root)) /= expected then
        n_errors := n_errors + 1;
        print("--- test " & integer'image(main_test_nr) & "," & integer'image(test_nr) & ": ERROR, expected " &
              integer'image(expected) & ", got " & integer'image(to_integer(unsigned(root))));
      end if;
    end procedure should_find;

    procedure init is
    begin
      ctrl       <= "11";
      ctrl_valid <= '1';
      wait until rising_edge(clk_test);
      ctrl_valid <= '0';
      wait until ready = '1';
      ctrl       <= "00";
      print_nodes(ctrl, id1, id2);
    end procedure init;
  begin
    wait until ready = '1';
    DEBUG := false;
    for i in 0 to 8 loop
      union(i, i+1);
    end loop;

    for i in 10 to 18 loop
      union(i, i+1);
    end loop;

    for i in 20 to 30 loop
      union(i, i+1);
    end loop;

    union(9, 10);
    union(19, 20);


    main_test_nr := 1;
    for i in 0 to 31 loop
      should_find(i, 0, test_nr, main_test_nr);
      test_nr := test_nr + 1;
    end loop;

    main_test_nr := 2;
    for i in 0 to 31 loop
      should_find(i, 0, test_nr, main_test_nr);
      test_nr := test_nr + 1;
    end loop;

    -- Manual test
    DEBUG        := true;
    main_test_nr := 3;
    init;
    for i in 0 to 15 loop
      union(i, 31-i);
    end loop;


    for i in 15 to 30 loop
      union(i, i+1);
    end loop;


    wait until rising_edge(clk_test);


    --------------------------------------------------------
    -- Finish simulation
    --------------------------------------------------------
    ENDSIM := true;
    if n_errors = 0 then
      print ("----- SIMULATION SUCCESSFUL -----");
    else
      assert false report "----- SIMULATION NOT SUCCESSFUL, failed (" &
        integer'image(n_errors) & ") tests."
        severity failure;
    end if;
    wait;
  end process;
end Testbench;
