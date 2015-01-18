--test dpll
library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL; 

entity test_fm_receiver is
end test_fm_receiver;

architecture behavior of test_fm_receiver is
	constant N : positive := 12;

	file vectors: text open read_mode is "src/test/toni12bit.dat";  
	
	component fm_receiver is
	generic ( N : positive := 12 );
	port (
		clk, rst : in std_logic;
		fin : in signed( N-1 downto 0);
		fout : out signed( N-1 downto 0)
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
test: fm_receiver
	generic map ( N => N ) -- W: needed to match 
	port map (clk=>clk,
		rst=>reset,
		fin=> fmin, -- W: Questo non è necessario assegnarlo... Il simulatore lo vede lo stesso
		fout=>open
	);
    
	-- W: Reset gen can be much more easily done with
	RESET <= '0' after clkperiod*4;
	
	-- aggiungendo poche minchiatine si può generare qualcosa che funziona.
	clk <= not clk after clkperiod / 2 when not endfile(vectors) else unaffected;

	process (clk) --W: questo è meglio sincronizzarlo con il clock!!
        variable vectorline : line;
		variable fmin_var : integer;
    begin
		if (RESET = '0' and rising_edge(CLK)) then
			if ( not endfile(vectors) ) then
				readline(vectors, vectorline);
				read(vectorline, fmin_var);
				fmin <= to_signed(fmin_var, N);
			end if;
		end if;
	end process;

end behavior;
