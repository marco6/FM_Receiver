
# Installazione:

Prima di tutto serve un client GIT se no diventiamo cretini con la 
linea di comando.

- Per windows e mac github ha già una sua app che va da dio 
	- Windows: https://windows.github.com/
	- MAC:  https://mac.github.com/
	- Anche quì, la fantasia per i nomi dei siti gioca un ruolo fondamentale.
- Per Linux invece c'è un programma esterno gratis per l'uso non commerciale
  che è praticamente uguale a quello di github:
	- http://www.syntevo.com/smartgit/download
	- Se qualcuno usa ubuntu è meglio che scarichi il "deb package"
	  che è compatibile.

## Per fare sta roba serve:

- GHDL (sudo apt-get install ghdl)
- gtkwave (sudo apt-get install gtkwave)
- make (se avete gcc dovrebbe essere già installato)

## Per usarli su Windows invece dovete installare:

- GHDL ( http://sourceforge.net/projects/ghdl-updates/ )
- gtkwave ( http://gtkwave.sourceforge.net/ )
- make o mingw (consiglio mingw che è completo) 
	- http://gnuwin32.sourceforge.net/packages/make.htm
	- http://www.mingw.org/

Dovete anche aggiungere tutte le cartelle con gli eseguibili al PATH
(vedi http://stackoverflow.com/questions/6318156/adding-python-path-on-windows-7 )

# Divisione dei compiti:

## Marco:

- NCO:
	- Controller
	- (Tuner Control ?)

## Ienny:

- Low pass filter (auguri)

##Carlo:

- Amp (con clipping)
- PLL (collegamenti)
- Configurazione(Probabile visto che dobbiamo provare più cose)

## SID:

- Phase detector (vaccata)
- Cosine Rom (non vaccata)

## Nick:

- Loop filter (auguri anche a te)

# Manca ancora:

- Input per la simulazione (questo ognuno prova a farsi il suo poi vediamo)
	- per favore usate lo stesso formato: un valore per riga, tutto 
	  scritto in decimale.. Se no anche quì diventiamo scemi.
- l'XADC (Questo chiediamo aiuto al prof.)
- Output (alla fine, se davvero lo mettiamo sulla scheda)

# Piazzate qua sotto i file/link di documentazione

- PDF tesi indiano: http://read.pudn.com/downloads166/ebook/757199/full%20digital%20FM%20receiver.pdf 
- Clipping (per l'amplificatore radio): http://en.wikipedia.org/wiki/Clipping_%28audio%29 
- Introduzione facile a git, per non sbagliare: http://rogerdudler.github.io/git-guide/index.it.html

# Note sul codice:

Ragazzi piazzo quì qualche regoletta/consiglio per non smadonnare come 
mi è successo a tirocinio!

- Commenti
- Possibilmente fate le cose parametriche (ovvero niente costanti 
	magiche ma usate pesantemente i generici)
- Nomi delle variabili/segnali comprensibili a umani
- Se una variabile deve rappresentare numeri, usate solo e soltanto 
	- signed o unsigned dalla libreria standard _IEEE.numeric_std_ 
	  perchè quella è sintetizzabile completamente.
	- Non usate librerie non standard in generale... Alla finte tanto non
	  servono
- Per i numeri con la virgola, non ragionate in "bit interi" e "bit 
	decimali" come dice di fare il prof di assembly.. E' UNA VACCATA.
	Ragionate piuttosto come se fosse una frazione.
	Ad esempio se avete da rappresentare 1.25 su 8 bit, si potrebbe usare
	10100000b = 160 come numeratore e immaginare che il denominatore 
	sia 128. 160/128 è facile da maneggiare nelle moltiplicazioni, pensare
	al numero di bit invece no. 
- Per far funzionare il makefile che ho scritto, dovete per forza creare
	due cartelle aggiuntive: _build_ e _waves_ .
- Come editor:
	- Su windows notepad++ è comodo ( http://notepad-plus-plus.org/ )
	- Ma linux vince di nuovo con geany ( sudo apt-get install geany )
		[ http://www.geany.org/ ]