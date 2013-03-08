library verilog;
use verilog.vl_types.all;
entity adder is
    port(
        input1          : in     vl_logic_vector(31 downto 0);
        input2          : in     vl_logic_vector(31 downto 0);
        output1         : out    vl_logic_vector(31 downto 0)
    );
end adder;
