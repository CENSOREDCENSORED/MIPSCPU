library verilog;
use verilog.vl_types.all;
entity programcounter is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        stall           : in     vl_logic;
        input1          : in     vl_logic_vector(31 downto 0);
        output1         : out    vl_logic_vector(31 downto 0)
    );
end programcounter;
