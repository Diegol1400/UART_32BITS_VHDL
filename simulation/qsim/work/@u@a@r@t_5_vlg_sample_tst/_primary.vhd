library verilog;
use verilog.vl_types.all;
entity UART_5_vlg_sample_tst is
    port(
        BTN             : in     vl_logic;
        CLK             : in     vl_logic;
        DATO            : in     vl_logic_vector(7 downto 0);
        dir             : in     vl_logic_vector(1 downto 0);
        esc             : in     vl_logic;
        lee             : in     vl_logic;
        RX_LINE         : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end UART_5_vlg_sample_tst;
