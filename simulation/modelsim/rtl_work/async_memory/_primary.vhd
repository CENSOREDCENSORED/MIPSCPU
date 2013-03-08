library verilog;
use verilog.vl_types.all;
entity async_memory is
    generic(
        MEM_ADDR        : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        DO_INIT         : integer := 0;
        INIT_PROGRAM0   : string  := "c:/altera/11.1sp1/141/hello_world.data_ram0.memh";
        INIT_PROGRAM1   : string  := "c:/altera/11.1sp1/141/hello_world.data_ram1.memh";
        INIT_PROGRAM2   : string  := "c:/altera/11.1sp1/141/hello_world.data_ram2.memh";
        INIT_PROGRAM3   : string  := "c:/altera/11.1sp1/141/hello_world.data_ram3.memh"
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        addr_in         : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0);
        data_in         : in     vl_logic_vector(31 downto 0);
        size_in         : in     vl_logic_vector(1 downto 0);
        we_in           : in     vl_logic;
        re_in           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_ADDR : constant is 1;
    attribute mti_svvh_generic_type of DO_INIT : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM0 : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM1 : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM2 : constant is 1;
    attribute mti_svvh_generic_type of INIT_PROGRAM3 : constant is 1;
end async_memory;
