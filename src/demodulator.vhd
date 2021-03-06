library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Demodulator is
   generic ( N : positive := 12 );
port (
	clk, rst : in std_logic;
	fin : in signed( N-1 downto 0);
	fout : out signed( N-1 downto 0);
	clkout : out std_logic
);
end Demodulator;

architecture Dpll of Demodulator is

	--internal signals

	signal s1 : std_logic;
	signal s2 : std_logic;
	signal s3 : std_logic;
	signal s4 : signed(N-1 downto 0);


	--components declaration


component preamp is
generic (
		N : positive := 12;
        soglia_isteresi : positive := 50
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
		  df : in std_logic;
		  F : out signed (N-1 downto 0)
		  );
end component;

component decimator is
	generic ( N : positive := 12;
			-- one good sample each M input sample
			DIV : positive := 20
			);
	port (CLK : in std_logic;
		  RESET : in std_logic;
		  Fin : in signed (N-1 downto 0);
		  Fout: out signed (N-1 downto 0)
		  );
end component;

component clock_divider is
	generic(
		N : positive := 8; -- Number of bits to store the counter
		DIV : positive := 20

	);
	port (
		CLK, RST : in std_logic;
		O_CLK : inout std_logic := '0'
	);
end component;



begin

amp: preamp
	port map (
		clk => clk,
		input => fin,

		output => s1,
		rst => rst
	);

demod: SyncXor
	port map (
		clk => clk,
		A => s1,
		B => s2,
		C => s3
	);

dem_signal: clock_divider
	generic map (
		DIV => 8
	)
	port map (
		clk => clk,
		rst => rst,
		O_CLK => s2
	);

integrator: adder
	port map (
		CLK => clk,
		RESET => s2,
		df => s3,
		F => s4
	);

sampler: decimator
	generic map (
		DIV => 8
	)
	port map (
		CLK => clk,
		RESET => rst,
		Fin => s4,
		Fout => fout
	);

	clkout<=s2;

end architecture;


architecture Pll of Demodulator is


	--internal signals
	signal s1 : signed(N-1 downto 0);
	signal s2 : signed(N-1 downto 0);
	signal s3 : signed(N-1 downto 0);

	--components declaration

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
	generic ( N, -- Number of bits as input
			M -- Number of bits as output
			: positive := 12; -- Default to 12 bit because of the xadc
			Shift : natural := 4; -- This is a scaling factor as a shift
			STEP : natural := 2**9
			);
	port (
		CLK, RST : in std_logic;
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
		Shift => 4,
		N => N,
		M => N
	)
	port map (
		clk => clk,
		rst => rst,
		E_in => s2,
		C_OUT => s3
	);


	-- also map the output
	clkout<=clk;
	fout <= s2;

end architecture;

