library verilog;
use verilog.vl_types.all;
entity hazardDetectionNoStall is
    port(
        writeReg2       : in     vl_logic_vector(4 downto 0);
        writeReg3       : in     vl_logic_vector(4 downto 0);
        reg1            : in     vl_logic_vector(4 downto 0);
        reg2            : in     vl_logic_vector(4 downto 0);
        opcode          : in     vl_logic_vector(5 downto 0);
        func            : in     vl_logic_vector(5 downto 0);
        hazardReg1      : out    vl_logic;
        hazardReg2      : out    vl_logic
    );
end hazardDetectionNoStall;
