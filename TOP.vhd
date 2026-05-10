----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/05/11 05:12:01
-- Design Name: 
-- Module Name: TOP - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
  Port (clk : in  STD_LOGIC;
         nrst : in  STD_LOGIC;
         rx_complete : in  STD_LOGIC;
         data_in : in  STD_LOGIC_vector(7 downto 0);
         data_out : out  STD_LOGIC_vector(15 downto 0);
        i_sclk : in std_logic;
        i_ss : in std_logic;
        i_mosi : in std_logic;
        --o_miso : out std_logic
  );
end TOP;

architecture RTL of TOP is

component statement is
  Port ( clk : in  STD_LOGIC;
         nrst : in  STD_LOGIC;
         rx_complete : in  STD_LOGIC;
         data_in : in  STD_LOGIC_vector(7 downto 0);
         data_out : out  STD_LOGIC_vector(15 downto 0)
  );
end component;

component spi_slave is
    generic (
        N : integer := 8; -- Number of bits to serialize
        CPOL : std_logic := '0'; -- Clock polarity
        CPHA : std_logic := '0' -- Clock phase
        );
    
    port (
        o_busy : out std_logic; --receiving data if'1'
        i_data_parallel : in std_logic_vector(N-1 downto 0); --data to sent
        o_data_parallel : out std_logic_vector(N-1 downto 0); --received data
        o_rx_complete : out std_logic; --indicates reception complete
        i_sclk : in std_logic;--SPI clock
        i_ss : in std_logic;--Slave select, active low
        i_mosi : in std_logic;--Master Out Slave In
        o_miso : out std_logic--Master In Slave Out
    );
end component;


begin
U1: statement
port map (
    clk => clk,
    nrst => nrst,
    rx_complete => rx_complete,
    data_in => data_in,
    data_out => data_out
);  
U2: spi_slave
generic map (
    N => 8,
    CPOL => '0',
    CPHA => '0'
)
port map (
    i_sclk => i_sclk,
    i_ss => i_ss,
    i_mosi => i_mosi,
    o_data_parallel => data_in,
    o_rx_complete => rx_complete
    --o_miso => o_miso
);


end RTL;
