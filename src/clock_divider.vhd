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
		O_CLK : out std_logic := '0'-- output is feeded as an input, so inout!
	);
end clock_divider;

architecture Behavioral of clock_divider is
	-- this holds my value
	signal cnt : unsigned(N-1 downto 0);
	--compute limit
	constant limit : unsigned(N-1 downto 0) := to_unsigned( (DIV-1) / 2, N);
begin
	-- Sanity check, needed to avoid strange behavior
	assert ( 2**(N+1) > DIV) report "N needs to be bigger to store DIV!! Increase N.";
	
	-- This process does the job!
	process (CLK, RST)
		variable INTERNAL_CLOCK : std_logic := '0';
	begin
		-- async reset for speed
		if(RST = '1') then
			cnt <= (others => '0');
			INTERNAL_CLOCK := '0';
		-- on rising edge 
		elsif (rising_edge(CLK)) then
			-- First I count up to DIV-1 if i didn't reach it yet
			if (cnt /= limit) then
				cnt <= cnt + to_unsigned(1, N); -- seems expensive, but in VHDL
												-- functions are solved to constants, 
												-- so... everything seems fine!
			else
				-- Hard reset 
				cnt <= (others => '0');
				-- And a nice change in the output clock
				INTERNAL_CLOCK := not INTERNAL_CLOCK;
			end if;
		end if;
		O_CLK <= INTERNAL_CLOCK;
	end process;
end architecture;
