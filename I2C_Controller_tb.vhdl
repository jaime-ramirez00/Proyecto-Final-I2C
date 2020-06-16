-- Test Bench
library IEEE;
library std;
use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity I2C_Controller_tb is
end entity;

architecture arch of I2C_Controller_tb is

	component I2C_Master is
      port(ENABLE   : in std_logic;
           SCL		: out std_logic;
           SDA	 	: inout std_logic;
           clk_in   : in std_logic;
           Data_in	: in std_logic;
           Reset	: in std_logic;
           Data_out	: out std_logic_vector(7 downto 0)
      );
    end component;
    
    component I2C_Slave is
      port(ENABLE       : in std_logic;
           SCL          : in std_logic;
           SDA          : inout std_logic;
           written_data : out std_logic_vector(7 downto 0)
      );
    end component;
    
    constant clk_period : time := 10 ns;

    signal Master_EN    : std_logic := '1';
    signal Slave_EN     : std_logic := '0';
	signal SCL			: std_logic := '1';
    signal SDA			: std_logic := 'Z';
    signal clk_in       : std_logic := '0';
    signal Data_in 		: std_logic := '0';
    signal Reset		: std_logic := '0';
    signal Data_out		: std_logic_vector(7 downto 0);
    signal written_data	:std_logic_vector(7 downto 0);
    signal data_package : std_logic_vector(0 to 7);

begin

	uut : I2C_Master port map(Master_EN, SCL, SDA, clk_in, Data_in, Reset, Data_out);
    uut2: I2C_Slave port map(Slave_EN, SCL, SDA, written_data);
    
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    process
        -- Variables for file reading.
        file fin : TEXT open READ_MODE is "input.txt";
        variable curr_line : line;
        variable vDATA1, vDATA2, vDATA3 : std_logic_vector(7 downto 0);

    	procedure send_data( sd : std_logic_vector(0 to 7) ) is
        begin
            for i in 0 to 7 loop
                Data_in <= sd(i);
                wait for clk_period;
                if i = 7 then
                    Master_EN <= '0';
                    Slave_EN <= '1';
                end if;
            end loop ;
        end procedure send_data;    
    begin
        wait for 0 ns;

        Data_in <= '1';
        Reset <= '1';
        
        readline(fin, curr_line);
        read(curr_line, vDATA1);
		read(curr_line, vDATA2);
		read(curr_line, vDATA3);

        data_package <= vDATA1;

        wait for clk_period;

        data_in <= '0';        
        Reset <= '0';
        Master_EN <= '1';
        Slave_EN <= '0';
        send_data(data_package);
        data_package <= vDATA2;
        ----------------------------
        wait for clk_period;
        Master_EN <= '1';
        Slave_EN <= '0';
        send_data(data_package);
        data_package <= vDATA3;

        ----------------------------
        wait for clk_period;
        Master_EN <= '1';
        Slave_EN <= '0';
        send_data(data_package);
        Master_EN <= '1';
        Slave_EN <= '0';
        
        wait for clk_period*10;

-------------------------------------------------

        Data_in <= '1';
        Reset <= '1';

        readline(fin, curr_line);
        read(curr_line, vDATA1);
		read(curr_line, vDATA2);
        read(curr_line, vDATA3);
        
        data_package <= vDATA1;
        
        wait for clk_period;

        data_in <= '0';        
        Reset <= '0';
        send_data(data_package);
        data_package <= vDATA2;
        ----------------------------
        wait for clk_period;
        Master_EN <= '1';
        Slave_EN <= '0';
        send_data(data_package);
        data_package <= vDATA3;

        ----------------------------
        wait for clk_period;
        Master_EN <= '0';
        Slave_EN <= '1';
        send_data(data_package);

        wait for clk_period;
        Master_EN <= '1';
        Slave_EN <= '0';
        
        wait for clk_period*10;
        
    end process;
    
end arch;