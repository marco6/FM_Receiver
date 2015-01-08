library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.Helpers.all;

-- Questo è l'NCO completo che si vede da fuori.
-- Descrivo di lato i vari input.
entity NCO is
generic ( N, -- Questa è il numero di bit in ingresso (addressing space)
		M -- Questa invece è la larghezza in bit dell'uscita
		: positive := 12 -- entrambi sono di default a 12 bit perchè fa 
						 -- fa comodo visto che l'xadc sputa 12 bit
		);
port (
	CLK, RST : in std_logic;
	STEP : in unsigned(N-1 downto 0); -- Parte programmabile del NCO...
									  -- in pratica decide la frequenza
									  -- di demodulazione.
									  -- Sotto c'è una spiegazione di
									  -- come calcolre la frequenza
									  -- dato N.
	E_IN : in signed(N-1 downto 0); -- Errore di fase: serve al NCO per
									-- riuscire a seguire il segnale.
									-- E' in pratica l'ingresso che 
									-- proviene dal loop.
	C_OUT : out signed(M-1 downto 0)-- Output: l'onda generata.
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

-- Ok questo lo traduco (ma lascio anche l'inglese perchè ormai l'ho 
-- scritto!
-- Un Oscillatore Numerico deve produrre un onda cosinusoidale a una 
-- specifica frequenza e inseguire la fase per mantenere il PLL chiuso.
-- Questo NCO può essere sintonizzato a una qualsiasi frequenza multipla
-- intera di quella di base tramite la programmazione della porta STEP.
-- Step sarà aggiunta ad un contatore interno a ogni ciclo di clock.
-- In questo modo, data 
--		f0 = frequenza minima
-- la frequenza di output sarà
-- 		F_out = STEP * f0

--
-- Per calcolare f0, bisogna tenere in considerazione come è ottenuto il 
-- coseno: la cosine rom è riempida di campioni precalcolati.
-- L'addressing widh della rom è N e quindi ci saranno 2^N campioni
-- in essa. Dato quindi il periodo del clock T (in secondi), un ciclo 
-- intero di 2PI radianti si ottiene passando in sequenza tutti i 
-- campioni ovvero:
-- 		MIN_COS_PERIOD = T * 2^N sec
-- E quindi 
-- 		f0 = 1/MIN_COS_PERIOD = 1/(t*2^N) Hz
--


-- Ragazzuoli io quì ne faccio due: una come dice lui (in stile indiano
-- insomma) e una con la conversione RAD => unità di misura del cazzo.
architecture Indian_Beh of NCO is
	-- la cosine rom... Io l'ho pensata così la definizione... ora sid
	-- deve vedere se gli va bene o no...
	component cos_rom is
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

	-- I first instantiate the cos_rom
c_gen: cos_rom
	generic map(N => N, M => M)
	port map(
		CLK => CLK,
		IDX => COUNTER,
		C_OUT => C_OUT 	-- the output of the rom is just the output of
						-- the NCO!
	);

	-- in questa control unit me ne frego dell'nità di misura, come fa
	-- l'indiano(o japu?!?) e "vediamo come va"... 
counter_driver:
	process(CLK, RST)
	begin
		if (RST = '1') then
			COUNTER <= (others => '0');
		elsif(rising_edge(CLK)) then
			-- in questo caso quindi mi basta sommare.
			COUNTER <= COUNTER + STEP + 
				unsigned(E_IN); 
		end if;
		-- and that's all folks (carrot time needed!).
	end process;
end architecture;

-- Lo so che "UnitCare" sembra na cosa da ospedale... 
-- Ma se avete un'idea migliore sono aperto a proposte!
architecture UnitCare_Beh of NCO is
	-- questa serve sempre
	component cos_rom is
		generic ( N, M : positive := 12 );
		port (
			CLK : in std_logic;
			IDX : in unsigned( N-1 downto 0);
			C_OUT : out signed ( M-1 downto 0)
		);
	end component;
	
	-- Questa pure però per il trucchetto che utilizzo per far 
	-- quadrare i conti, serve un counter più grande
	signal COUNTER : unsigned(N+1 downto 0);
begin
	-- Il problema principale quì è quindi che STEP è definito in
	-- parti di angolo: 1 STEP = 2PI/2^N, mentre E_IN è definito in 
	-- radianti ( anche se moltiplicati per 2^(N-1) ).
	-- 
	-- il trucco quì consiste nel percorrere la cos_rom PI volte più 
	-- velocemente, mentre invece E_IN sarà aggiunto senza questo fattore
	-- moltiplicativo.
	-- Questo però incrementa la frequenza minima di PI volte e quindi
	-- per tamponare questo effetto, si prende un addressing space
	-- maggiore (2 bit in più). In questo modo la frequenza minima 
	-- diminuisce addirittura di un fattore di 4/PI. Non di tanto quindi.
c_gen: cos_rom
	generic map(
		N => (N+2), -- come dicevo prima, due bit aggiuntivi!
		M => M) -- qui invece tutto uguale!
	port map(CLK => CLK,
		IDX => COUNTER,
		C_OUT => C_OUT
	); -- le porte invece non cambiano
	
	-- la struttura è simile
counter_driver:
	process(CLK, RST)
	begin
		-- quì c'è sempre un reset asincrono
		if (RST = '1') then
			COUNTER <= (others => '0');
		elsif(rising_edge(CLK)) then
			-- quì però cambia qualcosina:
			COUNTER <= COUNTER 
				-- come approssimazione per PI uso 3.125 = 3 + 1/8
				-- sperando vada bene
				+ STEP + STEP & '0' -- questa riga equivale a STEP * 3
				+ STEP(STEP'left downto 3) -- questo equivale a * 1/8
				+ TO_UNSIGNED_RESIZE(E_IN, N+2); 
				-- E questo invece lo trasformo in N+2 bit, tenendo conto
				-- del segno!
		end if;
	end process;
end architecture;
