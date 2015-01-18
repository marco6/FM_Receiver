library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity phase_detector is
generic ( 
	N : positive := 12 
);
port ( 
	clk    : in std_logic ;
	reset  : in std_logic ;
	input1 : in signed (n-1 downto 0);
	input2 : in signed (n-1 downto 0);
	output : out signed (n-1 downto 0)
);
end phase_detector;

architecture Behavioral of phase_detector is
begin
-- empty
end;
