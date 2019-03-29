library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myip_v1_1 is
	generic (
		-- Users to add parameters here
		
		-- FIFO Data Width
        C_F00_DATA_WIDTH : integer := 32;
        -- FIFO Depth
        C_F00_FIFO_DEPTH : integer := 64;
		-- User parameters ends
		
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32;
		

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here

		-- User ports ends
		
		-- Do not modify the ports beyond this line


		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	 : in std_logic;
		m00_axis_aresetn : in std_logic;
		m00_axis_tvalid	 : out std_logic;
		m00_axis_tdata	 : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	 : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	 : out std_logic;
		m00_axis_tready	 : in std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	 : in std_logic;
		s00_axis_aresetn : in std_logic;
		s00_axis_tready	 : out std_logic;
		s00_axis_tdata	 : in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	 : in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	 : in std_logic;
		s00_axis_tvalid	 : in std_logic
	);
end myip_v1_1;

architecture arch_imp of myip_v1_1 is

	-- component declaration
	component myip_v1_1_M00_AXIS is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic;
		M_AXIS_FIFO_DATA: in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
        M_AXIS_FIFO_EMPTY : in std_logic;
        M_AXIS_READ_EN: out std_logic
		);
	end component myip_v1_1_M00_AXIS;

	component myip_v1_1_S00_AXIS is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic;
		S_AXIS_FIFO_FULL : in std_logic;
        S_AXIS_WRITE_EN: out std_logic
		);
	end component myip_v1_1_S00_AXIS;

-- Component Declaration for the Unit Under Test (UUT)
	component myip_fifo is
		Generic (
            DATA_WIDTH  : integer := 32;
            FIFO_DEPTH    : integer := 64
       );
		port (
                FIFO_ACLK		: in  STD_LOGIC;
                FIFO_ARESETN        : in  STD_LOGIC;
                WriteEn    : in  STD_LOGIC;
                DataIn    : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
                ReadEn    : in  STD_LOGIC;
                DataOut    : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
                Empty    : out STD_LOGIC;
                Full    : out STD_LOGIC
		);
	end component myip_fifo;
	
	-- signal declaration
	signal fifo_full, fifo_empty, fifo_read_en, fifo_write_en : STD_LOGIC;
	signal fifo_data_out: STD_LOGIC_VECTOR (C_M00_AXIS_TDATA_WIDTH - 1 downto 0);
	
begin

-- Instantiation of Axi Bus Interface M00_AXIS
myip_v1_1_M00_AXIS_inst : myip_v1_1_M00_AXIS
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH
		--C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
	)
	port map (
		M_AXIS_ACLK	=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY	=> m00_axis_tready,
		M_AXIS_FIFO_EMPTY => fifo_empty,
		M_AXIS_READ_EN => fifo_read_en,
		M_AXIS_FIFO_DATA => fifo_data_out
	);

-- Instantiation of Axi Bus Interface S00_AXIS
myip_v1_1_S00_AXIS_inst : myip_v1_1_S00_AXIS
	generic map (
		C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
	)
	port map (
		S_AXIS_ACLK	=> s00_axis_aclk,
		S_AXIS_ARESETN	=> s00_axis_aresetn,
		S_AXIS_TREADY	=> s00_axis_tready,
		S_AXIS_TDATA	=> s00_axis_tdata,
		S_AXIS_TSTRB	=> s00_axis_tstrb,
		S_AXIS_TLAST	=> s00_axis_tlast,
		S_AXIS_TVALID	=> s00_axis_tvalid,
		S_AXIS_FIFO_FULL => fifo_full,
		S_AXIS_WRITE_EN => fifo_write_en
	);

	-- Add user logic here
myip_v1_1_fifo_inst : myip_fifo
        generic map (
            DATA_WIDTH    => C_F00_DATA_WIDTH,
            FIFO_DEPTH    => C_F00_FIFO_DEPTH
        )
        port map (
            FIFO_ACLK    => m00_axis_aclk,
            FIFO_ARESETN    => m00_axis_aresetn,
            DataIn    => s00_axis_tdata,
            WriteEn    => fifo_write_en,
            ReadEn    => fifo_read_en,
            DataOut    => fifo_data_out,
            Full    => fifo_full,
            Empty => fifo_empty
        );
        
	-- User logic ends

end arch_imp;
