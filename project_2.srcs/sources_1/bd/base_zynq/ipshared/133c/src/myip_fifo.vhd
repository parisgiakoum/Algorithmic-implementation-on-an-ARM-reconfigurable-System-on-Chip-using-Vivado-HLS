library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity myip_fifo is
	Generic (
		DATA_WIDTH  : integer := 32;
		FIFO_DEPTH	: integer := 64
	);
	Port ( 
	    -- Clock
		FIFO_ACLK		: in  STD_LOGIC;
		-- Reset
		FIFO_ARESETN	: in  STD_LOGIC;
		-- FIFO write enable
		WriteEn	: in  STD_LOGIC;
		-- Incoming FIFO Data from Slave
		DataIn	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		-- FIFO read enable
		ReadEn	: in  STD_LOGIC;
		-- Outgoing FIFO Data to Master
		DataOut	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		-- Signals an empty FIFO
		Empty	: out STD_LOGIC;
		-- Signals a full FIFO
		Full	: out STD_LOGIC
	);
end myip_fifo;

architecture Behavioral of myip_fifo is

begin

-- Based on the FIFO implementation found on http://www.deathbylogic.com/2013/07/vhdl-standard-fifo/

	-- Memory Pointer Process
	fifo_proc : process (FIFO_ACLK)
		-- FIFO's memory
		type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		variable Memory : FIFO_Memory;
		
		-- Variables showing head(write) and tail(read)
		variable Head : natural range 0 to FIFO_DEPTH - 1;
		variable Tail : natural range 0 to FIFO_DEPTH - 1;
		
		-- Variable showing if FIFO has already been scanned up to the top
		variable Looped : boolean;
		
	begin
		if rising_edge(FIFO_ACLK) then
	        -- Reset FIFO
			if FIFO_ARESETN = '0' then
				Head := 0;
				Tail := 0;
				
				Looped := false;
				
				Full  <= '0';
				Empty <= '1';
			else
			    -- Read functionality
				if (ReadEn = '1') then
				    -- FIFO is NOT empty when it's already scanned or head is in a different position than tail
					if ((Looped = true) or (Head /= Tail)) then
						-- Update data output
						DataOut <= Memory(Tail);
						
						-- Update Tail pointer (update to starting point if FIFO is scanned and on last positon)
						if (Tail = FIFO_DEPTH - 1) then
							Tail := 0;
							
							Looped := false;
						else
							Tail := Tail + 1;
						end if;
					end if;
				end if;
			    -- Write functionality
				if (WriteEn = '1') then
					-- FIFO is NOT full when it's already scanned or head is in a different position than tail
					if ((Looped = false) or (Head /= Tail)) then
						-- Write Data to Memory
						Memory(Head) := DataIn;
						
						-- Update Head pointer (update to starting point and set as Looped if FIFO is not scanned and is on last position)
						if (Head = FIFO_DEPTH - 1) then
							Head := 0;
							
							Looped := true;
						else
							Head := Head + 1;
						end if;
					end if;
				end if;
				
				-- FIFO is Empty or Full when Head = Tail depending on Looped
				if (Head = Tail) then
					if Looped then
						Full <= '1';
					else
						Empty <= '1';
					end if;
				else
					Empty	<= '0';
					Full	<= '0';
				end if;
			end if;
		end if;
	end process;
		
end Behavioral;