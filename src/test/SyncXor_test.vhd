library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SyncXor_test is
end;

-- Test idiota: sono abbastanza sicuro che l'xor funzioni....
architecture Behavioral of SyncXor_test is
	component SyncXor is
		port (
			CLK, A, B : in std_logic;
			C : out std_logic
		);
	end component;

    constant clkperiod : time := 1 ns;
	
	signal A_in, B_in, C_out, clk : std_logic := '0';
	
begin
	
	-- Comunque instazio il pezzo
exor: SyncXor
	port map(CLK => clk, A => A_in, B => B_in, C => C_out);
	
	-- Genero il clock fino ad una condizione di terminazione
	clk <= not clk after clkperiod/2 when A_in = '0' or C_out='1' else unaffected;
	
	process
	begin
		-- Qui posso tranquillamente provare tutte le combinazioni: 
		-- ce n'è solo 4!!!
		A_in <= '0';
		B_in <= '0';
		wait until falling_edge(clk);
		A_in <= '0';
		B_in <= '1';
		wait until falling_edge(clk);
		A_in <= '1';
		B_in <= '0';
		wait until falling_edge(clk);
		A_in <= '1';
		B_in <= '1';
		wait; -- Questo è necessario per evitare loop infiniti! 
	end process;
end;