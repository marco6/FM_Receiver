library IEEE;

use IEEE.std_logic_1164.all;
-- I use numeric_std because it's standard and it is syntetizable!!!
use IEEE.numeric_std.all;

library work;
use work.Helpers.all;

-- Right now this is a really special-pupose filter
-- If I have time, I will probably make it not-so 
-- 
-- The filter I'm trying to implement is
-- 
-- b = [1 0.74466345359135877 1]; % * 0.0030225961666631449
-- a = [1 -1.89 0.9]; %[1 -1.8925335793406506  0.90184185479781553];
entity ShapeFilter is
generic ( N : positive := 12 );
port (
	CLK, RST : in std_logic;
	X : in signed( N-1 downto 0);
	Y : inout signed( N-1 downto 0)
);
end ShapeFilter;


architecture AsyncReset_Beh of ShapeFilter is
	-- I will use 2 bit to store integral digits... The others are fractional!
	-- I do this because one of the filter weights is > 1, so I can't use
	-- all the digits to store the fractional part! Besides, I need an additional
	-- bit to "store the sign" (not actually true, because of 2 complement
	-- complexity, but easy to understand this way!)
	
	-- So I define first the scale factor used in the notation!
	-- (input is assumed integral, without any fractional part)
	constant Np2 : real := (2.0 ** (N-2));
	
	-- Than I multiply for "1" the real number to get it transformed in my notation.
	-- Still, I have to make an additional step to get my costants:
	-- I need to transform the real number I geto to an integer and then
	-- I can transform the integer to signed.
	-- This should be syntetizable because I only use constants!
	-- (I hope the syntetizer is clever enough to do this)
	constant a2 : signed(N-1 downto 0) := to_signed(integer((-1.8925335793406506) * Np2), N);
	constant a3 : signed(N-1 downto 0) := to_signed(integer(0.90184185479781553 * Np2), N);
	constant b1 : signed(N-1 downto 0) := to_signed(integer(Np2), N);
	constant b2 : signed(N-1 downto 0) := to_signed(integer(0.74466345359135877 * Np2), N);
	constant b3 : signed(N-1 downto 0) := to_signed(integer(Np2), N);
		
	-- Now I need to store some results...
	signal x1, x2, y1, y2 : signed(N-1 downto 0) := (others => '0');
begin
	-- Now, this filter is pure behavioral...
	-- I'm probably going to need something better
	process (CLK, RST)
		variable tmp : signed(2*N-1 downto 0) := (others => '0');
	begin
		-- Async reset
		if (RST = '1') then
			-- On reset everything should go to zero, both memory...
			x1 <= (others => '0');
			x2 <= (others => '0');
			y1 <= (others => '0');
			y2 <= (others => '0');
			-- ...and output!
			Y <= (others => '0');
		elsif (CLK = '1' AND CLK'event) then
			-- now.. I compute first the non recursive part of the filter
			tmp := x * B1 + x1 * B2 + x2 * B3;
			-- and than I immediatly apply the gain to avoid that
			-- y registers grow too high!
			
			-- The gain is 0.00301... ~= 3/1000 ~= 4/1024 ~= 1/256
			tmp := sar(tmp, 8); 
			-- Now I add the regursive part!
			tmp := tmp - y * A2 - y1 * A3;
			-- And I remove the decimal part
			tmp := sar(tmp, N-2);
			y1 <= y;
			y <= tmp(N-1 downto 0);
			x2 <= x1;
			x1 <= x;
		end if;
	end process;
end architecture;
