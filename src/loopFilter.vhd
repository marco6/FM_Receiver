--here the code of loop filter
--in pratica è un filtro passa basso se non ho capito male
--devo solo capire come si fa un filtro passa basso 

--used library
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity loop_filter is
generic ( N: positive := 12
		);
port (CLK : in std_logic;
	  RESET : in std_logic;
	  filter_in : signed (N-1 downto 0);
	  filter_out : signed (N-1 downto 0)
	 );

end loop_filter;