library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fm_receiver is
   generic ( N : positive := 12 );
port (
	clk, rst : in std_logic;
	fin : in signed( N-1 downto 0);
	fout : out signed( N-1 downto 0)
);
end fm_receiver;

architecture structure of fm_receiver is
	
	
component demodulator is
generic ( N : positive := 12 );
port (
	clk, rst : in std_logic;
	fin : in signed( N-1 downto 0);
	fout : out signed( N-1 downto 0)
);
end component;

component passabanda is
generic ( N : positive := 12 );
port (
	CLK, RST : in std_logic;
	X : in signed( N-1 downto 0);
	Y : out signed( N-1 downto 0)
);
end component;


signal s1 : signed(N-1 downto 0);


begin

	C1: demodulator
	port map (
		--segnale del component=> segnale interno o esterno
		clk => clk, 
		rst => rst,   
		fin => fin,
		fout => s1    
	);
	
	C2: passabanda
	port map (
		clk => clk,
		rst => rst,
		X => s1,    
		Y => fout
	);
	

end architecture;
