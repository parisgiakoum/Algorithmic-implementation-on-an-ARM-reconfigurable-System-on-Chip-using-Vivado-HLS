library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myip_v1_1_S00_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		
		-- Signal from full fifo
        S_AXIS_FIFO_FULL : in std_logic;
        -- Signals fifo to write
        S_AXIS_WRITE_EN: out std_logic;
		-- User ports ends
		
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end myip_v1_1_S00_AXIS;

architecture arch_imp of myip_v1_1_S00_AXIS is

	signal axis_tready	: std_logic;
	
	-- FIFO write enable
	signal fifo_wren : std_logic;
	
begin
	-- I/O Connections assignments

	S_AXIS_TREADY	<= axis_tready;
	S_AXIS_WRITE_EN <= fifo_wren;
	
	-- Add user logic here
	
	-- Slave signals tready when FIFO is NOT full
	axis_tready <= '1' when (S_AXIS_FIFO_FULL = '0') else '0';
	-- Slave writes to FIFO if tready and tvalid are enabled
	fifo_wren <= axis_tready and S_AXIS_TVALID;

	-- User logic ends

end arch_imp;
