library verilog;
use verilog.vl_types.all;
entity hazardDetectionStall is
    port(
        reg2write       : in     vl_logic_vector(4 downto 0);
        reg1            : in     vl_logic_vector(4 downto 0);
        reg2            : in     vl_logic_vector(4 downto 0);
        opcodeWrite     : in     vl_logic_vector(5 downto 0);
        opcodeRead      : in     vl_logic_vector(5 downto 0);
        funcRead        : in     vl_logic_vector(5 downto 0);
        stall           : out    vl_logic
    );
end hazardDetectionStall;
