library verilog;
use verilog.vl_types.all;
entity serial_buffer is
    generic(
        MEM_ADDR        : vl_logic_vector(0 to 15) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1)
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        addr_in         : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0);
        re_in           : in     vl_logic;
        data_in         : in     vl_logic_vector(31 downto 0);
        we_in           : in     vl_logic;
        s_data_valid_in : in     vl_logic;
        s_data_in       : in     vl_logic_vector(7 downto 0);
        s_data_ready_in : in     vl_logic;
        s_rden_out      : out    vl_logic;
        s_data_out      : out    vl_logic_vector(7 downto 0);
        s_wren_out      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_ADDR : constant is 1;
end serial_buffer;
