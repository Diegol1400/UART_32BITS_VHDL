library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TX is

	generic (

		g_CLKS_PER_BIT : integer := 5208  -- 50Mhz/9600bps
	);

	port(

		CLK           : in std_logic;
		TX_DATA_VALID : in std_logic;  
		TX_DATA       : in std_logic_vector( 7 downto 0 );  -- buffer
		TX_LINE       : out std_logic; --Transmision de datos
		TX_ACTIVE     : out std_logic;
		TX_DONE       : out std_logic
	);

end entity;


architecture arch of TX is

	type STATEMACHINE is ( 

		s_idle,      -- Espera
		s_startBit,  -- Transmite bit de incio
		s_dataBits,  -- Transmite datos
		s_stopBit    -- Transmite bit de paro
	);

	signal state : STATEMACHINE := s_idle;

	signal clkCount  : integer range 0 to g_CLKS_PER_BIT - 1 := 0;
	signal dataIndex : integer range 0 to 7 := 0;
	signal data      : std_logic_vector( 7 downto 0 ) := ( others => '0' );
	signal done      : std_logic := '0';

begin

	TX_DONE <= done;

	process( CLK )

	begin

		if rising_edge( CLK ) then

			case state is

				-- Espera trasnmision de datos

				when s_idle =>

					TX_LINE <= '1';  -- Mantiene la linea en estado alto

					TX_ACTIVE <= '0';
					done <= '0';
					clkCount <= 0;
					dataIndex <= 0;

					if TX_DATA_VALID = '1' then

						data <= TX_DATA; -- guardar datos para enviarlos en caso de actualizaciones

						state <= s_startBit;

					else
						
						state <= s_idle;

					end if;

				-- Bit de inicio

				when s_startBit =>

					TX_ACTIVE <= '1';

					TX_LINE <= '0';  -- Estado bajo, para bit de inicio

					if clkCount < g_CLKS_PER_BIT - 1 then

						clkCount <= clkCount + 1;

						state <= s_startBit;

					else
						
						clkCount <= 0;

						state <= s_dataBits;

					end if;

				-- Estado trasnmision de datos

				when s_dataBits =>

					TX_LINE <= data( dataIndex );  -- Envia bits

					-- Espera por bit

					if clkCount < g_CLKS_PER_BIT - 1 then

						clkCount <= clkCount + 1;

						state <= s_dataBits;

					else
						
						clkCount <= 0;

						-- Checa que se mandaron todos los bits

						if dataIndex < 7 then

							dataIndex <= dataIndex + 1;

							state <= s_dataBits;

						-- Sent all data

						else

							dataIndex <= 0;

							state <= s_stopBit;

						end if;

					end if;

				-- Estado bit de paro

				when s_stopBit =>

					TX_LINE <= '1';  -- Estado en alto para bit de paro

					-- Espera	

					if clkCount < g_CLKS_PER_BIT - 1 then

						clkCount <= clkCount + 1;

						state <= s_stopBit;

					else
						
						clkCount <= 0;

						TX_ACTIVE <= '0';
						done <= '1';

						state <= s_idle;

					end if;

				when others =>

					state <= s_idle;

			end case;

		end if;

	end process;

end architecture;