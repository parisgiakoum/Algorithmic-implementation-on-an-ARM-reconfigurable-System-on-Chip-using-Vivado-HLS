LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY myip_v1_1_fifo_tb IS
END myip_v1_1_fifo_tb;

ARCHITECTURE behavior OF myip_v1_1_fifo_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
	component myip_fifo
		port (
			FIFO_ACLK		: in std_logic;
			FIFO_ARESETN		: in std_logic;
			DataIn	: in std_logic_vector(31 downto 0);
			WriteEn	: in std_logic;
			ReadEn	: in std_logic;
			DataOut	: out std_logic_vector(31 downto 0);
			Full	: out std_logic;
			Empty	: out std_logic
		);
	end component;
	
	--Inputs
	signal FIFO_ACLK		: std_logic := '0';
	signal FIFO_ARESETN		: std_logic := '0';
	signal DataIn	: std_logic_vector(31 downto 0) := (others => '0');
	signal ReadEn	: std_logic := '0';
	signal WriteEn	: std_logic := '0';
	
	--Outputs
	signal DataOut	: std_logic_vector(31 downto 0);
	signal Empty	: std_logic;
	signal Full		: std_logic;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: myip_fifo
		PORT MAP (
			FIFO_ACLK => FIFO_ACLK,
			FIFO_ARESETN => FIFO_ARESETN,
			DataIn	=> DataIn,
			WriteEn	=> WriteEn,
			ReadEn	=> ReadEn,
			DataOut	=> DataOut,
			Full	=> Full,
			Empty	=> Empty
		);
	
	-- Clock process definitions
	CLK_process :process
	begin
		FIFO_ACLK <= '0';
		wait for CLK_period/2;
		FIFO_ACLK <= '1';
		wait for CLK_period/2;
	end process;
	
	-- Reset process
	rst_proc : process
	begin
	wait for CLK_period * 5;
		
		FIFO_ARESETN <= '0';
		
		wait for CLK_period * 5;
		
		FIFO_ARESETN <= '1';
		
		wait;
	end process;
	
	-- Write process
	wr_proc : process
		variable counter : unsigned (31 downto 0) := (others => '0');
	begin		
		wait for CLK_period * 20;

		for i in 1 to 64 loop
			counter := counter + 1;
			
			DataIn <= std_logic_vector(counter);
			
			wait for CLK_period * 1;
			
			WriteEn <= '1';
			
			wait for CLK_period * 1;
		
			WriteEn <= '0';
		end loop;
		
		wait for clk_period * 20;
		
		for i in 1 to 32 loop
			counter := counter + 1;
			
			DataIn <= std_logic_vector(counter);
			
			wait for CLK_period * 1;
			
			WriteEn <= '1';
			
			wait for CLK_period * 1;
			
			WriteEn <= '0';
		end loop;
		
		wait;
	end process;
	
	-- Read process
	rd_proc : process
	begin
		wait for CLK_period * 20;
		
		wait for CLK_period * 40;
		
		-- full stack
		wait for CLK_period * 90;
			
		ReadEn <= '1';
		
		wait for CLK_period * 60;
		
		ReadEn <= '0';
		
		wait for CLK_period * 64 * 2;
		
		ReadEn <= '1';
		
		wait;
	end process;

END;