library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.Helpers.all;

-- in questo test provo a vedere se le funzioni di help funzionano 
-- correttamente
entity Helpers_test is
end Helpers_test;

architecture Behavioral of Helpers_test is
	signal A: signed(9 downto 0);
	signal B: unsigned(11 downto 0);
begin
test:
	process
	begin
		-- prima lo shift
		A <= to_signed(-160, A'length);
		wait for 1 ns;
		A <= SAR(A, 2); -- questo dovrebbe fare -40
		wait for 1 ns;
		-- Controllo che sia vero
		assert to_integer(A) = -40 ;
		
		-- Ora provo a trasformare -40 in unsigned a 12 bit
		B <= TO_UNSIGNED_RESIZE(A, B'length);
		wait for 1 ns;
		
		assert to_integer(B) = 4056; -- spero di non aver toppato
		
		-- ripeto tutto ma con i positivi

		-- prima lo shift
		A <= to_signed(160, A'length);
		wait for 1 ns;
		A <= SAR(A, 2); -- questo dovrebbe fare 40
		wait for 1 ns;
		-- Controllo che sia vero
		assert to_integer(A) = 40 ;
		
		-- Ora provo a trasformare 40 in unsigned a 12 bit
		B <= TO_UNSIGNED_RESIZE(A, B'length);
		wait for 1 ns;
		
		assert to_integer(B) = 40; -- spero di non aver toppato
		wait; -- fine!
	end process;
end architecture;
