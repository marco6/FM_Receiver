library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MulTest is
end MulTest;

architecture Stimoli of MulTest is
	component AsyncMul is
	generic (
		N : positive := 8
	);
	port (
		A, B : in signed(N-1 downto 0);
		C : out signed(2*N -1 downto 0)
	);
	end component;
	
	component SyncMul is
	generic (
		N : positive := 8
	);
	port (
		CLK : in std_logic;
		A, B : in signed(N-1 downto 0);
		C : out signed(2*N -1 downto 0)
	);
	end component;

	constant CLK_P : time := 1 us;
	
	signal A_in, B_in : signed(11 downto 0) := (others => '0');
	signal CLOCK : std_logic := '1';
	signal STOP : bit := '0';
begin

am: AsyncMul 
	generic map ( N => 12 )
	port map ( A => A_in, B => B_in, C => open);

sm: SyncMul
	generic map ( N => 12 )
	port map ( CLK => CLOCK, A => A_in, B => B_in, C => open);

CLOCK_PROCESS:
	process
	begin
		if(STOP='0') then
			CLOCK <= not CLOCK;
			wait for CLK_P/2;
		else
			wait;
		end if;
	end process;
	
STIMULI:
	process
	begin
		-- operand A
		A_in <= "000000000010";
		wait for CLK_P;
		-- check B
		B_in <= "000000001011";
		wait for CLK_P;
		-- check B transition on negative numbers
		B_in <= "111111111111";
		wait for CLK_P;
		-- and A for negative numbers
		A_in <= "111001101001";
		wait for CLK_P;
		-- and A for negative numbers
		A_in <= to_signed(2**10, 12);
		wait for CLK_P;
		STOP <= '1';
		wait;
	end process;
end Stimoli;
