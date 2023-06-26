clear
clc

% Parameters and Initialization
M =4;
sample_ex = 1200;
sample = 1148;
fs = 1000;  
T = 1/fs;               
t_ex = 0:T:sample_ex/fs-T;
t = 0:T:sample/fs-T;  
symbol_sample = 4;
symbol_duration = symbol_sample*T; 
sirs_dB = 0 : 1 : 0;
symbol_count = sample/symbol_sample;
freqsep = fs / (4 * (M - 1));

% Check if the folder exists
if ~exist('/home2/LIG/Fsk4_LFM_Overlap', 'dir')
   mkdir('/home2/LIG/Fsk4_LFM_Overlap');
end

% FSK4 signal generation for each SIR
for sir_dB = sirs_dB
    sir = 10 ^ (sir_dB / 10);
    bits = zeros(300, sample/symbol_sample);
    fsk4_iq = zeros(300, sample);
    lfm_iq = zeros(300, sample);
    overlap_iq = zeros(300, sample);
    phases = zeros(300, sample);
    fsk4_stft = [];
    lfm_stft = [];
    overlap_stft = [];
    lfm_bandwidth = [];
    lfm_chirp_duration = [];
    
    for i = 1 : 300
        tic
        lfm_sig = zeros(1, sample);

        % Signal generation
        bit = randi([0 3], 1, sample_ex/symbol_sample);
        phase = pi*randn(1, sample_ex); % random phase
        % phase = zeros(1, sample_ex);
        fsk4_signal = fskmod(bit, 4, freqsep, 4,fs);
        fsk4_signal = fsk4_signal(1 : sample);
        bit = bit(:, 1 : symbol_count);
        phase = phase(1 : sample);
        power_fsk4 = sum(abs(fsk4_signal) .^ 2); 

        % LFM signal generation
        chirp_duration_half = T * randi([100, sample/2]);
        chirp_duration = 2*chirp_duration_half; 
        lfm_bw = randi([sample/2, sample/1.]); 
        lfm_sig = lfm(t, chirp_duration, lfm_bw); 
        power_lfm = sum(abs(lfm_sig) .^ 2); 
        lfm_signal = sqrt(double(sir) * power_fsk4  / power_lfm) * lfm_sig; 

        % Overlapping the signals
        overlap_signal = fsk4_signal + lfm_signal; 

        % STFT
        window_size = 128;
        overlap = 124;
        nfft = 128;
        window = hann(window_size);
        fsk4_img = stft(fsk4_signal, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft);
        lfm_img = stft(lfm_signal, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft);
        overlap_img = stft(overlap_signal, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft);

        % Update data
        fsk4_iq(i, :) = squeeze(fsk4_signal);
        lfm_iq(i, :) = squeeze(lfm_signal);
        overlap_iq(i, :) = squeeze(overlap_signal);
        fsk4_stft(i, :, :) = fsk4_img;
        lfm_stft(i, :, :) = lfm_img;
        overlap_stft(i, :, :) = overlap_img;
        bits(i, :) = squeeze(bit);
        phases(i, :) = squeeze(phase);
        lfm_bandwidth(i) = lfm_bw;
        lfm_chirp_duration(i) = chirp_duration;

        disp(sir_dB + "dB : " + i + "번째 data 완료! (" + toc + "sec)")
    end

    % Save Matfile
    filename = "sir_" + string(sir_dB) + "_dB.mat";
    filedir = "/home2/LIG/Fsk4_LFM_Overlap/" + filename;
    save(filedir, 'fsk4_iq', 'lfm_iq', 'overlap_iq', 'fsk4_stft', 'lfm_stft', 'overlap_stft', 'bits', 'phases', 'lfm_bandwidth', 'sir_dB', 'lfm_chirp_duration');
end
