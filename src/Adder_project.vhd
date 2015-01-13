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
		  F : inout signed (N-1 downto 0)
		  );
end adder;

architecture adder_behavior of adder is 
constant inc_signal : signed (N-1 downto 0) := to_signed(-2, N);  --signal which will be incremented 
begin
process (CLK , RESET) 
begin
	if (RESET = '1') then 
		F <= (others => '0');
	elsif rising_edge (CLK) then	
		if (df = '1') then
			F <= F - inc_signal;
		else 
			F <= F - inc_signal ; 
		end if;
	end if;
end process;

end adder_behavior;


