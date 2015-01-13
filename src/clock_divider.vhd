library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_divider is
	generic( DIV : positive := 200 );
	port (
		CLK : in std_logic;
		O_CLK : inout std_logic
	);
end clock_divider;

architecture Behavioral of clock_divider is
	signal cnt : unsigned(
begin
	
end architecture;
