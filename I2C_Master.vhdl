--MASTER ENTITY
library IEEE;
use IEEE.std_logic_1164.all;

entity I2C_Master is
	port(ENABLE     : in std_logic;
         SCL		: out std_logic;
         SDA	 	: inout std_logic := '1';
         clk_in     : in std_logic;
         Data_in	: in std_logic;
         Reset		: in std_logic;
         Data_out	: out std_logic_vector(7 downto 0)
    );
end entity;

architecture arch of I2C_Master is

    -- State.
    type state is (IDDLE, SLAVE_ADD, ACK1, INT_ADD, ACK2, DATA_RW, ACK3, STP);
    signal current_state: state;

    -- Signals.
    signal count      : integer range 0 to 12 := 0;
    signal clk        : std_logic;
    signal shift      : std_logic_vector(7 downto 0);
    signal R_W 	      : std_logic;
    signal SDA_signal : std_logic;

begin

    SDA <= SDA_signal when ENABLE = '1' else 'Z';

	process(clk, SDA, Reset)
    begin
    	if Reset = '1' then
        	count <= 0;
            current_state <= IDDLE;
            SDA_signal <= '1';
    	else
            case current_state is
                -- IDDLE.
                when IDDLE =>
                    SDA_signal <= data_in;
                    if clk = '1' and SDA = '0' then
                    	current_state <= SLAVE_ADD;
                    end if;
                -- Slave Address.
                when SLAVE_ADD =>
                	if clk'event and clk = '0' then
                    	count <= count + 1;
                        SDA_signal <= Data_in;
                        if count = 7 then
                            R_W <= Data_in;
                            count <= 0;
                            current_state <= ACK1;
                        end if;
                    end if;
                -- First Acknowledge.
                when ACK1 =>
                	if clk'event and clk = '0' then
                        current_state <= INT_ADD;
                    end if;
                -- Internal Address.
                when INT_ADD =>
                	if clk'event and clk = '0' then
                    	count <= count + 1;
                        SDA_signal <= Data_in;
                        if count = 7 then
                        	count <= 0;
                            current_state <= ACK2;
                        end if;
                    end if;
                -- Second Acknowledge.
                when ACK2 =>
                    if clk'event and clk = '0' then
                        current_state <= DATA_RW;
                    end if;
                -- Data Read/Write
                when DATA_RW =>
                    if R_W = '0' then
                        if clk'event and clk = '0' then
                            -- Write.
                            SDA_signal <= data_in;
                            count <= count + 1;
                            if count = 7 then
                                count <= 0;
                                current_state <= Ack3;
                            end if; 
                        end if;
                    else
                        if clk'event and clk = '1' then
                            -- Read.
                            shift(7 downto 1) <= shift(6 downto 0);
                            shift(0) <= SDA;
                            count <= count + 1;
                            if count = 8 then
                                count <= 0;
                                current_state <= Ack3;
                            end if;
                        end if;
                    end if;
                -- Third Acknowledge.
                when ACK3 =>
                    if clk'event and clk = '1' then
                        current_state <= STP;
                    end if;
                -- Stop.
                when STP =>
                    if clk'event and clk = '0' then
                        SDA_signal <= '1';
                        if R_W = '1' then
                            Data_out <= shift;
                        end if;
                        current_state <= IDDLE;
                    end if;
            end case;
        end if;
    end process;

    clk <= '1' when current_state = IDDLE else clk_in;

    SCL <= clk;

end arch;