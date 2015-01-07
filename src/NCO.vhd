library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- TODO: E mo 'sta robba come la testi?!?
entity NCO is
generic ( N, M : positive := 12 );
port (
	CLK, RST : in std_logic;
	STEP : in unsigned(N-1 downto 0);
	E_IN : in signed(N-1 downto 0); -- Phase error
	C_OUT : out signed(M-1 downto 0)
);
end entity;

-- An Numeric Controlled Oscillator should produce a cosine wave
-- at a specified frequency to keep a PLL locked.
-- This NCO can be tuned to any frequency even multiple of its base frequency
-- through the programmation of the port STEP.
-- Step will be added to the internal counter at every clock cycle. This
-- way given 
-- 		f0 = lowest frequency that can be obtained
-- the output frequency is STEP * f0.

-- To compute f0, I must take into account how the cosine is obtained:
-- a cosine rom is filled whose addressing space width is N.
-- This means that I get 2^N samples of the cosine in my rom
-- and given the clock period T I get a full 2PI cicle in
-- MIN_COS_PERIOD = T * 2^N sec if STEP is equal to 1
-- so F0 = 1/MIN_COS_PERIOD = 1 / (T * 2^N)  Hz
architecture Behavioral of NCO is
	-- first I need a cos_rom to get the values I need
	component cos_rom is
		generic ( N, M : positive := 12 );
		port (
			CLK : in std_logic;
			IDX : in unsigned( N-1 downto 0);
			C_OUT : out signed ( M-1 downto 0)
		);
	end component;
	
	-- Than a counter to take track of the last angle computed
	signal COUNTER : unsigned(N-1 downto 0);
begin

	-- I first instantiate the cos_rom
c_gen: cos_rom
	generic map(N => N, M => M)
	port map(
		CLK => CLK,
		IDX => COUNTER,
		C_OUT => C_OUT 	-- the output of the rom is just the output of
						-- the NCO!
	);
	
	-- Now I need to drive the counter, but it should be simple enough
counter_driver:
	process(CLK, RST) -- async reset
	begin
		if (RST = '1') then
			COUNTER <= (others => '0');
		elsif(rising_edge(CLK)) then
			-- this is just a sum!
			COUNTER <= COUNTER + STEP + unsigned(E_IN);
		end if;
		-- and that's all folks (carrot time needed!).
	end process;
	
end architecture;
