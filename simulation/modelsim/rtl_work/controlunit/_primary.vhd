library verilog;
use verilog.vl_types.all;
entity controlunit is
    port(
        instruction     : in     vl_logic_vector(31 downto 0);
        Func_in         : out    vl_logic_vector(5 downto 0);
        mux1Select      : out    vl_logic;
        mux2Select      : out    vl_logic;
        mux3Select      : out    vl_logic;
        muxShiftSelect  : out    vl_logic;
        re_in           : out    vl_logic;
        we_in           : out    vl_logic;
        i_Write_Enable  : out    vl_logic;
        linkReg         : out    vl_logic;
        jumpReg         : out    vl_logic;
        upper           : out    vl_logic;
        lhunsigned_out  : out    vl_logic;
        lhsigned_out    : out    vl_logic;
        lbunsigned_out  : out    vl_logic;
        lbsigned_out    : out    vl_logic
    );
end controlunit;
