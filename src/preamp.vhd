library IEEE;

use IEEE.std_logic_1164.all;
USE ieee.numeric_std.ALL;

entity preamp is
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
                --positive input but less than threshold
                if(prec='1') then
                    --if 'prec' is positive
                    output<='1';
                    prec<='1';
                else
                    --if 'prec' is negative
                    output<='0';
                    prec<='0';
                end if;
            end if;
            if(val(N-1)='0' and val>soglia_isteresi) then
                    --if positive input greater than threshold
                    output<='1';
                    prec<='1';
            end if;
            
            if(val(N-1)='1' and val < (-soglia_isteresi)) then
                    --if input less than negative threesold
                    output<='0';
                    prec<='0';
            end if;
            
            if(val(N-1)='1' and val> (-soglia_isteresi)) then
                    --if negative input greater than negative threshold
                    if(prec='1') then
                        --if 'prec' is positive
                        output<='1';
                        prec<='1';
                    else
                        --if 'prec' is negative
                        output<='0';
                        prec<='0';
                    end if;
             end if;
            
        end if;
        
    end if;
  end process;

end behav;
