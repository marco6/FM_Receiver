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


architecture Pll of Demodulator is
  
	--dichiarazione segnali interni
	signal s1 : signed(N-1 downto 0);
	signal s2 : signed(N-1 downto 0);
	signal s3 : signed(N-1 downto 0);
	--dichiarazione component
  
	component phase_detector is
	generic ( 
		N : positive := 12 
  	);
	port ( 
		clk    : in std_logic ;
		reset  : in std_logic ;
		input1 : in signed (n-1 downto 0);
		input2 : in signed (n-1 downto 0);
		output : out signed (n-1 downto 0)
	);
	end component;

	component loop_filter is
	generic ( 
		N: positive := 12
	);
	port (
		CLK : in std_logic;
		RESET : in std_logic;
		filter_in : in signed (N-1 downto 0);
		filter_out : out signed (N-1 downto 0)
	);
	end component;

	component NCO is
	generic ( 
		N, -- Questa è il numero di bit in ingresso (addressing space)
		M -- Questa invece è la larghezza in bit dell'uscita
		: positive := 12 -- entrambi sono di default a 12 bit perchè fa 
						 -- fa comodo visto che l'xadc sputa 12 bit
	);
	port (
		CLK, RST : in std_logic;
		STEP : in unsigned(N-1 downto 0);
		E_IN : in signed(N-1 downto 0);
		C_OUT : out signed(M-1 downto 0)
	);
	end component;

begin
	--port maps
phd: phase_detector
	generic map (
		N => N
	)
	port map (
		clk => clk,
		reset  => rst,
		input1 => fin,
		input2 => s3,
		output => s1
    );
	
filter: loop_filter
	generic map (
		N => N
	)
	port map(
		CLK => clk,
		RESET => rst,
		filter_in => s1,
		filter_out => s2
	);
   
oscilaltor: NCO
	generic map (
		N => N,
		M => N
	)
	port map (
		clk => clk,
		rst => rst,
		STEP => to_unsigned(1, N),
		E_in => s2,
		C_OUT => s3  
	);
	
	-- mappiamo anche l'uscita!
	fout <= s2;

end architecture;

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

