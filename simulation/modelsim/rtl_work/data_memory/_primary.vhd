library verilog;
use verilog.vl_types.all;
entity data_memory is
    generic(
        INIT_PROGRAM0   : string  := "";
        INIT_PROGRAM1   : string  := "";
        INIT_PROGRAM2   : string  := "";
        INIT_PROGRAM3   : string  := ""
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        addr_in         : in     vl_logic_vector(31 downto 0);
        writedata_in    : in     vl_logic_vector(31 downto 0);
        re_in           : in     vl_logic;
        we_in           : in     vl_logic;
        size_in         : in     vl_logic_vector(1 downto 0);
        lhunsigned_outEXMEM: in     vl_logic;
        lhsigned_outEXMEM: in     vl_logic;
        lbunsigned_outEXMEM: in     vl_logic;
        lbsigned_outEXMEM: in     vl_logic;
        readdata_out    : out    vl_logic_vector(31 downto 0);
        serial_in       : in     vl_logic_vector(7 downto 0);
        serial_ready_in : in     vl_logic;
        serial_valid_in : in     vl_logic;
        serial_out      : out    vl_logic_vector(7 downto 0);
        serial_rden_out : out    vl_logic;
        serial_wren_out : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INIT_PROGRAM0 : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM1 : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM2 : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM3 : constant is 1;
end data_memory;
