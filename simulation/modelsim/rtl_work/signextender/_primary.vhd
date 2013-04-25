library verilog;
use verilog.vl_types.all;
entity signextender is
    port(
        enable          : in     vl_logic;
        input1          : in     vl_logic_vector(15 downto 0);
        output1         : out    vl_logic_vector(31 downto 0)
    );
end signextender;
