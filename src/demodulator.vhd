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


--architecture Pll of Demodulator is
--begin
--end architecture;