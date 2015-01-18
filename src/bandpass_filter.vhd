library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.Helpers.all;

entity passabanda_old is
generic ( N : positive := 12 );
port (
	CLK, RST : in std_logic;
	X : in signed( N-1 downto 0);
	Y : inout signed( N-1 downto 0)
);
end passabanda_old;

--Transfer function coefficients of the filter, calculated whit matlab butter function;
-- >> [b, a] = butter(2,30/1000000, 'high')

-- b =    0.9999   -1.9999    0.9999
-- a =    1.0000   -1.9999    0.9999

-- >> [b, a] = butter(2,15000/1000000, 'low')

-- b =    0.0005    0.0011    0.0005
-- a =    1.0000   -1.9334    0.9355



architecture AsyncReset_Beh of passabanda_old is
	
	constant Np2 : real := (2.0 ** (N-2));
	
	
	-- the constants are normalized
	constant a1l : signed(N-1 downto 0) := to_signed(integer((-1.9334) * Np2), N);
	constant a2l : signed(N-1 downto 0) := to_signed(integer((0.9355) * Np2), N);

	constant a1h : signed(N-1 downto 0) := to_signed(integer((-1.9999) * Np2), N);
	constant a2h : signed(N-1 downto 0) := to_signed(integer((0.9999) * Np2), N);

	
	
	constant b1l : signed(N-1 downto 0) := to_signed(integer(0.0005 * Np2), N);
	constant b2l : signed(N-1 downto 0) := to_signed(integer(0.0011 * Np2), N);
	constant b3l : signed(N-1 downto 0) := to_signed(integer((0.0005) * Np2), N);
	
	constant b1h : signed(N-1 downto 0) := to_signed(integer(0.9999 * Np2), N);
	constant b2h : signed(N-1 downto 0) := to_signed(integer((-1.9999) * Np2), N);
	constant b3h : signed(N-1 downto 0) := to_signed(integer(0.9999*Np2), N);
	
		
	-- temporary variable
	signal x1, x2, x3, x4, x5, y1: signed(N-1 downto 0) := (others => '0');
	--signal tmp : signed(2*N-1	downto 0);
	
begin
	--
	process (CLK, RST)
		variable tmp : signed(2*N-1 downto 0);-- tmp := (others => '0'); --sized for ensure to not overflow (2*N-1) perchè funziona anche se io ne ho bisogno di più bit 
		--provare domani dinuovo con la divisione e capire perchè non funziona con i 32 bit ma con gli 23 si
		
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
			
			Y <= (others => '0');
			
			
		elsif (CLK = '1' AND CLK'event) then
			-- now.. I compute first the non recursive part of the filter
			tmp := x * b1l + x1 * b2l + x2 * b3l ;			
			-- Now I add the recursive part!
			tmp := tmp - x4 * a1l - x3 * a2l;--braccio di retroazione dul primo filtro
			
			-- resize the tmp value for putting it in to imput of the low pass filter
			tmp := sar(tmp, N);-- a questo punto non è male
			
			x3<= tmp(N-1 downto 0);--become imput for low pass
			tmp := x3 * b1h + x4 * b2h + x5 * b3h ;			
			-- Now I add the recursive part!
			tmp := tmp - y1 * a1h - y * a2h;-- all'uscita da questo è una merda 
			
			
			-- resize the tmp value for putting it in to output
			tmp := sar(tmp, N);
			
			
			-- take new value 
			y1 <= y;
			y <= tmp(N-1 downto 0);-- devo rimettere la divisione perchè i bit più alti potrebbero tranquillamente essere vuoti
			
			
			--for high pass
			x5 <= x4;
			x4 <= x3;
			--for low pass
			x2 <= x1;
			x1 <= x;
			
		end if;
	end process;
end architecture;
