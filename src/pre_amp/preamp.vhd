--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: preamp.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010T> <Package::484 FBGA>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
USE ieee.numeric_std.ALL;

entity preamp is
generic (
		N : positive := 7    --per usare il file di testo ipotizzo campioni da 8 bit
	);
port (
    clk : in std_logic;   
    input : in std_logic_vector(N downto 0);   --valori dall'adc
    output : out std_logic_vector(N downto 0)  --valori per il pll
);
end preamp;

architecture behav of preamp is
   --niente di che ci ho messo un eternità perchè non so un tubo di vhdl,
   --quando il clock è a 1 leggo il valore (che in simulazione è preso dal file,
   --in realtà sarà poi dall'adc), e uso il trucchetto delle trasformazioni per utilizzare il
   --"maggiore-uguale". se lo è l'output son tutti 1, altrimenti tutti 0 (facilmente si può fare -2^8 col
    --complemento a 2)

signal val : integer;   

begin
    
   Process(clk)
   BEGIN

    if(clk='1') then
        val<=to_integer(signed(input));
        if(val >= 0) then
            output<=(others => '1');
        else
            output<=(others => '0');
        end if;
    
    end if;

  end process;

end behav;
