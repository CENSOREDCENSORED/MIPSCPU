library verilog;
use verilog.vl_types.all;
entity processor is
    port(
        serial_out      : out    vl_logic_vector(7 downto 0);
        serial_rden_out : out    vl_logic;
        serial_wren_out : out    vl_logic;
        outputPC        : out    vl_logic_vector(31 downto 0);
        outputwriteDataOrPC: out    vl_logic_vector(31 downto 0);
        counter         : out    vl_logic_vector(31 downto 0);
        instructioncounter: out    vl_logic_vector(31 downto 0);
        outputReg       : out    vl_logic_vector(31 downto 0);
        instructionROMOutMEMWBOut: out    vl_logic_vector(31 downto 0);
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        serial_in       : in     vl_logic_vector(7 downto 0);
        serial_valid_in : in     vl_logic;
        serial_ready_in : in     vl_logic
    );
end processor;
