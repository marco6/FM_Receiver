--here the code of loop filter


--used library
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity loop_filter is
generic ( N: positive := 12
		);
port (CLK : in std_logic;
	  RESET : in std_logic;
	  filter_in : in signed (N-1 downto 0);
	  filter_out : out signed (N-1 downto 0)
	 );

end loop_filter;

architecture Behavioral of loop_filter is
signal f1 : signed(N-1 downto 0);
signal f2 : signed(N-1 downto 0);
signal f3 : signed(N-1 downto 0);
signal f4 : signed(N-1 downto 0);
signal sum : signed(N+1 downto 0);  --where I store the result of the addition, it requires 2 additional bit for take care of overflow
begin
process (CLK,RESET)
begin
	if (RESET='1')then

		f1 <= (others => '0');
		f2 <= (others => '0');
		f3 <= (others => '0');
		f4 <= (others => '0');
		sum <= (others => '0');
		
	elsif rising_edge(CLK) then
		f4 <= f3;
		f3 <= f2;
		f2 <= f1;
		f1 <= filter_in;
		sum <= f1 + f2 + f3 + f4;
		filter_out <= sum srl 2; --controllare ancora se si fa così lo shift 
	end if;
end process;

end Behavioral ;
