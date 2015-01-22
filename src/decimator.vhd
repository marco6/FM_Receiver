--decimator VHDL project

--used library
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;



entity decimator is 
	generic ( N : positive := 12;
			-- one good sample each M input sample
			M : positive := 20
  			 );
	port (CLK : in std_logic;
		  RESET : in std_logic;
		  Fin : in signed (N-1 downto 0);         --input signal which is the actual value of adder
		  --output signal which one of valide sample
		  Fout: out signed (N-1 downto 0)
		  );
end decimator;

architecture decimator_behavior of decimator is  
	signal cnt : unsigned(N-1 downto 0); --counter
	signal f : signed(N-1 downto 0); --output
begin
	process (CLK , RESET) 
	begin
		if (RESET = '1') then 
			f <= (others => '0');
			cnt <= (others => '0');
		elsif rising_edge (CLK) then	
			if (cnt /= M-1) then
				cnt <= cnt + to_unsigned(1, N); -- seems expensive, but in VHDL
												-- functions are solved to constants, 
												-- so... everything seems fine!
			else
				-- Hard reset 
				cnt <= (others => '0');
				-- And the output will be the input sample
				f <= Fin;
			end if;
			Fout<=f;
		end if;
	end process;

end decimator_behavior;
