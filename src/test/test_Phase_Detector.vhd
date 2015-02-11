--ThestBench of Phase Detector 

LIBRARY ieee;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.textio.all;

entity test_Phase_Detector is
end test_Phase_Detector;


-- this is pratically a copy & paste of the shape filter test...
-- Still working :D

architecture Behavioral of test_Phase_Detector is


constant N : positive := 4;

component phase_detector is 
	generic ( 
	N : positive := 4 
);
port ( 
	clk    : in std_logic ;
	reset  : in std_logic ;
	input1 : in signed (N-1 downto 0);
	input2 : in signed (N-1 downto 0);
	output : out signed (N-1 downto 0)
);
end component;


	-- Basic signals. Stop is needed to avoid infinite looping
	signal clock,  STOP : std_logic := '0';
	signal reset : std_logic := '1'; -- Start by resetting everything
	
	signal x1 : signed (N-1 downto 0) := "0001";
	signal x2 : signed (N-1 downto 0) := "0011";
	
	constant clk_cycle : time := 1 us;
begin
	
dut: phase_detector 
	generic map ( N => N )
	port map ( 
		clk => clock, 
		reset => reset, 
		input1 => x1,
		input2 => x2  
	);
	
	-- Stop resetting after the first clock cycle
	reset <= '0' after clk_cycle;
	STOP <= '1' after clk_cycle*1000;
	-- This process generates the clock
	
CLOCK_PROCESS:	
	process
	begin
		if(STOP='0') then
			clock <= not clock;
			wait for (clk_cycle / 2);
		else
			wait;
		end if;
	end process;
	
	-- This process sets the input on the falling edge of the clock so that
	-- on the rising edge everything is set and ready to be processed
	-- and collected by the check system
STIMULUS:
	process (clock)
		--variable ln : line;
		--variable int_in : integer;
	begin
		-- Input wave comes from a file, generated with Matlab, that 
		-- represent the function
		-- X = sin(50 PI t) + 0.5 sin(2 pi 30000 t)
		-- with some additional noise (gaussian)
		-- The format is one value per line
		if(reset = '0' and clock = '0' and clock'event ) then			
				--codice test 
				x1 <= x1 +1 after 200 ns;
				x2 <= x2 +1 after 200 ns;
		end if;
		
		-- No need for any loop... VHDL will take care!! Handy!
	end process;
end Behavioral;
