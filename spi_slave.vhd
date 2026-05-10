library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
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
end spi_slave;


architecture RTL of spi_slave is

    signal r_tx_data : std_logic_vector(N-1 downto 0);--data to sent
    signal r_rx_data : std_logic_vector(N-1 downto 0);--received data
    signal r_rx_complete : std_logic := '0';--indicates reception complete

    signal r_bit_cnt : integer range 0 to N-1 := 0;--bit counter for shifting
    signal s_sample_edge : std_logic;--indicates the edge to sample data
    signal s_shift_edge : std_logic;--indicates the edge to shift data

    begin
    --------------------------------------------------------------------
    -- CPOL / CPHA Edge Selection
    --------------------------------------------------------------------

    -- Mode 0 : CPOL=0 CPHA=0
    -- Sample : Rising
    -- Shift  : Falling

    -- Mode 1 : CPOL=0 CPHA=1
    -- Sample : Falling
    -- Shift  : Rising

    -- Mode 2 : CPOL=1 CPHA=0
    -- Sample : Falling
    -- Shift  : Rising

    -- Mode 3 : CPOL=1 CPHA=1
    -- Sample : Rising
    -- Shift  : Falling

    s_sample_edge <= '1' when (CPOL xor CPHA) = '0' else '0';
    s_shift_edge  <= not s_sample_edge;
    
    --------------------------------------------------------------------
    -- Busy
    --------------------------------------------------------------------
    o_busy <= not i_ss;
    o_rx_complete <= r_rx_complete;
    o_data_parallel <= r_rx_data;--output the received data
    ----------------------------------------------------------------------
    -- SPI MAIN PROCESS
    --------------------------------------------------------------------
    p_spi : process(i_sclk, i_ss)
    begin
        ----------------------------------------------------------------
        -- Slave Disable
        ----------------------------------------------------------------
        if i_ss = '1' then
            r_bit_cnt <= 0;
            r_tx_data <= i_data_parallel;
            o_miso <= 'Z';
            r_rx_complete <= '0';
        ----------------------------------------------------------------
        -- Rising Edge
        ----------------------------------------------------------------
        elsif rising_edge(i_sclk) then
            r_rx_complete <= '0'; -- Clear reception complete flag at the start of each process cycle
            ------------------------------------------------------------
            -- SAMPLE on Rising
            ------------------------------------------------------------
            if s_sample_edge = '1' then
                r_rx_data <= r_rx_data(N-2 downto 0) & i_mosi;
                if (r_bit_cnt = N-2) then
                    r_bit_cnt <= 0; -- Reset bit counter after receiving N bits
                    r_rx_complete <= '1'; -- Indicate reception complete
                else
                    r_bit_cnt <= r_bit_cnt + 1;
                end if;
            end if;

            ------------------------------------------------------------
            -- SHIFT on Rising
            ------------------------------------------------------------
            if s_shift_edge = '1' then
                o_miso <= r_tx_data(N-1);
                r_tx_data <= r_tx_data(N-2 downto 0) & '0';
            end if;

        ----------------------------------------------------------------
        -- Falling Edge
        ----------------------------------------------------------------
        elsif falling_edge(i_sclk) then
            r_rx_complete <= '0'; 
            ------------------------------------------------------------
            -- SAMPLE on Falling
            ------------------------------------------------------------
            if s_sample_edge = '0' then
                r_rx_data <= r_rx_data(N-2 downto 0) & i_mosi;
                if (r_bit_cnt = N-2) then
                    r_bit_cnt <= 0; -- Reset bit counter after receiving N bits
                    r_rx_complete <= '1'; -- Indicate reception complete
                else
                    r_bit_cnt <= r_bit_cnt + 1;
                end if;
            end if;

            ------------------------------------------------------------
            -- SHIFT on Falling
            ------------------------------------------------------------
            if s_shift_edge = '0' then
                o_miso <= r_tx_data(N-1);
                r_tx_data <= r_tx_data(N-2 downto 0) & '0';
            end if;
        end if;
    end process;

end RTL;