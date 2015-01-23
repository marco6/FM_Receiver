--ThestBench of decimator

LIBRARY ieee;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library std;
use std.textio.all;

entity test_decimator is

end test_decimator;

architecture Behavioral of test_decimator is

	-- Input file, generated with matlab that contains
	-- a low freq sinusoid and a hi freq one! There is also some
	-- Gaussian noise...

	file vectors: text open read_mode is "src/test/test_decimator.dat";
	constant N : positive := 12;
	-- The component to be tested
component decimator is
	generic ( N : positive := 12;
			  DIV : positive := 200
  			 );
	port (CLK : in std_logic;
		  RESET : in std_logic;
		  Fin : in signed (N-1 downto 0);
		  Fout: out signed (N-1 downto 0)
		  );
end component;


	-- Basic signals. Stop is needed to avoid infinite looping
	signal clock,  STOP : std_logic := '0';
	signal reset : std_logic := '1'; -- Start by resetting everything
	-- I/O redirect
	signal f_in : signed(N-1 downto 0) := (others => '0');

	-- Since this is a test, this could be anything.
	-- Still the real clock period needs to be 1 us, because we need to
	-- Process samples @ 1 Mhz! So...
	constant clk_cycle : time := 1 us;
begin
	-- Instantiation... N is set to 12 since XADC is capable of that bit depth.
dec_test: decimator
	generic map ( N => 12 )
	port map (
		CLK => clock,
		RESET => reset,
		Fin => f_in,
		Fout => open -- I leave this open... I will still see the output
				  -- in a good simulator
	);

	RESET <= '0' after clk_cycle*4;


	clock <= not clock after clk_cycle / 2 when not endfile(vectors) else unaffected;

CLOCK_PROCESS:
	process(clock)

	variable vectorline : line;
		-- W: E' meglio usare gli integer così possiamo generare noi i test
    variable f_in_var : integer;

	begin
		if rising_edge (clock) then
			if ( not endfile(vectors) ) then
				readline(vectors, vectorline);
				read(vectorline, f_in_var);
				-- W: la conversione anche quì è più semplice con gli interi!
				f_in <= to_signed(f_in_var, N);
			end if;
		end if;

	end process;
end Behavioral;
