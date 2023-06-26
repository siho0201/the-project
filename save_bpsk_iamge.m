clear
clc
close all

load('/home2/LIG/BPSK_LFM_Overlap_data/sir_0_dB.mat')
load('/home2/LIG/siho/the_project/mid_img_complex/sir_0_dB.mat')
t = 1 : 1148;
i = 25;

subplot(321)
% plot(t, real(bpsk_iq(i, :)), t , imag(bpsk_iq(i, :)))
plot(t, real(bpsk_iq(i, :)))
ylim([-1 1])
title('BPSK (time domain)')

subplot(322)
imagesc(squeeze(abs(bpsk_stft(i, :, :))))
title('BPSK (TFI)')

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
title('Overlap (time domain)')

subplot(326)
imagesc(squeeze(abs(overlap_stft(i, :, :))))
title('Overlap (TFI)')

figure(2)
imagesc(squeeze(abs(mid(i,:,:))))
% bpsk_phase = exp(-1i*phases(i,:)) .* bpsk_iq(i, :);
% figure(2)
% % plot(t, real(bpsk_phase), t, imag(bpsk_phase))
% plot(t, real(bpsk_phase))
% ylim([-1 1])
% bit_demod = [];
% for n = 1 : 287
%     bit_demod(n) = (sum(bpsk_phase(4*(n-1) + 1 : 4*n)) >= 0);
% end
% num_error = sum(abs(squeeze(bits(i, :)) - squeeze(bit_demod)));