library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity de1 is
	port (
		CLOCK_50 : in std_logic;
		reset : in std_logic;
		led_running : out std_logic;
		led_found : out std_logic;
		led_overflow : out std_logic;
--		////////////////////////	UART	////////////////////////
		spi_mosi : in std_logic;
		spi_sck : in std_logic;
		spi_ss : in std_logic;
		spi_miso : out std_logic
		
	);
end;

architecture beh of de1 is

signal nreset : std_logic;



signal pll_clk : std_logic;
signal pll_reset : std_logic := '0';
signal pll_locked : std_logic;

signal spi_data_tx : std_logic_vector(31 downto 0);
signal spi_data_rx  : std_logic_vector(31 downto 0);
signal spi_data_rx_en : std_logic;


signal pll_slow : std_logic;

component spi_slave
	port
	(
		clk : in std_logic;
		reset : in std_logic;
		
		mosi : in std_logic;
		miso : out std_logic;
		sck : in std_logic;
		ss : in std_logic;
		
		
		data_rd : in std_logic_vector(31 downto 0);
		data_wr : out std_logic_vector(31 downto 0);
		data_wren : out std_logic
	);
end component;

component pll
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1 : out std_logic;
		locked		: OUT STD_LOGIC 
	);
end component;

component curl
	port
	(
		clk : in std_logic;
		clk_slow : in std_logic;
		reset : in std_logic;
		
		spi_data_rx : in std_logic_vector(31 downto 0);
		spi_data_tx : out std_logic_vector(31 downto 0);
		spi_data_rxen : in std_logic;

		overflow : out std_logic;
		running : out std_logic;
		found : out std_logic
	);
end component;

begin
	nreset <= not reset;


	pll0 : pll port map (
		areset => pll_reset,
		inclk0 => CLOCK_50,
		c0 => pll_clk,
		c1	=> pll_slow,
		locked => pll_locked
	);
	
	
	spi0 : spi_slave port map (
		clk => pll_slow,
		reset => nreset,
		
		mosi => spi_mosi,
		miso => spi_miso,
		sck => spi_sck,
		ss => spi_ss,
		
		data_rd => spi_data_tx,
		data_wr => spi_data_rx,
		data_wren => spi_data_rx_en
	);
	
	curl0 : curl port map (
		clk => pll_clk,
		reset => nreset,
		clk_slow => pll_slow,
		
		spi_data_rx => spi_data_rx,
		spi_data_tx => spi_data_tx,
		spi_data_rxen => spi_data_rx_en,
		
		overflow => led_overflow,
		running => led_running,
		found => led_found
	);
	

end architecture;