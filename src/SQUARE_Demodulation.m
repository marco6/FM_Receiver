% in questo file matlab ho tentato di demodulare con un algoritmo diverso
% (molto più facile!). Provare per credere i risultati sono decenti!
% Adesso direi di finire per prima cosa di fare il progetto come vuole lui
% poi c'è da pensarci, perchè questo non è nemmeno retroazionato....
clear all
close all
% Frequenza campionamento
Fs = 1e6;

% Frequenza di modulazione
Fc = 5000;

% Trasmetto 1/10 di secondo!
t = 0:1/Fs:1; 

% Input di prova
x = sin(2*pi*300*t) + 3 * sin(2*pi*800*t) + 2 * sin(2*pi*600*t) + 3 * sin(2*pi*400*t);
x = x/max(x);


% deviazione 
dev = 50;

% Modulazione
y = fmmod(x, Fc, Fs, dev);

% Amplificazione con clipping
y = (min(1, max(-1, y * 1000)) + 1) / 2;

% segnale demodulazione e risultato
z = (square(2 * pi * Fc * t) + 1) / 2;

for i = 1:length(y)
	z(i) = (z(i) ~= y(i));
end	
z = -cumsum(z - mean(z));
z = z/max(z);

[b, a] = butter(4, 3000/Fs);

z1 = filter(b,a,z);

[b, a] = butter(4, 400/Fs, 'high');

z1 = filter(b,a,z1);
z1 = z1/max(z1);
plot(t(1:length(t)-1400), [x(1:length(x)-1400);z1(1401:length(z1))]);

