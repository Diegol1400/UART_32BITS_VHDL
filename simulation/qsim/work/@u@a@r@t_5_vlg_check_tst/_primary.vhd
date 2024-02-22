library verilog;
use verilog.vl_types.all;
entity UART_5_vlg_check_tst is
    port(
        LEDS            : in     vl_logic_vector(31 downto 0);
        TX_LINE         : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end UART_5_vlg_check_tst;
