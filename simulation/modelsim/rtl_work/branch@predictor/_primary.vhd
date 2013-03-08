library verilog;
use verilog.vl_types.all;
entity branchPredictor is
    generic(
        width           : integer := 6;
        offset          : integer := 2
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        addressToWrite  : in     vl_logic_vector(31 downto 0);
        branchoutcome   : in     vl_logic;
        addressToPredict: in     vl_logic_vector(31 downto 0);
        prediction      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
    attribute mti_svvh_generic_type of offset : constant is 1;
end branchPredictor;
