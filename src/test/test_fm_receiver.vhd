--test dpll
library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;

entity test_fm_receiver is
end test_fm_receiver;

architecture behavior of test_fm_receiver is
	constant N : positive := 12;
<<<<<<< Updated upstream

	file source: text open read_mode is "src/test/sawtooth12bit.in";
=======
	
>>>>>>> Stashed changes
	file vectors: text open read_mode is "src/test/sawtooth12bit.dat";
	file origin: text open read_mode is "src/test/sawtooth12bit.in";

	component passabanda is
	generic ( N : positive := 12 );
	port (
		CLK, RST : in std_logic;
		X : in signed( N-1 downto 0);
		Y : out signed( N-1 downto 0)
	);
	end component;

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
    SIGNAL o_in : signed(N-1 downto 0) := (others => '0');
    -- SIGNAL dmout : std_logic;
    constant clkperiod : time := 1 us;
    signal reset: std_logic := '1'; -- W: Questo è  necessario perchè se no reset è 'undefined'. Probabilmente a te fungeva perchè libero soc ti inizializza le variabili da solo...
	signal original: signed(N-1 downto 0) := (others => '0');
begin

check: passabanda
	port map(
		clk => clk,
		rst => reset,
		X => o_in,
		Y => open
	);

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
<<<<<<< Updated upstream
				readline(source, vectorline);
				read(vectorline, fmin_var);
				original <= to_signed(fmin_var, N);
=======
				readline(origin, vectorline);
				read(vectorline, fmin_var);
				o_in <= to_signed(fmin_var, N);
>>>>>>> Stashed changes
			end if;
		end if;
	end process;

end behavior;
