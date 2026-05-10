----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/05/11 05:14:32
-- Design Name: 
-- Module Name: statement - RTL
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity statement is
--  Port ( clk : in  STD_LOGIC;
--         nrst : in  STD_LOGIC;
--         rx_complete : in  STD_LOGIC;
--         data_in : in  STD_LOGIC_vector(7 downto 0);
--         data_out : out  STD_LOGIC_vector(15 downto 0);
end statement;

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

architecture RTL of statement is

type state is (IDLE, RECEIVE, DONE);
signal current_state, next_state : state;
signal mcu_send : std_logic;
signal data_out_reg : std_logic_vector(15 downto 0);

begin
--プリップフロップ
    process(clk, nrst)
    if nrst = '0' then
        current_state <= IDLE;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if; 
    end process;
--状態遷移
    process(current_state, rx_complete, mcu_send)
    case current_state is
        when IDLE =>
            if rx_complete = '1' then
                next_state <= RECEIVE;
            else
                next_state <= IDLE;
            end if;
        when RECEIVE =>
            if mcu_send = '1' then
                next_state <= DONE;
            else
                next_state <= RECEIVE;
            end if;
        when DONE =>
            next_state <= IDLE;
    end case;
end process;
--処理部分
    process(current_state)
    case current_state is
        when IDLE =>
            data_out_reg <= (others => '0');
            mcu_send <= '0';
        when RECEIVE =>
            case( data_in ) is
            
                when X"00" => data_out_reg <= data_out_reg
                when X"01" => data_out_reg(0) <= not data_out_reg(0);
                when X"02" => data_out_reg(1) <= not data_out_reg (1);
                when X"03" => data_out_reg(2) <= not data_out_reg(2);
                when X"04" => data_out_reg(3) <= not data_out_reg(3);
                when X"05" => data_out_reg(4) <= not data_out_reg(4);
                when X"06" => data_out_reg(5) <= not data_out_reg(5);
                when X"07" => data_out_reg(6) <= not data_out_reg(6);
                when X"08" => data_out_reg(7) <= not data_out_reg(7);
                when X"09" => data_out_reg(8) <= not data_out_reg(8);
                when X"0A" => data_out_reg(9) <= not data_out_reg(9);
                when X"0B" => data_out_reg(10) <= not data_out_reg(10);
                when X"0C" => data_out_reg(11) <= not data_out_reg(11);
                when X"0D" => data_out_reg(12) <= not data_out_reg(12);
                when X"0E" => data_out_reg(13) <= not data_out_reg(13);
                when X"0F" => data_out_reg(14) <= not data_out_reg(14);            
                when others => data_out_reg(15) <= not data_out_reg(15);
            end case;
            mcu_send <= '1';
        when DONE =>
            mcu_send <= '0';
            end case ;

    data_out <= data_out_reg;

end RTL;
