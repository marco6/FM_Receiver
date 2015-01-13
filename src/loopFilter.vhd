--here the code of loop filter
--mohamed ali version  

LIBRARY ieee;
USE iee.std_logic_1164.ALL
USE ieee.numeric_std.ALL

entity loop_filter is    --declarations
port (clk : in std_logic;
	   reset : in std_logic;
	   c : ni signed (7 downto 0);    --input <8,0,t> from multiplier
	   d1 : out signed (11 downto 0); --output <12,4,t> to FIR
	   d2 : out signed (11 downto 0)  --output <12,-6,t> to NCO
	   );
end loop_filter ; 

architecture behavior of loop_filter is
signal e : signed (11 downto 0);
signal dtemp : signed (11 downto 0);

begin
process(clk,reset)
begin
if (reset = '1') then 
d1 <= (others => '0');
d2 <= (others => '0');
e <= (others => '0');
dtemp <= (others => '0');
elsif rising_edge(clk) then 
dtemp <= (c(7)&c(7)&c(7)&c&'0') + dtemp - e;
e <= dtemp(11)&dtemp(11)&dtemp(11)&dtemp(11)&dtemp(11 downto 4);
d1 <= dtemp;
d2 <= dtemp (11 downto 4) & "0000";
end if;
end process;
end behavior;
