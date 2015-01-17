library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all; 

entity test_demodulator is
end test_demodulator;

architecture behavior of test_demodulator is

    constant N : positive := 12;

	file vectors: text open read_mode is "src/test/sawtooth12bit.dat";

	component demodulator is
	generic ( N : positive := 12 );
	port (
		clk, rst : in std_logic;
		fin : in signed( N-1 downto 0);
		fout : out signed( N-1 downto 0)
	);
	end component;
    
    SIGNAL clk : std_logic := '0' ;
    SIGNAL fmin : signed(N-1 downto 0) := (others => '0');
    
	constant clkperiod : time := 1 us;
    signal reset: std_logic := '1'; 
	
begin
    

	test: demodulator 
	generic map ( N => N ) 
	port map (clk=>clk,
		rst=>reset,
		fin=> fmin,
		fout=>open
	);
    

	RESET <= '0' after clkperiod*4;

	clk <= not clk after clkperiod / 2 when not endfile(vectors) else unaffected;

	process (clk) 
		variable vectorline : line;
		variable fmin_var : integer;
    begin
		if(not reset) then
			if ( not endfile(vectors) ) then
				readline(vectors, vectorline);
				read(vectorline, fmin_var);
				fmin <= to_signed(fmin_var, N);
			end if;
		end if;
	end process;

end behavior;
