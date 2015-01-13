library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.Helpers.all;

entity ShapeFilter is
generic ( N : positive := 12 );
port (
	CLK, RST : in std_logic;
	X : in signed( N-1 downto 0);
	Y : inout signed( N-1 downto 0)
);
end ShapeFilter;

--Transfer function coefficients of the filter, calculated whit matlab butter function;
-- b =

--      0.0002         0   -0.0011         0    0.0023         0   -0.0023         0    0.0011         0   -0.0002


-- a =

--      1.0000   -9.8478   43.6417 -114.6123  197.5338 -233.4568  191.6109 -107.8422   39.8326   -8.7188    0.8588



architecture AsyncReset_Beh of ShapeFilter is
	
	constant Np2 : real := (2.0 ** (N-2));
	
	
	
	constant a1 : signed(N-1 downto 0) := to_signed(integer((1.000) * Np2), N);
	constant a2 : signed(N-1 downto 0) := to_signed(integer((-9.8478) * Np2), N);
	constant a3 : signed(N-1 downto 0) := to_signed(integer((43.6417) * Np2), N);
	constant a4 : signed(N-1 downto 0) := to_signed(integer((-114.6123) * Np2), N);
	constant a5 : signed(N-1 downto 0) := to_signed(integer((197.5338) * Np2), N);
	constant a6 : signed(N-1 downto 0) := to_signed(integer((-233.4568) * Np2), N);
	constant a7 : signed(N-1 downto 0) := to_signed(integer(191.6109 * Np2), N);
	constant a8 : signed(N-1 downto 0) := to_signed(integer((-107.8422) * Np2), N);
	constant a9 : signed(N-1 downto 0) := to_signed(integer((39.8326) * Np2), N);
	constant a10 : signed(N-1 downto 0) := to_signed(integer((-8.7188) * Np2), N);
	constant a11 : signed(N-1 downto 0) := to_signed(integer((0.8588) * Np2), N);
	
	
	constant b1 : signed(N-1 downto 0) := to_signed(integer(0.0002 * Np2), N);
	constant b2 : signed(N-1 downto 0) := to_signed(integer(0.0 * Np2), N);
	constant b3 : signed(N-1 downto 0) := to_signed(integer((-0.0011) * Np2), N);
	constant b4 : signed(N-1 downto 0) := to_signed(integer(0.0 * Np2), N);
	constant b5 : signed(N-1 downto 0) := to_signed(integer(0.0023 * Np2), N);
	constant b6 : signed(N-1 downto 0) := to_signed(integer(0.0*Np2), N);
	constant b7 : signed(N-1 downto 0) := to_signed(integer((-0.0023) * Np2), N);
	constant b8 : signed(N-1 downto 0) := to_signed(integer(0.0*Np2), N);
	constant b9 : signed(N-1 downto 0) := to_signed(integer(0.0011*Np2), N);
	constant b10 : signed(N-1 downto 0) := to_signed(integer(0.0*Np2), N);
	constant b11 : signed(N-1 downto 0) := to_signed(integer((-0.0002)*Np2), N);
		
	-- temporary variable
	signal x1, x2, x3,x4,x5,x6,x7,x8,x9,x10,y1, y2, y3,y4,y5,y6,y7,y8,y9,y10 : signed(N-1 downto 0) := (others => '0');
begin
	--
	process (CLK, RST)
		variable tmp : signed(3*N-1 downto 0) := (others => '0'); --sized for ensure to not overflow
	begin
		-- Async reset
		if (RST = '1') then
			-- On reset everything should go to zero
			x1 <= (others => '0');
			x2 <= (others => '0');
			x3 <= (others => '0');
			x4 <= (others => '0');
			x5 <= (others => '0');
			x6 <= (others => '0');
			x7 <= (others => '0');
			x8 <= (others => '0');
			x9 <= (others => '0');
			x10 <= (others => '0');
			y1 <= (others => '0');
			y2 <= (others => '0');
			y3 <= (others => '0');
			y4 <= (others => '0');
			y5 <= (others => '0');
			y6 <= (others => '0');
			y7 <= (others => '0');
			y8 <= (others => '0');
			y9 <= (others => '0');
			y10 <= (others => '0');
			
			Y <= (others => '0');
			
			
		elsif (CLK = '1' AND CLK'event) then
			-- now.. I compute first the non recursive part of the filter
			tmp := x * b1 + x1 * b2 + x2 * b3 + x3 * b4 + x4 * b5 + x5 * b6 + x6 * b7 + x7 * b8 + x8 * b9 +x9 * b10 + x10 * b11 ;
			-- and than I immediatly apply the gain to avoid that
			-- y registers grow too high!
			
			-- The gain is 0.00301... ~= 3/1000 ~= 4/1024 ~= 1/256 no sono già normalizzati
			--tmp := sar(tmp, 8); 
			
			-- Now I add the recursive part!
			tmp := tmp - y * a1 - y1 * a2- y2 * a3 - y3 * a4- y4 * a5- y5 * a6- y6 * a7- y7 * a8- y8 * a9- y9 * a10- y10 * a11;
			
			-- resize the tmp value for putting it in to output
			
			tmp := sar(tmp, N+4);
			
			-- take new value 
			y10 <= y9;
			y9 <= y8;
			y8 <= y7;
			y7 <= y6;
			y6 <= y5;
			y5 <= y4;
			y4 <= y3;
			y3 <= y2;
			y2 <= y1;
			y1 <= y;
			y <= tmp(N-1 downto 0);
			x10 <= x9;
			x9 <= x8;
			x8 <= x7;
			x7 <= x6;
			x6 <= x5;
			x5 <= x4;
			x4 <= x3;
			x3 <= x2;
			x2 <= x1;
			x1 <= x;
		end if;
	end process;
end architecture;
