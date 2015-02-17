--adder VHDL project

--used library
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;



entity adder is 
	generic ( N : positive := 12 
  			 );
	port (CLK : in std_logic;
		  RESET : in std_logic;
		  df : in std_logic;         --input signal which determines the "sign" of the sum
		  --F : inout signed (N-1 downto 0);
		  F : out signed (N-1 downto 0)
		  --f1 : in signed(N-1 downto 0)  --input accumulator
		  );
end adder;

architecture adder_behavior of adder is 
	constant inc_signal : signed (N-1 downto 0) := to_signed(93, N);  --signal which will be incremented 
	signal f2 : signed(N-1 downto 0) := (others => '0'); --accumulator
begin
	process (CLK , RESET) 
	begin
		if rising_edge(RESET) then 
			f2<= (others => '0');
		elsif rising_edge (CLK) then	
			if (df = '1') then
				f2<= f2  + inc_signal;
			else
				f2<= f2 - inc_signal;
			end if;
		end if;
	end process;
	F<=f2;

end adder_behavior;


