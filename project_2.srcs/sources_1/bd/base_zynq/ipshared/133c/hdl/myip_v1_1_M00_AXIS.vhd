library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myip_v1_1_M00_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		
		-- Data received from FIFO
        M_AXIS_FIFO_DATA: in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- Signal from empty fifo to master
        M_AXIS_FIFO_EMPTY : in std_logic;
        -- Master signals fifo to read
        M_AXIS_READ_EN: out std_logic;
        
		-- User ports ends
		
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end myip_v1_1_M00_AXIS;

architecture implementation of myip_v1_1_M00_AXIS is

	-- AXI Stream internal signals
	--streaming data valid
	signal axis_tvalid	: std_logic;
	--streaming data valid delayed by one clock cycle
	signal axis_tvalid_delay	: std_logic;
	--Last of the streaming data 
--	signal axis_tlast	: std_logic;
	--Last of the streaming data delayed by one clock cycle
--	signal axis_tlast_delay	: std_logic;
    -- fifo readEn signal
	signal fifo_read_en : std_logic;

begin
	-- I/O Connections assignments

	M_AXIS_TVALID	<= axis_tvalid_delay;
	M_AXIS_TDATA	<= M_AXIS_FIFO_DATA;
	M_AXIS_TSTRB	<= (others => '1');
    M_AXIS_READ_EN <= fifo_read_en;                                                                         


	-- Add user logic here
	
	-- We read data from FIFO when Master signals tready and tvalid
	fifo_read_en <= M_AXIS_TREADY and axis_tvalid;                                

	-- Master signals tvalid when FIFO is NOT empty
    axis_tvalid <= '1' when ((M_AXIS_FIFO_EMPTY = '0')) else '0';              
	                                                                                               
	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	-- to match the latency of M_AXIS_TDATA                                                
	process(M_AXIS_ACLK)                                                                           
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
	      axis_tvalid_delay <= '0';                                                                                                                         
	    else                                                                                       
	      axis_tvalid_delay <= axis_tvalid;                                                           
	    end if;                                                                                    
	  end if;                                                                                      
	end process;                                                                                   
                                                        
	-- User logic ends

end implementation;
