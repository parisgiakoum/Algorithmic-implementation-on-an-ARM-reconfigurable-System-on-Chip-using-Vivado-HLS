library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity myip_v1_1_tb is
end;

architecture bench of myip_v1_1_tb is

  component myip_v1_1
  	port (
  		m00_axis_aclk	: in std_logic;
  		m00_axis_aresetn	: in std_logic;
  		m00_axis_tvalid	: out std_logic;
  		m00_axis_tdata	: out std_logic_vector(31 downto 0);
  		m00_axis_tready	: in std_logic;
		m00_axis_tstrb	: out std_logic_vector(3 downto 0);
        m00_axis_tlast    : out std_logic;  		
  		
  	    s00_axis_tstrb	: in std_logic_vector(3 downto 0);
        s00_axis_tlast    : in std_logic;
  		s00_axis_aclk	: in std_logic;
  		s00_axis_aresetn	: in std_logic;
  		s00_axis_tready	: out std_logic;
  		s00_axis_tdata	: in std_logic_vector(31 downto 0);
  		s00_axis_tvalid	: in std_logic
  	);
  end component;

  signal m00_axis_aclk: std_logic;
  signal m00_axis_aresetn: std_logic;
  signal m00_axis_tvalid: std_logic;
  signal m00_axis_tdata: std_logic_vector(31 downto 0);
  signal m00_axis_tready: std_logic;
  signal m00_axis_tstrb	: std_logic_vector(3 downto 0);
  signal m00_axis_tlast    : std_logic;  
  signal s00_axis_tlast    : std_logic;
  signal s00_axis_tstrb	: std_logic_vector(3 downto 0);
  signal s00_axis_aclk: std_logic;
  signal s00_axis_aresetn: std_logic;
  signal s00_axis_tready: std_logic;
  signal s00_axis_tdata: std_logic_vector(31 downto 0);
  signal s00_axis_tvalid: std_logic ;

  constant Clk_period : time := 10 ns;

begin

  uut: myip_v1_1 port map ( m00_axis_aclk    => m00_axis_aclk,
                            m00_axis_aresetn => m00_axis_aresetn,
                            m00_axis_tvalid  => m00_axis_tvalid,
                            m00_axis_tdata   => m00_axis_tdata,
                            m00_axis_tready  => m00_axis_tready,
                            m00_axis_tstrb => m00_axis_tstrb,
                            m00_axis_tlast => m00_axis_tlast,
                            s00_axis_aclk    => s00_axis_aclk,
                            s00_axis_aresetn => s00_axis_aresetn,
                            s00_axis_tready  => s00_axis_tready,
                            s00_axis_tdata   => s00_axis_tdata,
                            s00_axis_tstrb => s00_axis_tstrb,
                            s00_axis_tlast => s00_axis_tlast,
                            s00_axis_tvalid  => s00_axis_tvalid );


   Clk_process :process
   begin
		m00_axis_aclk <= '0';
		s00_axis_aclk <= '0';
		wait for Clk_period/2;
		
		m00_axis_aclk <= '1';
		s00_axis_aclk <= '1';
		wait for Clk_period/2;
		
   end process;
   
  stimulus: process
  begin
  
    --Reset
    m00_axis_aresetn <= '0';
    s00_axis_aresetn <= '0';
    
    --Initialization of signals
    s00_axis_tvalid <= '0';
    s00_axis_tdata <= "00000000000000000000000000000000";
    m00_axis_tready <= '0';
    wait for 10 ns;
    
    --Active low Reset signal 
    m00_axis_aresetn <= '1';
    s00_axis_aresetn <= '1';
    wait for 10 ns;
	
	
    --Master is ready to get data from the fifo 
	--and send them to the slave of the DMAe
    m00_axis_tready <= '1';
	
	--Sending valid data to slave
	s00_axis_tvalid <= '1';
	
	--Write "1" to fifo
    s00_axis_tdata <= "00000000000000000000000000000001";
    wait for 10 ns;
	
	--Write "5" to fifo
    s00_axis_tdata <= "00000000000000000000000000000101";
    wait for 10 ns; 
    
	--Write "10" to fifo
    s00_axis_tdata <= "00000000000000000000000000001010";
    wait for 10 ns;
	
    --Master isn't ready to get data from fifo
    m00_axis_tready <= '0';
    wait for 10 ns;
 
	--Write 11" to fifo
    s00_axis_tdata <= "00000000000000000000000000001011";
    wait for 10 ns; 
	
    --Master is ready to get data from the fifo 
	--and send them to the slave of the DMAe
    m00_axis_tready <= '1';
	wait for 10ns;
    
	--Write "4" to fifo
    s00_axis_tdata <= "00000000000000000000000000000100";
    wait for 10 ns;
 
    --No more valid data to slave
    s00_axis_tvalid <= '0';
    
    --Try to send invalid data to slave 
    s00_axis_tdata <= "01010001001000010000100000100101";
    wait for 10 ns;
	
    --Master isn't ready to get data from fifo
    m00_axis_tready <= '0';
    wait for 30 ns;
       
    
	--Sending valid data to fifo and 
    --Write data to fifo until it's full (for 1000ns)
    s00_axis_tvalid <= '1';
    s00_axis_tdata <= "00000000000000000000000000000001";
    wait for 1000 ns;
    
	--Stop sendind valid data to fifo
    s00_axis_tvalid <= '0';
	
	--Read fifo until it's empty (Check full and empty flag)
    m00_axis_tready <= '1';
    
    wait;
  end process;


end;