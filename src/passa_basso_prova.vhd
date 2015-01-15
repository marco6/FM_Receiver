library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use WORK.Helpers.all;

entity passabanda is
generic ( N : positive := 12 );
port (
	CLK, RST : in std_logic;
	X : in signed( N-1 downto 0);
	Y : out signed( N-1 downto 0)
);
end passabanda;

--Transfer function coefficients of the filter, calculated whit matlab butter function;
-- >> [b, a] = butter(2,30/1000000, 'high')

-- b =    0.9999   -1.9999    0.9999
-- a =    1.0000   -1.9999    0.9999

-- >> [b, a] = butter(2,15000/1000000, 'low')

-- b =    0.0005    0.0011    0.0005
-- a =    1.0000   -1.9334    0.9355



architecture AsyncReset_Beh of passabanda is
	
	constant Np2 : real := (2.0 ** (N-2));
	
	
	-- the constants are normalized
	constant a1l : signed(N-1 downto 0) := to_signed(integer((-1.9334) * Np2), N);
	constant a2l : signed(N-1 downto 0) := to_signed(integer((0.9355) * Np2), N);
	
	constant b1l : signed(N-1 downto 0) := to_signed(integer(0.0005 * Np2), N);
	constant b2l : signed(N-1 downto 0) := to_signed(integer(0.0011 * Np2), N);
	constant b3l : signed(N-1 downto 0) := to_signed(integer((0.0005) * Np2), N);
	

	constant a1h : signed(N-1 downto 0) := to_signed(integer((-1.9999) * Np2), N);
	constant a2h : signed(N-1 downto 0) := to_signed(integer((0.9999) * Np2), N);

	constant b1h : signed(N-1 downto 0) := to_signed(integer(0.9999 * Np2), N);
	constant b2h : signed(N-1 downto 0) := to_signed(integer((-1.9999) * Np2), N);
	constant b3h : signed(N-1 downto 0) := to_signed(integer(0.9999*Np2), N);
	
		
	-- temporary variable
	signal x1, x2, x3,x4,x5,y1, y_retr: signed(N-1 downto 0) := (others => '0');
	
begin
	--
	process (CLK, RST)
		variable tmp : signed(27 downto 0);
		variable add1, add2, add3, sub1, sub2 :signed(27 downto 0);--variabili necessarie per garantire di non andare in overflow
		variable mul1,mul2,mul3, mul4, mul5 :signed(2*N-1 downto 0);
		
	begin
		-- Async reset
		if (RST = '1') then
			-- On reset everything should go to zero
			x1 <= (others => '0');
			x2 <= (others => '0');
			x3 <= (others => '0');
			x4 <= (others => '0');
			x5 <= (others => '0');
		
			y1 <= (others => '0');
			
			
			
			tmp := (others => '0');
			y_retr <=(others => '0');
			
			Y <= (others => '0');
			
			
		elsif (CLK = '1' AND CLK'event) then
			-- now.. I compute first the non recursive part of the filter
			--numeratore
			mul1 := x * b1l; 
			if (mul1(mul1'left)='0') -- brutale bisogna poi farci una funzioncina per eleganza
			then
			add1:="0000" & mul1; -- Qui semplicemente stavi passando da 24 a 28 non da 12 a 28.... la stanchezza fa brutti scherzi! xD
			else
			add1:="1111"&mul1;
			end if;
			
			mul2 := x1 * b2l; 
			if (mul2(mul2'left)='0') -- brutale bisogna poi farci una funzioncina per eleganza
			then
				add2:="0000"&mul2;
			else
				add2:="1111"&mul2;
			end if;
			
			
			mul3 := x2 * b3l;
			if (mul3(mul3'left)='0') -- brutale bisogna poi farci una funzioncina per eleganza
			then
				add3:="0000"&mul3;
			else
			add3:="1111"&mul3;
			end if;
			
			
			--denominatore
			
			mul4 := y_retr * a1l;
			if (mul4(mul4'left)='0') -- brutale bisogna poi farci una funzioncina per eleganza
			then
			sub1:="0000"&mul4;
			else
			sub1:="1111"&mul4;
			end if;
			
			
			mul5 := y1 * a2l;
			if (mul5(mul5'left)='0') -- brutale bisogna poi farci una funzioncina per eleganza
			then
			sub2:="0000"&mul5;
			else
			sub2:="1111"&mul5;
			end if;
			
			
			tmp := add1 + add2+ add3 - sub1- sub2; --braccio di retroazione sul filtro			
			
			-- resize the tmp value for putting it in to output
			tmp := sar(tmp, N-2);
			
			
			-- take new value 
			y1 <= y_retr;
			y_retr <= tmp(N-1 downto 0);
			
			--put result in output
			y <= tmp(N-1 downto 0);
			
			
			--for low pass
			x2 <= x1;
			x1 <= x;
			
		end if;
	end process;
end architecture;
