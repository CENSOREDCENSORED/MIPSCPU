library verilog;
use verilog.vl_types.all;
entity IFIDPipe is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        stall           : in     vl_logic;
        instructionROMOut: in     vl_logic_vector(31 downto 0);
        pcPlus4         : in     vl_logic_vector(31 downto 0);
        Branch_out      : in     vl_logic;
        Jump_out        : in     vl_logic;
        prediction      : in     vl_logic;
        instructionROMOutIFID: out    vl_logic_vector(31 downto 0);
        pcPlus4IFID     : out    vl_logic_vector(31 downto 0);
        predictionIFID  : out    vl_logic
    );
end IFIDPipe;
