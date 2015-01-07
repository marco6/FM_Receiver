library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- Needed to use cos function on static initializzation
use IEEE.math_real.all;

entity cos_rom is
	generic ( N, M : positive := 12 );
	port (
		CLK : in std_logic;
		IDX : in unsigned( N-1 downto 0);
		C_OUT : out signed ( M-1 downto 0)
	);
end cos_rom;

architecture Behavioral of cos_rom is
	type C_ROM is array ( integer range 0 to 2**(N-2)-1)
		of signed( M - 1 downto 0 );
	-- this function will generate the values I need for my rom
	function FILL_ROM return C_ROM is
		variable RET : C_ROM;
	begin
		-- Here is where all the cleverness is: parametric generation of
		-- cos values!
		--
		-- Besides I use another trick: I keep x in the
		-- range [-pi/4, pi/4] that is all I need since cos is a pair
		-- function and it's period can be split in 4 parts:
		-- cos([0, pi/4]) = cos([pi/4, pi/2]) = -cos(pi/2, 3/4 pi) = -cos(3/4 pi, pi).
		--
		-- With this trick I get a reduction of the memory I need:
		-- "just" 1/4 of the addressing space!
		--
		for i in C_ROM'range loop
			RET(i) := to_signed ( 	-- Conversion from internal
									-- rapresentation to bit array

					integer ( 	-- Conversion from real to integer

						COS ( 	-- this function is probably not
								-- synthetizable, but since function
								-- returns constants in VHDL,this should
								--  be resolved by the synthetizer.
								(MATH_PI * real(i)) /
								real(C_ROM'length * 2)
						) * -- I multiply to obtain a fixed point
							-- fractional number!
						(2.0**(M-1))-1.0 	-- I leave one bit for the sign (kind
									-- of since it's 2's complement)
									-- the second "-1" is to avoid overflow
									-- in the peak.
					), M -- number of bits to translate int to signed
				); -- done!
		end loop;
		return RET;
	end;
	constant ROM : C_ROM := FILL_ROM;
begin
	-- the process is really basic! It just needs to load from the rom
	-- to the output!
	process (CLK)
		variable temp : signed(M-1 downto 0);
	begin
		-- on rising edge
		if(rising_edge(CLK)) then
			-- output
			-- On the 2nd quarter and on the 4th quarter of the addressing
			-- space (that is when the 2 MSB are either '01' or '11' and so when the
			-- 2nd MSB is 1) I need a change in the order of the samples!
			--
			if(IDX(M-2) = '1') then
				temp := ROM(ROM'length - 1 - to_integer(IDX(M-3 downto 0)));
			else
				temp := ROM(to_integer(IDX(M-3 downto 0)));
			end if;

			-- On the 2nd and 3rd quarter of the period (that is when the
			-- first 2 MSB are either '01' or '10' => when they are different
			-- one from the other) I need a change in the sign
			-- in the sign of the sample
			if(IDX(M-1) /= IDX(M-2)) then
				temp := -temp;
			end if;

			-- the result is a nice and smooth cos curve! :D
			C_OUT <= temp;
		end if;
	end process;
end architecture;
