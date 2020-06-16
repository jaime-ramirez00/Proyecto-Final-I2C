<<<<<<< HEAD
-- Test Bench
library IEEE;
--library std;
use IEEE.std_logic_1164.all;
--use std.textio.all;
--use IEEE.std_logic_textio.all;
=======
-- Code your testbench here
library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

>>>>>>> dd6af4476c09975957565563a2ceac067cbb54cf

entity I2C_Controller_tb is
end entity;

architecture arch of I2C_Controller_tb is

	component I2C_Master is
<<<<<<< HEAD
      port(ENABLE   : in std_logic;
           SCL		: out std_logic;
           SDA	 	: inout std_logic;
           clk_in   : in std_logic;
=======
      port(SCL		: out std_logic;
           SDA	 	: inout std_logic;
>>>>>>> dd6af4476c09975957565563a2ceac067cbb54cf
           Data_in	: in std_logic;
           Reset	: in std_logic;
           Data_out	: out std_logic_vector(7 downto 0)
      );
    end component;
<<<<<<< HEAD
    
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
    	procedure send_data( sd : std_logic_vector(0 to 7) ) is
        begin
            for i in 0 to 7 loop
                wait for clk_period;
        		Data_in <= sd(i);
            end loop;
            wait for clk_period/2;
            Master_EN <= '0';
            Slave_EN <= '1';
        end procedure send_data;    
    begin
        wait for 0 ns;

        Reset <= '1';
        data_package <= "00000011";
        
        wait for clk_period/2;
        
        Reset <= '0';
        Master_EN <= '1';
        Slave_EN <= '0';
        send_data(data_package);
        data_package <= "00011011";
        ----------------------------
        wait for clk_period/2;
        Master_EN <= '1';
        Slave_EN <= '0';
        send_data(data_package);
        data_package <= "01011001";
        ----------------------------
        wait for clk_period/2;
        Master_EN <= '1';
        Slave_EN <= '0';
        send_data(data_package);
        
        wait for clk_period*10;
        
    end process;
    
end arch;
=======

    component I2C_Slave is
      port(SCL : in std_logic;
           SDA : inout std_logic;
           written_data : out std_logic_vector(7 downto 0)
      );
    end component;

    constant clk_period : time := 10 ns;

	   signal SCL			: std_logic := '1';
    signal SDA			: std_logic := '1';
    signal Data_in 		: std_logic;
    signal Reset		: std_logic := '0';
    signal Data_out		: std_logic_vector(7 downto 0);
    signal written_data	:std_logic_vector(7 downto 0);
    signal data_package : std_logic_vector(7 downto 0);

begin

	uut : I2C_Master port map(SCL, SDA, Data_in, Reset, Data_out);
    uut2: I2C_Slave port map(SCL, SDA, written_data);

    process
    	procedure send_data( sd : std_logic_vector(7 downto 0) ) is
        begin
        	for i in 7 to 0 loop
        		Data_in <= sd(i);
                wait for clk_period;
        	end loop;
        end procedure send_data;


    begin
    	Reset <= '1';

        wait for clk_period;

        SDA <= '0';
        RESET <= '0';
        data_package <= "00000000";

        wait for clk_period/2;

        send_data(data_package);
        data_package <= "00011011";

        wait for clk_period;

        send_data(data_package);
        data_package <= "01011001";

        wait for clk_period;

        send_data(data_package);

        wait for clk_period*10;

    end process;

end arch;
>>>>>>> dd6af4476c09975957565563a2ceac067cbb54cf
