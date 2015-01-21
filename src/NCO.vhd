library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.Helpers.all;

entity NCO is
generic ( N, -- Number of bits as input
		M -- Number of bits as output
		: positive := 12 -- Default to 12 bit because of the xadc
		);
port (
	CLK, RST : in std_logic;
	STEP : in unsigned(N-1 downto 0); -- Programmable part of NCO...
									  -- it decides the demod freqency.
									  -- Below there's an explanation on how
									  -- to calculate freq given STEP and 
									  -- N.
	E_IN : in signed(N-1 downto 0); -- Phase error input: this needs to be
									-- connected to the loop filter out.
	C_OUT : out signed(M-1 downto 0)-- In-phase cosine
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
-- a cosine rom is filled whose addressing width width is N.
-- This means that I get 2^N samples of the cosine in my rom
-- and given the clock period T I get a full 2PI cicle in
-- MIN_COS_PERIOD = T * 2^N sec if STEP is equal to 1
-- so F0 = 1/MIN_COS_PERIOD = 1 / (T * 2^N)  Hz

-- This architecture doesn't take care of what type of signal arrives as
-- input. It just adds the error to the count.
architecture Naive_behavioral of NCO is
	-- Component needed
	component cosine_rom is
		generic ( N, M : positive := 12 );
		port (
			CLK : in std_logic;
			IDX : in unsigned( N-1 downto 0);
			C_OUT : out signed ( M-1 downto 0)
		);
	end component;
	
	-- Than a counter to take track of the last angle computed
	signal COUNTER : unsigned(N-1 downto 0) := (others => '0');
begin

	-- I first instantiate the cosine_rom
rom: cosine_rom
	generic map(N => N, M => M)
	port map(
		CLK => CLK,
		IDX => COUNTER,
		C_OUT => C_OUT 	-- the output of the rom is just the output of
						-- the NCO!
	);

counter_driver:
	process(CLK, RST)
	begin
		if (RST = '1') then
			COUNTER <= (others => '0');
		elsif(rising_edge(CLK)) then
			-- this is just a sum
			COUNTER <= COUNTER + STEP + 
				unsigned(E_IN); 
		end if;
		-- and that's all folks (carrot time needed!).
	end process;
end architecture;


architecture Behavioral of NCO is
	-- Just like above
	component cosine_rom is
		generic ( N, M : positive := 12 );
		port (
			CLK : in std_logic;
			IDX : in unsigned( N-1 downto 0);
			C_OUT : out signed ( M-1 downto 0)
		);
	end component;
	
	
	signal COUNTER : unsigned(N+1 downto 0);
begin
	-- the main problem is that STEP is defined in 'angle slices': 
	-- 1 STEP = 2PI/2^N while E_IN is defined as radians (multiplyed by
	-- 2^(N-1));
	-- 
	-- So the trick here is to go through the rom PI times faster, while
	-- E_IN will be added without any multiplication.
	-- This does increase the minimum frequency of PI times and so, to 
	-- reduce this effect, I take a bigger addressing space (2 more bits)
	--In this way the minimum freq is reduced by 4/PI. Not that much!
c_gen: cosine_rom
	generic map(
		N => (N+2), -- Plus 2
		M => M) -- Normal out
	port map(CLK => CLK,
		IDX => COUNTER,
		C_OUT => C_OUT
	);
	
counter_driver:
	process(CLK, RST)
	begin
		-- Async reset
		if (RST = '1') then
			COUNTER <= (others => '0');
		elsif(rising_edge(CLK)) then

			-- PI approximation: 3.125 = 3 + 1/8
			COUNTER <= COUNTER 
				+ STEP + STEP & '0' -- this is 'step * 3'
				+ STEP(STEP'left downto 3) -- this is 'step / 8'
				+ unsigned(E_IN); 
		end if;
	end process;
end architecture;
