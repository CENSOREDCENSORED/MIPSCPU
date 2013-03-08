library verilog;
use verilog.vl_types.all;
entity alu is
    port(
        Func_in         : in     vl_logic_vector(5 downto 0);
        A_in            : in     vl_logic_vector(31 downto 0);
        B_in            : in     vl_logic_vector(31 downto 0);
        upper           : in     vl_logic;
        O_out           : out    vl_logic_vector(31 downto 0);
        Branch_out      : out    vl_logic;
        Jump_out        : out    vl_logic
    );
end alu;
