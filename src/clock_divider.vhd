library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_divider is
	generic(
		N : positive := 8; -- Number of bits to store the counter
		DIV : positive := 200 
	);
	port (
		CLK, RST : in std_logic; -- Clock and Reset needed
		O_CLK : inout std_logic -- output is feeded as an input, so inout!
	);
end clock_divider;

architecture Behavioral of clock_divider is
	signal cnt : unsigned(N-1 downto 0);
begin
	-- Sanity check, needed to avoid strange behavior
	assert ( 2**N > DIV) report "N needs to be bigger to store DIV";
	
	process (CLK, RST) 
	begin
		
	end process;
end architecture;
