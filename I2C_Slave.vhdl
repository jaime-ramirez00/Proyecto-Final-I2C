--SLAVE ENTITY
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity I2C_Slave is
	port(ENABLE : in std_logic;
		 SCL 	: in std_logic;
		 SDA 	: inout std_logic := 'Z';
		 written_data : out std_logic_vector(7 downto 0)
    );
end entity;

architecture arch of I2C_Slave is
	-- Slave Address.
	constant slave_address: std_logic_vector(6 downto 0):="0000001";

	-- Slave internal memory.
    type RAM_type is array (0 to 255) of std_logic_vector(7 downto 0);
	signal RAM : RAM_type := (others => "00000000");

	-- State.
    type state is (IDDLE, SLAVE_ADD, ACK1, INT_ADD, ACK2, DATA_RW, ACK3, STP);
	signal current_state   : state := IDDLE;

	-- Signals.
	signal count 		   : integer range 0 to 12 := 0;
	signal address_compare : std_logic_vector(6 downto 0);
	signal R_W			   : std_logic;
	signal RAM_index 	   : std_logic_vector(7 downto 0);
	signal SDA_signal	   : std_logic;
begin

	SDA <= SDA_signal when ENABLE = '1' else 'Z';

	process(SCL, SDA)
		variable index : integer := 0;
	begin
		case current_state is
		-- IDDLE.
		when IDDLE =>
			if SCL = '1' and SDA = '0' and SDA'event then
				current_state <= SLAVE_ADD;
			end if;
		-- Slave Address.
		when SLAVE_ADD =>
			if SCL'event and SCL = '1' then
				if count < 7 then
					count <= count + 1;
					address_compare(6 downto 1) <= address_compare(5 downto 0);
					address_compare(0) <= SDA;
				elsif count = 7 then
					count <= count + 1;
					R_W <= SDA;
					count <= 0;
					current_state <= ACK1;
				end if;
			end if;
		-- First Acknowledge.
		when ACK1 =>
			if SCL'event and SCL = '0' then
				SDA_signal <= '0';
			elsif SCL'event and SCL = '1' then
				current_state <= INT_ADD;
			end if;
		-- Internal Address.
		when INT_ADD =>
			if SCL'event and SCL = '1' then
				count <= count + 1;
				RAM_index(7 downto 1) <= RAM_index(6 downto 0);
				RAM_index(0) <= SDA;
				if count = 7 then
					count <= 0;
					current_state <= ACK2;
				end if;
			end if;
		-- Second Acknowledge.
		when ACK2 =>
			SDA_signal <= '0';
			if SCL'event and SCL = '1' then
				current_state <= DATA_RW;
			end if;
			index := 7;
		-- Data Read/Write.
		when DATA_RW =>
			if R_W = '0' then
				if SCL'event and SCL = '1' then
					-- Reading SDA.
					count <= count + 1;
					RAM(TO_INTEGER(UNSIGNED(RAM_index)))(7 downto 1) <= RAM(TO_INTEGER(UNSIGNED(RAM_index)))(6 downto 0);
					RAM(TO_INTEGER(UNSIGNED(RAM_index)))(0) <= SDA;
					if count = 7 then
						count <= 0;
						current_state <= Ack3;
					end if;
				end if;
			else
				if SCL'event and SCL = '0' then
					-- Controlling SDA.
					count <= count + 1;
					SDA_signal <= RAM(TO_INTEGER(UNSIGNED(RAM_index)))(index);
					index := index - 1;
					if count = 7 then
						count <= 0;
						current_state <= Ack3;
					end if;
				end if;
			end if;
		-- Third Acknowledge.
		when ACK3 =>
			if SCL'event and SCL = '1' then
				SDA_signal <= '0';
				written_data <= RAM(TO_INTEGER(UNSIGNED(RAM_index)));
				current_state <= IDDLE;
			end if;
		-- Stop.
		when STP =>
			
        end case;
    end process;

end arch;