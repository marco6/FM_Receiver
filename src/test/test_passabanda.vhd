library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;  --necessario per usare un file di testo come input di simulazione

entity test_passabanda is
end entity;

architecture behavior of test_passabanda is
	--la simulazione è un po piu incasinata, ma a parte le port map iniziali non ho nemmeno messo il reset tanto
	--dovrebbe partire immediatamente, prende un valore dal file ogni 4 periodi di clock e fa il suo sporco lavoro
    constant N : positive := 12;

	file vectors: text open read_mode is "src/test/test_preamp_noise.dat";  --file di testo (da allegare con IMPORT su microsemi, non so sul vostro)

	component passabanda is
	generic ( N : positive := 12 );
	port (
		CLK, RST : in std_logic;
		X : in signed( N-1 downto 0);
		Y : inout signed( N-1 downto 0)
	);
	end component;

    --i nomi dei segnali sono copiati pari pari dal testbench del pdf
    SIGNAL clk : std_logic := '0' ;
    SIGNAL fmin : signed(N-1 downto 0) := (others => '0');
    constant clkperiod : time := 10 ns;
    signal reset: std_logic := '1'; -- W: Questo è  necessario perchè se no reset è 'undefined'. Probabilmente a te fungeva perchè libero soc ti inizializza le variabili da solo...

	begin
test: passabanda
	port map (clk=>clk,
		x=>fmin,
		y=> open,
		rst=>reset
	);

	RESET <= '0' after clkperiod*4;

	clk <= not clk after clkperiod / 2 when not endfile(vectors) else unaffected;

	process (clk)
		variable vectorline : line;
        variable fmin_var : integer;
    begin
		if ( not endfile(vectors) ) then
			readline(vectors, vectorline);
			read(vectorline, fmin_var);
			fmin <= to_signed(fmin_var, N);
		end if;
	end process;

end behavior;
