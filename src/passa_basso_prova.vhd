library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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

	constant Np2 : real := ((2.0 ** N) - 1.0);


	constant a1l : signed(N+1 downto 0) := to_signed(integer(-1.933380225879930 * Np2), N+2);
	constant a2l : signed(N+1 downto 0) := to_signed(integer(0.935528904979178 * Np2), N+2);

	constant b1l : signed(N-1 downto 0) := to_signed(integer(0.000537169774812 * Np2), N);
	constant b2l : signed(N-1 downto 0) := to_signed(integer(0.001074339549624 * Np2), N);
	constant b3l : signed(N-1 downto 0) := to_signed(integer(0.000537169774812 * Np2), N);


	--constant a1h : signed(N-1 downto 0) := to_signed(integer((-1.9999) * Np2), N);
	--constant a2h : signed(N-1 downto 0) := to_signed(integer((0.9999) * Np2), N);

	--constant b1h : signed(N-1 downto 0) := to_signed(integer(0.9999 * Np2), N);
	--constant b2h : signed(N-1 downto 0) := to_signed(integer((-1.9999) * Np2), N);
	--constant b3h : signed(N-1 downto 0) := to_signed(integer(0.9999*Np2), N);


	-- temporary variable
	signal x1, x2, x3, y1, y_retr: signed(N-1 downto 0) := (others => '0');

begin
	process (CLK, RST)
		variable direct : signed (2*N-1 downto 0);
		variable recursive, sum : signed ( 2*N + 1 downto 0);
		
	begin


		-- Async reset
		if (RST = '1') then
			-- On reset everything should go to zero
			x1 <= (others => '0');
			x2 <= (others => '0');
			x3 <= (others => '0');
			y1 <= (others => '0');
			y_retr <=(others => '0');
			Y <= (others => '0');
			
			direct := (others => '0');
			recursive := (others => '0');

		elsif (CLK = '1' AND CLK'event) then
			-- now.. I compute first the non recursive part of the filter
			--numeratore
			direct := x * b1l + x1 * b2l + x2 * b3l;

			recursive := y_retr * a1l + y1 * a2l;

			sum := direct - recursive;

			-- take new value
			y1 <= y_retr;
			y_retr <= sum(2*N-1 downto N);

			--put result in output
			y <= sum(2*N-1 downto N);


			--for low pass
			x2 <= x1;
			x1 <= x;

		end if;
	end process;
end architecture;
