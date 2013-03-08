library verilog;
use verilog.vl_types.all;
entity instructioncounter is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        instruction     : in     vl_logic_vector(31 downto 0);
        instructioncounter: out    vl_logic_vector(31 downto 0)
    );
end instructioncounter;
