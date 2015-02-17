% in questo file matlab ho tentato di demodulare con un algoritmo diverso
% (molto più facile!). Provare per credere i risultati sono decenti!
% Adesso direi di finire per prima cosa di fare il progetto come vuole lui
% poi c'è da pensarci, perchè questo non è nemmeno retroazionato....
clear all
close all
% Frequenza campionamento
Fs = 1e6;

% Frequenza di modulazione
Fc = 50000;

% Trasmetto 1/10 di secondo!
t = 0:1/Fs:0.1; 

% Input di prova
x = sin(2*pi*800*t);
x = x/max(x);


% deviazione 
dev = 200;

% Modulazione
y = fmmod(x, Fc, Fs, dev);

% Amplificazione con clipping
y = y > 0;
plot(t, double(y)); figure

% segnale demodulazione e risultato
z = (square(2 * pi * Fc * t + pi/4) + 1) / 2;

z = z ~= y;
z = cumsum(z - 0.5);
%z = z/max(z);

% decimo z
z_dec = z(1:round(Fs/Fc):length(z));
t_dec = t(1:round(Fs/Fc):length(t));

%[b, a] = butter(4, 15000/Fs);

z1 = z;%filter(b,a,z);

[b, a] = butter(4, 400/Fs, 'high');

z1 = filter(b,a,z1);
%z1 = z1/max(z1);





%[b, a] = butter(4, 15000/Fc);
%z2 = filter(b,a,z_dec);
z2 = z_dec;
[b, a] = butter(4, 100/Fc, 'high');

z2 = filter(b,a,z2);
%z2 = z2/max(z2);
plot(t, [x;z1]);
hold on
plot(t_dec, z2, 'r');
