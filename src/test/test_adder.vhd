--ThestBench of adder 

LIBRARY ieee;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.textio.all;

entity test_adder is
end test_adder;


-- this is pratically a copy & paste of the shape filter test...
-- Still working :D

architecture Behavioral of test_adder is

	-- Input file, generated with matlab that contains
	-- a low freq sinusoid and a hi freq one! There is also some 
	-- Gaussian noise...
	
	--file f_in : TEXT open read_mode is "src/test/Filter_in.dat";
	
	-- The component to be tested
component adder is 
	generic ( N : positive := 12 
  			 );
	port (CLK : in std_logic;
		  RESET : in std_logic;
		  df : in std_logic;         --input signal which determines the "sign" of the sum
		  F : inout signed (N-1 downto 0)
		  );
end component;


	-- Basic signals. Stop is needed to avoid infinite looping
	signal clock,  STOP : std_logic := '0';
	signal reset : std_logic := '1'; -- Start by resetting everything
	-- I/O redirect
	signal x_in : std_logic := '1';
	
	-- Since this is a test, this could be anything.
	-- Still the real clock period needs to be 1 us, because we need to
	-- Process samples @ 1 Mhz! So...
	constant clk_cycle : time := 1 us;
begin
	-- Instantiation... N is set to 12 since XADC is capable of that bit depth.
a_test: adder 
	generic map ( N => 12 )
	port map ( 
		CLK => clock, 
		RESET => reset, 
		df => x_in, 
		F => open -- I leave this open... I will still see the output 
				  -- in a good simulator
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
				x_in <= not x_in;
		end if;
		
		-- No need for any loop... VHDL will take care!! Handy!
	end process;
end Behavioral;