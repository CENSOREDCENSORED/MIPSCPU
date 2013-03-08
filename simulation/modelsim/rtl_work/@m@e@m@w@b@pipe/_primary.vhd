library verilog;
use verilog.vl_types.all;
entity MEMWBPipe is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        O_outEXMEM      : in     vl_logic_vector(31 downto 0);
        o_RT_DataEXMEM  : in     vl_logic_vector(31 downto 0);
        reg2EXMEM       : in     vl_logic_vector(4 downto 0);
        reg3EXMEM       : in     vl_logic_vector(4 downto 0);
        mux1SelectEXMEM : in     vl_logic;
        mux3SelectEXMEM : in     vl_logic;
        linkRegEXMEM    : in     vl_logic;
        pcPlus4EXMEM    : in     vl_logic_vector(31 downto 0);
        instructionROMOutEXMEM: in     vl_logic_vector(31 downto 0);
        i_Write_EnableEXMEM: in     vl_logic;
        readdata_out    : in     vl_logic_vector(31 downto 0);
        O_outMEMWB      : out    vl_logic_vector(31 downto 0);
        o_RT_DataMEMWB  : out    vl_logic_vector(31 downto 0);
        reg2MEMWB       : out    vl_logic_vector(4 downto 0);
        reg3MEMWB       : out    vl_logic_vector(4 downto 0);
        mux1SelectMEMWB : out    vl_logic;
        mux3SelectMEMWB : out    vl_logic;
        linkRegMEMWB    : out    vl_logic;
        pcPlus4MEMWB    : out    vl_logic_vector(31 downto 0);
        instructionROMOutMEMWB: out    vl_logic_vector(31 downto 0);
        i_Write_EnableMEMWB: out    vl_logic;
        readdata_outMEMWB: out    vl_logic_vector(31 downto 0)
    );
end MEMWBPipe;
