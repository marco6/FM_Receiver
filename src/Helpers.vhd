library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Helpers is
	-- Arithmetic right shift - I don't know why this isn't in the 
	-- standard lyibrary yet!
	-- As input this function takes a signed number (other data type
	-- wouldn't really need SAR function) and a strictly positive count.
	function SAR (LEFT: SIGNED; COUNT: POSITIVE ) return SIGNED;
end Helpers;

package body Helpers is

	function SAR (LEFT: SIGNED; COUNT: POSITIVE) return SIGNED is
		variable RES : SIGNED(LEFT'LENGTH -1 downto 0);
	begin
		-- I just fill the leftmost part with the leftmost bit
		RES(LEFT'LENGTH -1 downto LEFT'LENGTH - COUNT) := (others => LEFT(LEFT'LENGTH -1));
		-- The rest is the same as the input
		RES(LEFT'LENGTH - 1 - COUNT downto 0) := LEFT(LEFT'LENGTH-1 downto COUNT);
		return RES;
	end SAR;
	
end Helpers;
