library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clk_div_test is
end entity;


architecture Behavioral of clk_div_test is

	-- The component to be tested
	component clock_divider is
		generic(
			N : positive := 8;
			DIV : positive := 200 
		);
		port (
			CLK, RST : in std_logic;
			O_CLK : inout std_logic := '0'
		);
	end component;
	
	-- Basic signals. Stop is needed to avoid infinite looping
	signal clock,  STOP : std_logic := '0';
	signal reset : std_logic := '1'; -- Start by resetting everything
	
	-- Since this is a test, this could be anything.
	-- Still the real clock period needs to be 1 us, because we need to
	-- Process samples @ 1 Mhz! So...
	constant clk_cycle : time := 1 us;
begin
	-- Instantiation... N is set to 12 since XADC is capable of that bit depth.
cd_test_default: clock_divider
	port map ( 
		CLK => clock, 
		RST => reset, 
		O_CLK => open
	);

cd_test_8: clock_divider
	generic map(N => 3, DIV => 8)
	port map ( 
		CLK => clock, 
		RST => reset, 
		O_CLK => open
	);

cd_test_14: clock_divider
	generic map(N => 3, DIV => 14)
	port map ( 
		CLK => clock, 
		RST => reset, 
		O_CLK => open
	);	

cd_test_40: clock_divider
	generic map(N => 5, DIV => 40)
	port map ( 
		CLK => clock, 
		RST => reset, 
		O_CLK => open
	);
	
	-- Stop resetting after the first clock cycle
	reset <= '0' after clk_cycle;
	STOP <= '1' after clk_cycle * 1000; -- stop after testing for a while!

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
end Behavioral;