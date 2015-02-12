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
	input1 : in signed (N-1 downto 0);
	input2 : in signed (N-1 downto 0);
	output : out signed (N-1 downto 0)
);
end phase_detector;

architecture Behavioral of phase_detector is
begin
process (clk, reset) 
		-- to store temporary result of multiplication between
		-- 2 numbers of N bit. 
		variable tmp : signed (2*N-1 downto 0);
		-- to store real output (only higher part)
		variable result: signed (N downto 0);
	begin
		if (RESET = '1') then 
			output <= (others => '0');
		elsif rising_edge (CLK) then	
			-- execute the multiplication
			tmp := input1 * input2;
			-- divide higher and lower part
			result := tmp(2*N-1 downto N-1) + to_signed(1, N+1);
			output <= result(N downto 1);
		end if;
	end process;
end;
