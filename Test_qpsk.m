clear
clc
close all

load('/home2/LIG/BPSK_LFM_Overlap_v3/sir_0_dB.mat')
t = 1 : 1148;
i = 1;

subplot(321)
% plot(t, real(qpsk_iq(i, :)), t , imag(qpsk_iq(i, :)))
plot(t, real(qpsk_iq(i, :)))
title('QPSK (time domain)')

subplot(322)
imagesc(squeeze(abs(qpsk_stft(i, :, :))))
title('QPSK (TFI)')

subplot(323)
% plot(t, real(lfm_iq(i, :)), t , imag(lfm_iq(i, :)))
plot(t, real(lfm_iq(i, :)))
ylim([-1 1])
title('LFM (time domain)')

subplot(324)
imagesc(squeeze(abs(lfm_stft(i, :, :))))
title('LFM (TFI)')

subplot(325)
% plot(t, real(overlap_iq(i, :)), t , imag(overlap_iq(i, :)))
plot(t, real(overlap_iq(i, :)))
ylim([-1 1])
title('Overlap (time domain)')

subplot(326)
imagesc(squeeze(abs(overlap_stft(i, :, :))))
title('Overlap (TFI)')

qpsk_phase = exp(-1i*phases(i,:)) .* qpsk_iq(i, :);
figure(2)
plot(t, real(qpsk_phase), t, imag(qpsk_phase))
bit_demod = [];
for n = 1 : 287
    tmp = (qpsk_phase(4*(n-1) + 2));
    if real(tmp) >= 0 && imag(tmp) >= 0
        bit_demod(n) = 0;
    elseif real(tmp) < 0 && imag(tmp) >= 0
        bit_demod(n) = 2;
    elseif real(tmp) >= 0 && imag(tmp) < 0
        bit_demod(n) = 1;
    else
        bit_demod(n) = 3;
    end
end
num_error = sum(abs(squeeze(bits(i, :)) - squeeze(bit_demod)));