library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity UART_5 is

	port(
      --80 y 81 no sirven
		CLK : in std_logic;  -- PIN_17
		
		lee, esc: in std_logic;
	   dir: in std_logic_vector(1 downto 0);

		RX_LINE : in std_logic;   -- PIN_40
		TX_LINE : out std_logic;  -- PIN_42

		BTN  : in std_logic;                       -- 1 button  -- PIN_144
		LEDS : out std_logic_vector( 31 downto 0 );  
		DATO : in std_logic_vector( 7 downto 0 )  
	);

end entity;

architecture arch of UART_5 is

	subtype byte is std_logic_vector(7 downto 0);
	type tm is array(0 to 15) of byte; --matriz
	signal mem: tm;

	signal dataValid_TX : std_logic := '0';
	signal data_TX      : std_logic_vector( 7 downto 0 ) := ( others => '0' );
	signal active_TX     : std_logic;
	signal done_TX       : std_logic;

	signal dataValid_RX : std_logic;
	signal data_RX      : std_logic_vector( 7 downto 0 ) := ( others => '1' ); 

	component UART_TX is 

		--generic (
		--
		--	g_CLKS_PER_BIT : integer
		--);

		port(

			CLK           : in std_logic;
			TX_DATA_VALID : in std_logic;  -- Iniciar transmision
			TX_DATA       : in std_logic_vector( 7 downto 0 );  -- buffer
			TX_LINE       : out std_logic;
			TX_ACTIVE     : out std_logic;
			TX_DONE       : out std_logic
		);

	end component;

	component UART_RX is

		--generic (
		--
		--	g_CLKS_PER_BIT : integer;
		--	g_CLKS_PER_HALF_BIT : integer
		--);	

		port(

			CLK           : in std_logic;
			RX_LINE       : in std_logic;
			RX_DATA_VALID : out std_logic;
			RX_DATA       : out std_logic_vector( 7 downto 0 )  -- buffer
		);

	end component;

begin

	-- Instanciar Uart Tx
	UART_TX_instance : TX

		--generic map (
		--
		--	5208  -- CLKS_PER_BIT 50Mhz/9600bps
		--)

		port map (

			CLK,           -- in
			dataValid_TX,  -- in
			data_TX,       -- in
			TX_LINE,       -- out
			active_TX,     -- out
			done_TX        -- out
		);

	-- Instanciar Uart Rx
	UART_RX_instance : RX

		--generic map (
		--
		--	5208, -- CLKS_PER_BIT
		--	2604  -- CLKS_PER_HALF_BIT
		--)

		port map (

			CLK,           -- in
			RX_LINE,       -- in
			dataValid_RX,  -- out
			data_RX        -- out
		);

	process( CLK )
		variable ind: unsigned(1 downto 0);
	begin

		if rising_Edge( CLK ) then

			-- Si el boton esta prsionado y el transmisor no esta ocupado

			if BTN = '0' and active_TX = '0' then
            
				dataValid_TX <= '1';

				data_TX <= DATO(7 downto 0) ;  

			else
				
				dataValid_TX <= '0';

			end if;

				
			ind:=unsigned(dir);		
			if lee='1' then --Si lee esta en 1 va mostrar los datos guardados en cada direccion
				case dir is
					when"00"=> ind:=unsigned(dir); LEDS(7 downto 0)<=mem(to_integer(ind)); 
					LEDS(15 downto 8)<="00000000"; LEDS(23 downto 16)<="00000000"; LEDS(31 downto 24)<="00000000";
					
					when"01"=>  ind:=unsigned(dir); LEDS(15 downto 8)<=mem(to_integer(ind)); 
					LEDS(7 downto 0)<="00000000"; LEDS(23 downto 16)<="00000000"; LEDS(31 downto 24)<="00000000";
					
					when"10"=>  ind:=unsigned(dir); LEDS(23 downto 16)<=mem(to_integer(ind)); 
					LEDS(7 downto 0)<="00000000"; LEDS(15 downto 8)<="00000000"; LEDS(31 downto 24)<="00000000";
					
					when others => ind:=unsigned(dir); LEDS(31 downto 24)<=mem(to_integer(ind)); 
					LEDS(7 downto 0)<="00000000"; LEDS(15 downto 8)<="00000000";
					LEDS(23 downto 16)<="00000000";
					
					--LEDS(15 downto 0)<="0000000000000000";
				end case;	
				
			elsif esc='1' then -- si escribe esta en 1 va a guarda los datos recibidos
				mem(to_integer(ind))<=data_RX(7 downto 0 );
			end if;
			
		end if;

	end process;

end architecture;