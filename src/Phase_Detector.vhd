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
	
	-- to store temporary result of multiplication between
	-- 2 numbers of N bit. 
	signal tmp : signed (2*(N-1) downto 0);
	-- to store real output (only higher part)
	signal result: signed (N-1 downto 0);
	-- used to approximate the output(lower part)
	signal ctrl: signed (N-2 downto 0);
	
begin
	process (clk, reset) 
	begin
		if (RESET = '1') then 
			output <= (others => '0');
		elsif rising_edge (CLK) then	
			-- execute the multiplication
			tmp <= input1 * input2;
			-- divide higher and lower part
			result <= tmp(2*(N-1) downto N-1);
			ctrl <= tmp(N-2 downto 0);
			if (result(2*(N-1)) = '1') then
				-- negative result
				if (ctrl(N-2) = '0') then
					result <= result - 1;
					-- to avoid overflow
					if (result(N-1) = '0') then
						result <= result + 1;
					end if;
				end if;
			else
				-- if we are here result is positive
				if (ctrl(N-2) = '1') then
					result <= result + 1;
					-- to avoid overflow
					if (result(N-1) = '1') then
						result <= result - 1;
					end if;
				end if;
			end if;
			output <= result;
		end if;
	end process;
end;
