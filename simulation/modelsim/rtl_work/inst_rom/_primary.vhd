library verilog;
use verilog.vl_types.all;
entity inst_rom is
    generic(
        ADDR_WIDTH      : integer := 8;
        INIT_PROGRAM    : string  := ""
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        stall           : in     vl_logic;
        addr_in         : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM : constant is 1;
end inst_rom;
