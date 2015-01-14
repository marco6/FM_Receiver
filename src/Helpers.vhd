library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ragazzi parliamo come mangiamo: italiano!
-- Questo package è il ricettacolo di tutte le cose utili ma che 
-- possono essere riutilizzate, ok?
-- La roba che ho scritto in inglese non la riscrivo... 
package Helpers is
	-- Arithmetic right shift - I don't know why this isn't in the 
	-- standard lyibrary yet!
	-- As input this function takes a signed number (other data type
	-- wouldn't really need SAR function) and a strictly positive count.
	function SAR (LEFT: SIGNED; COUNT: POSITIVE ) return SIGNED;

	-- Questa funzione restituisce un numero senza segno con ampiezza N,
	-- tenendo conto del segno durante la conversione.
	function TO_UNSIGNED_RESIZE(L: SIGNED; N : POSITIVE) return UNSIGNED;
	
	-- Questa funzione fa il resize dei due tipi numerici, tenendo conto del segno
	-- IN particolare, aggiunge N bit al numero
	function RESIZE(L:SIGNED; N : POSITIVE) return SIGNED;
	
	-- Questa funzione fa il resize dei due tipi numerici
	function RESIZE(L:UNSIGNED; N : POSITIVE) return UNSIGNED;
	
end Helpers;

package body Helpers is

	function RESIZE(L:SIGNED; N : POSITIVE) 
		return SIGNED is
		variable RET : SIGNED(N + L'length -1 downto 0);
	begin
		RET(N+ L'length -1 downto L'length) := (others=>L(L'left));
		RET(L'length-1 downto 0) := L;
		RETURN RET;
	end RESIZE;

	function RESIZE(L:UNSIGNED; N : POSITIVE) 
		return UNSIGNED is
		variable RET : UNSIGNED(N + L'length -1 downto 0);
	begin
		RET(N+ L'length -1 downto L'length) := (others=>'0');
		RET(L'length-1 downto 0) := L;
		RETURN RET;
	end RESIZE;
	
	

	function TO_UNSIGNED_RESIZE(L: SIGNED; N : POSITIVE) 
		return UNSIGNED is
		variable RET : UNSIGNED (N-1 downto 0);
	begin
		-- Sanity check
		assert N > L'length;
		RET(N-1 downto L'length) := (others => L(L'left));
		RET(L'left downto 0) := UNSIGNED(L);
		return RET;
	end TO_UNSIGNED_RESIZE;

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
