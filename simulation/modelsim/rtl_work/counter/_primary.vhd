library verilog;
use verilog.vl_types.all;
entity counter is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        counter         : out    vl_logic_vector(31 downto 0)
    );
end counter;
