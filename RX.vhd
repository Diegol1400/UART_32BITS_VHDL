library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RX is

	generic (

		g_CLKS_PER_BIT : integer := 5208;  -- 50Mhz/9600bps
		g_CLKS_PER_HALF_BIT : integer := 2604  -- 50Mhz/9600bps/2
	);

	port(

		CLK           : in std_logic; 
		RX_LINE       : in std_logic; 
		RX_DATA_VALID : out std_logic;--
		RX_DATA       : out std_logic_vector( 7 downto 0 )  -- buffer
	);

end entity;


architecture arch of RX is

	type STATEMACHINE is ( 

		s_idle,      -- Espera transmision de datos
		s_startBit,  -- Detecta bit de inicio
		s_dataBits,  -- Recopilacion de datos
		s_stopBit    -- Detecta bit de paro
	);

	signal state : STATEMACHINE := s_idle;

	signal clkCount  : integer range 0 to g_CLKS_PER_BIT - 1 := 0;
	signal dataIndex : integer range 0 to 7 := 0;
	signal data      : std_logic_vector( 7 downto 0 ) := ( others => '0' );
	signal dataValid : std_logic := '0';

	

begin

	RX_DATA_VALID <= dataValid;
	RX_DATA <= data;

	process( CLK )

	begin

		if rising_edge( CLK ) then

			case state is

				-- Esepra transmision de datos

				when s_idle =>

					dataValid <= '0';
					clkCount <= 0;   -- Cuenta del reloj se mantiene  en 0
					dataIndex <= 0;

					if RX_LINE = '0' then  -- Detecta bit de inicio

						state <= s_startBit;

					else
						
						state <= s_idle;

					end if;

				-- Estado del bit de inicio. Compruebe que sigue estado bajo

				when s_startBit =>

					if clkCount = g_CLKS_PER_HALF_BIT then  -- sample bit

						if RX_LINE = '0' then -- si se matinene en estado bajo, cambia al siguiente estado

							clkCount <= 0; 

							state <= s_dataBits;

						else  -- si no se matiene en estado bajo, regresa al estado anterior
							
							state <= s_idle;

						end if;

					else  --Mantiene el estado hasta alacanzar el conteo del reloj

						clkCount <= clkCount + 1;

						state <= s_startBit;

					end if;

				-- Recopilacion de datos

				when s_dataBits =>

					if clkCount < g_CLKS_PER_BIT - 1 then   -- Espera hasta que el reloj alcanze 50Mhz/9600bps

						clkCount <= clkCount + 1;

						state <= s_dataBits;

					else  
						
						clkCount <= 0;

						data( dataIndex ) <= RX_LINE;  -- lee el bit recibido



						if dataIndex < 7 then --checa que todos los bits se recibieron

							dataIndex <= dataIndex + 1;

							state <= s_dataBits;

						else -- Se recibieron todos los bits, pasa al sigueinte estado
							
							dataIndex <= 0;       

							state <= s_stopBit;
							
						end if ;

					end if;

				

				when s_stopBit =>  --Bit de paro

					if clkCount < g_CLKS_PER_BIT - 1 then  -- Espera hasta que el reloj alcanze 50Mhz/9600bps
						
						clkCount <= clkCount + 1;

						state <= s_stopBit;

					else  

						dataValid <= '1';

						clkCount <= 0;

						state <= s_idle;

					end if;

				

				when others =>

					state <= s_idle;

			end case;

		end if;

	end process;

end architecture;