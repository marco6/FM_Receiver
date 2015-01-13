library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;  --necessario per usare un file di testo come input di simulazione

-- W: NEVER use generics on testbenchs... Use constants instead!
entity test_preamp is
end test_preamp;

architecture behavior of test_preamp is
	--la simulazione è un po piu incasinata, ma a parte le port map iniziali non ho nemmeno messo il reset tanto
	--dovrebbe partire immediatamente, prende un valore dal file ogni 4 periodi di clock e fa il suo sporco lavoro
	-- W: Il reset l'ho fatto io... E' vero che andava lo stesso... però è buona norma farlo!
    constant N : positive := 12;

	file vectors: text open read_mode is "src/test/test_preamp.dat";  --file di testo (da allegare con IMPORT su microsemi, non so sul vostro)

	-- W: This needs to be copied as is from original file
	component preamp is
	generic (
			N : positive := 12;
			soglia_isteresi : positive := 100 
		);
	port (
		clk : in std_logic;   
		input : in signed(N-1 downto 0);   
		output : out std_logic;  
		rst : in std_logic
	);
	end component;
    
    --i nomi dei segnali sono copiati pari pari dal testbench del pdf
    SIGNAL clk : std_logic := '0' ;
    SIGNAL fmin : signed(N-1 downto 0) := (others => '0');
    -- SIGNAL dmout : std_logic;
    constant clkperiod : time := 10 ns;
    signal reset: std_logic := '1'; -- W: Questo è  necessario perchè se no reset è 'undefined'. Probabilmente a te fungeva perchè libero soc ti inizializza le variabili da solo...

begin
    
    --anche le funzioni per prendere i valori di volta in volta dal file, e usano la libreria textIO
test: preamp 
	generic map ( N => N, soglia_isteresi => 100 ) -- W: needed to match 
	port map (clk=>clk,
		input=>fmin,
		output=> open, -- W: Questo non è necessario assegnarlo... Il simulatore lo vede lo stesso
		rst=>reset
	);
    
	-- W: Reset gen can be much more easily done with
	RESET <= '0' after clkperiod*4;
--	RESET_GEN: 
--	process
--	begin
--	LOOP1: for N in 0 to 3 loop
--			wait until falling_edge(clk);
--		end loop LOOP1;
--		RESET <= '0' ;
--		end process RESET_GEN;

	-- W: Questo sava generando un loop infinito perchè non c'è condizione
	-- 		 di terminazione.
	-- aggiungendo poche minchiatine si può generare qualcosa che funziona.
	clk <= not clk after clkperiod / 2 when not endfile(vectors) else unaffected;

   process (clk) --W: questo è meglio sincronizzarlo con il clock!!
        variable vectorline : line;
		-- W: E' meglio usare gli integer così possiamo generare noi i test, senza copiare dall'indiano del cazzo
        variable fmin_var : integer;
    begin
		-- W: In questo modo si può addirittura evitare il while
		if ( not endfile(vectors) ) then
			readline(vectors, vectorline);
			read(vectorline, fmin_var);
			-- W: la conversione anche quì è più semplice con gli interi!
			fmin <= to_signed(fmin_var, N);
		end if;
end process;

end behavior;
