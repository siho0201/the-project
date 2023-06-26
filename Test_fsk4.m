clear
clc
close all

fs = 1000;
load('/home2/LIG/Fsk4_LFM_Overlap/sir_0_dB.mat')
t = 1 : 1148;
i = 61;
subplot(321)
plot(t, real(fsk4_iq(i, :)), t , imag(fsk4_iq(i, :)))
title('FSK4 (time domain)')

subplot(322)
imagesc(squeeze(abs(fsk4_stft(i, :, :))))
title('FSK4 (TFI)')

subplot(323)
plot(t, real(lfm_iq(i, :)), t , imag(lfm_iq(i, :)))
title('LFM (time domain)')

subplot(324)
imagesc(squeeze(abs(lfm_stft(i, :, :))))
title('LFM (TFI)')

subplot(325)
plot(t, real(overlap_iq(i, :)), t , imag(overlap_iq(i, :)))
title('Overlap (time domain)')

subplot(326)
imagesc(squeeze(abs(overlap_stft(i, :, :))))
title('Overlap (TFI)')

fsk4_phase = exp(-1i*phases(i,:)) .* fsk4_iq(i,:);
figure(2)
plot(t, real(fsk4_phase), t, imag(fsk4_phase))

M = 4; % Number of symbols in the FSK modulation, 4 for 4-FSK
freqsep = fs / (4 * (M - 1));  % Frequency separation

bit_demod = fskdemod(fsk4_phase, M, freqsep, 4, fs);
num_error = sum(abs(squeeze(bits(i, :)) - squeeze(bit_demod)));