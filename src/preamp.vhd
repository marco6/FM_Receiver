
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
USE ieee.numeric_std.ALL;

entity preamp is
generic (
		N : positive := 12; --per usare il file di testo ipotizzo campioni da 8 bit
        soglia_isteresi : positive := 10
	);
port (
    clk : in std_logic;   
    input : in signed(N-1 downto 0);   --valori dall'adc
    output : out std_logic;  --valori per il pll
    rst : in std_logic
);
end preamp;

architecture behav of preamp is
   
signal val : signed(N-1 downto 0); 
signal prec : std_logic;  

begin
    
   Process(clk)
   BEGIN
    if(rst='1') then
        output <='0';
        prec <='0';
    else
        if(clk='1') then
            val<=input;
            if(val(N-1) = '0' and val<=soglia_isteresi) then
                --se input positivo ma minore della soglia
                if(prec='1') then
                    --se prec è positivo
                    output<='1';
                    prec<='1';
                else
                    --se prec è negativo
                    output<='0';
                    prec<='0';
                end if;
            end if;
            if(val(N-1)='0' and val>soglia_isteresi) then
                    --se input positivo e maggiore della soglia isteresi
                    output<='1';
                    prec<='1';
            end if;
            
            if(val(N-1)='1' and val < (-soglia_isteresi)) then
                    --se input è minore della soglia in negativo
                    output<='0';
                    prec<='0';
            end if;
            
            if(val(N-1)='1' and val> (-soglia_isteresi)) then
                    --se input è negativo e maggiore della soglia in negativo
                    if(prec='1') then
                        --se prec è positivo
                        output<='1';
                        prec<='1';
                    else
                        --se prec è negativo
                        output<='0';
                        prec<='0';
                    end if;
             end if;
            
        end if;
        
    end if;
  end process;

end behav;
