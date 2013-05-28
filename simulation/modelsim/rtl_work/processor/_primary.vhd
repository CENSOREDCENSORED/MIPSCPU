library verilog;
use verilog.vl_types.all;
entity processor is
    generic(
        INIT_PROGRAM    : string  := "C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test_no_delay.inst_rom.memh";
        DATA_MEM3       : string  := "C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test_no_delay.data_ram3.memh";
        DATA_MEM2       : string  := "C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test_no_delay.data_ram2.memh";
        DATA_MEM1       : string  := "C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test_no_delay.data_ram1.memh";
        DATA_MEM0       : string  := "C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test_no_delay.data_ram0.memh"
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        serial_in       : in     vl_logic_vector(7 downto 0);
        serial_valid_in : in     vl_logic;
        serial_ready_in : in     vl_logic;
        serial_out      : out    vl_logic_vector(7 downto 0);
        serial_rden_out : out    vl_logic;
        serial_wren_out : out    vl_logic;
        outputPC        : out    vl_logic_vector(31 downto 0);
        outputwriteDataOrPC: out    vl_logic_vector(31 downto 0);
        counter         : out    vl_logic_vector(31 downto 0);
        instructioncounter: out    vl_logic_vector(31 downto 0);
        outputReg       : out    vl_logic_vector(31 downto 0);
        instructionROMOutMEMWBOut: out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INIT_PROGRAM : constant is 1;
    attribute mti_svvh_generic_type of DATA_MEM3 : constant is 1;
    attribute mti_svvh_generic_type of DATA_MEM2 : constant is 1;
    attribute mti_svvh_generic_type of DATA_MEM1 : constant is 1;
    attribute mti_svvh_generic_type of DATA_MEM0 : constant is 1;
end processor;
