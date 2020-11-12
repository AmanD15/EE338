close all;
clearvars;
clc;

% Specs
m = 74;
q_m = floor(0.1*m);
r_m = m - 10*q_m;
BL = 25+1.9*q_m + 4.1*r_m;
BH = BL + 20;
trans_bw = 4*10^3;

% Band Edge specifications
fs1 = BL*10^3-trans_bw
fp1 = BL*10^3
fp2 = BH*10^3
fs2 = BH*10^3+trans_bw
f_samp = 260e3;
ws1=fs1*2*pi/f_samp;
wp1=fp1*2*pi/f_samp;
wp2=fp2*2*pi/f_samp;
ws2=fs2*2*pi/f_samp;
delta = 0.15

% Kaiser paramters
A = -20*log10(delta);
if(A < 21)
    beta = 0;
elseif(A <51)
    beta = 0.5842*(A-21)^0.4 + 0.07886*(A-21);
else
    beta = 0.1102*(A-8.7);
end
d_omega_by_pi = trans_bw*2/f_samp;
d_omega=d_omega_by_pi*pi;
N_min = ceil((A-8) / (2*2.285*(d_omega)))          

% Window length for Kaiser Window
addend = 4 % N_min gives the minimum, add something to it to get exact
% addend is found such that stopband specs are met
n=N_min + addend;

%Ideal bandpass impulse response of length n
w1=(ws1+wp1)/2;
w2=(ws2+wp2)/2;
bp_ideal = ideal_lp(w2,2*n+1) - ideal_lp(w1,2*n+1);   % bandpass filter with same specs
bs_ideal = ideal_lp(pi,2*n+1)-bp_ideal;               % 1 - bandpass (lowpass filter with cutoff freq pi = all pass filter)

% Kaiser Window of length n with shape paramter beta calculated above
% the in-built function generates a function centered at n  
kaiser_win_shifted = (kaiser(2*n+1,beta))';    
num_arr = [-n:1:n];
kaiser_win = kaiser_win_shifted(num_arr+n+1);  % centered at 0
FIR_BandStop = bs_ideal .* kaiser_win;         

fvtool(FIR_BandStop,'Analysis','freq');         %frequency response

%magnitude response
[H,f] = freqz(FIR_BandStop,1, 1024*1024,f_samp);
plot(f,abs(H))
% xline(fs1);
% yline(0.15);
% 
% xline(fp1);
% yline(0.85);
grid
