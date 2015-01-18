library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cosine_rom is
	generic ( N, M : positive := 12 );
	port (
		CLK : in std_logic;
		IDX : in unsigned( N-1 downto 0);
		C_OUT : out signed ( M-1 downto 0)
	);
end cosine_rom;

architecture Behavioral of cosine_rom is
begin
-- todo
end;
