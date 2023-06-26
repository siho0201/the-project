clear
clc
close all

load('/home2/LIG/BPSK_LFM_Overlap_data/sir_0_dB.mat')
load('/home2/LIG/siho/the_project/mid_img_complex/sir_0_dB.mat')
t = 1 : 1148;
i = 25;

figure(1)
a = imagesc(squeeze(abs(bpsk_stft(i, :, :))));
axis off
print('-dpng', '-r300', 'bpsk.png');

figure(2)
b = imagesc(squeeze(abs(lfm_stft(i, :, :))));
axis off
print('-dpng', '-r300', 'lfm.png');

figure(3)
c = imagesc(squeeze(abs(overlap_stft(i, :, :))));
axis off
print('-dpng', '-r300', 'overlapping.png');
%% 

