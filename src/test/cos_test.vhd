library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cos_test is
end cos_test;

architecture Behavioral of cos_test is
	component cos_rom is
		generic ( N, M : positive := 12 );
		port ( 
			CLK : in std_logic;
			IDX : in unsigned( N-1 downto 0);
			C_OUT : out signed ( M-1 downto 0)
		);
	end component;
	
	-- Number of bits for the index
	constant N : positive := 12;
	-- Number of bits for the values
	constant M : positive := 12;
	-- Clock time
	constant CLK_P : time := 1 us;


	signal CLOCK : std_logic := '0';
	signal STOP : bit := '0';
	signal COUNT : unsigned (N-1 downto 0) := (others => '0');
begin

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
	
cr: cos_rom
	generic map(N, M)
	port map( CLK => clock, IDX => count, C_OUT => open);

STIMULI:
	process(CLOCK)
		constant FINE : unsigned(M-1 downto 0) := (others => '1');
	begin
		-- In this test I want to see the wave generate, so I just need to
		-- increment the count and see what appens
		if(rising_edge(clock)) then
			if(COUNT = FINE) then
				STOP <= '1';
			else
				COUNT <= COUNT + 1;
			end if;
		end if;
	end process;
end;
