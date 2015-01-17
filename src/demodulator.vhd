library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Demodulator is
   generic ( N : positive := 12 );
port (
	clk, rst : in std_logic;
	fin : in signed( N-1 downto 0);
	fout : out signed( N-1 downto 0)
);
end Demodulator;

architecture Dpll of Demodulator is
	signal s1 : std_logic;
	signal s2 : std_logic;
	signal s3 : std_logic;
	
component preamp is
generic (
		N : positive := 12; --output from xadc of 12 bit
        soglia_isteresi : positive := 100  --isteresis to eliminate noise
	);
port (
    clk : in std_logic;   
    input : in signed(N-1 downto 0);   
    output : out std_logic := '0';
    rst : in std_logic
);
end component;

component SyncXor is
	port (
		CLK, A, B : in std_logic;
		C : out std_logic
	);
end component;

component adder is 
	generic ( N : positive := 12 
  			 );
	port (CLK : in std_logic;
		  RESET : in std_logic;
		  df : in std_logic;         --input signal which determines the "sign" of the sum
		  --F : inout signed (N-1 downto 0);
		  F : out signed (N-1 downto 0)
		  --f1 : in signed(N-1 downto 0)  --input accumulator
		  );
end component;

component clock_divider is
	generic(
		N : positive := 8; -- Number of bits to store the counter
		DIV : positive := 200 
	);
	port (
		CLK, RST : in std_logic; -- Clock and Reset needed
		O_CLK : inout std_logic := '0'-- output is feeded as an input, so inout!
	);
end component;



begin

	C1: preamp
	port map (
		--segnale del component=> segnale interno o esterno
		clk => clk, 
		input => fin,   
		output => s1,
		rst => rst
	);
	
	C2: SyncXor
	port map (
		clk => clk,
		A => s1,
		B => s2,
		C => s3
	);
	
	C3: clock_divider
	port map (
		clk => clk,
		rst => rst,
		O_CLK => s2
	);
	
	C4: adder
	port map (
		CLK => clk,
		RESET => rst,
		df => s3,
		F => fout
	);

end architecture;


architecture Pll of Demodulator is
  
  --dichiarazione segnali interni
  signal s1 : signed(N-1 downto 0);
	signal s2 : signed(N-1 downto 0);
	signal s3 : signed(N-1 downto 0);
  --dichiarazione component
  
COMPONENT phase_divider
  generic ( N : positive := 12 
  			 );
PORT ( clk    : IN std_logic ;
       reset  : IN std_logic ;
       input1 : IN signed (N-1 DOWNTO 0);
       input2 : IN signed (N-1 DOWNTO 0);
       output : OUT signed (N-1 DOWNTO 0)
     );
END COMPONENT;

component loop_filter is
generic ( N: positive := 12
		);
port (CLK : in std_logic;
	  RESET : in std_logic;
	  filter_in : in signed (N-1 downto 0);
	  filter_out1 : out signed (N-1 downto 0);   --serve una doppia uscita, una verso il filtro e una in retroaz all'nco
	  filter_out2 : out signed (N-1 downto 0)
	 );
end component;

component NCO is
generic ( N, -- Questa è il numero di bit in ingresso (addressing space)
		M -- Questa invece è la larghezza in bit dell'uscita
		: positive := 12 -- entrambi sono di default a 12 bit perchè fa 
						 -- fa comodo visto che l'xadc sputa 12 bit
		);
port (
	CLK, RST : in std_logic;
	STEP : in unsigned(N-1 downto 0); -- Parte programmabile del NCO...
									  -- in pratica decide la frequenza
									  -- di demodulazione.
									  -- Sotto c'è una spiegazione di
									  -- come calcolre la frequenza
									  -- dato N.
	E_IN : in signed(N-1 downto 0); -- Errore di fase: serve al NCO per
									-- riuscire a seguire il segnale.
									-- E' in pratica l'ingresso che 
									-- proviene dal loop.
	C_OUT : out signed(M-1 downto 0)-- Output: l'onda generata.
);
end component;




  begin
  --port mappe
  c1: phase_divider
  port map (
  clk => clk,
       reset  => rst,
       input1 => fin,
       input2 => s3,
       output => s1
    );
	
	c2: loop_filter
	port map(
		CLK => clk,
	  RESET => rst,
	  filter_in => s1,
	  filter_out1 => fout,   --serve una doppia uscita, una verso il filtro e una in retroaz all'nco
	  filter_out2 => s2
	);
   
   c3: NCO
   port map(
   clk => clk,
   rst => rst,
   --E_in => 'Z',
   C_OUT => s3  
   );
   
   
   
  end architecture;