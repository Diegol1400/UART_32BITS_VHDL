library verilog;
use verilog.vl_types.all;
entity UART_5 is
    port(
        CLK             : in     vl_logic;
        lee             : in     vl_logic;
        esc             : in     vl_logic;
        dir             : in     vl_logic_vector(1 downto 0);
        RX_LINE         : in     vl_logic;
        TX_LINE         : out    vl_logic;
        BTN             : in     vl_logic;
        LEDS            : out    vl_logic_vector(31 downto 0);
        DATO            : in     vl_logic_vector(7 downto 0)
    );
end UART_5;
