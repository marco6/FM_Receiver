library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- The xor needed to switch from Frequency Modulation to Pulse Width Modulation
entity SyncXor is
	port (
		CLK, A, B : in std_logic;
		C : out std_logic
	);
end entity;

architecture Behavioral of SyncXor is
begin
	-- Vabbè.... 'Nsomma na vaccata...
	C <= A xor B when rising_edge(CLK);
end;