clear
clc

sample_ex = 1200;
sample = 1148;
fs = 1000;             % 샘플링 주파수
T = 1/fs;               % 샘플링 간격
t_ex = 0:T:sample_ex/fs-T;
t = 0:T:sample/fs-T;            % Times (0s ~ 0.768s)
symbol_sample = 4;
symbol_duration = symbol_sample*T; % BPSK의 Symbol Duration (0.0004s = 4 samples)
qpsk_bandwidth = 300;   % QPSK의 Bandwidth

sirs_dB = 0 : 1 : 30;

% Check if the folder exists
if ~exist('/home2/LIG/QPSK_LFM_Overlap', 'dir')
   % If not, create the folder
   mkdir('/home2/LIG/QPSK_LFM_Overlap');
end

for sir_dB = sirs_dB
    sir = 10 ^ (sir_dB / 10);
    bits = zeros(300, sample/symbol_sample); % 이 부분을 수정했습니다. QPSK는 기호당 2비트를 처리합니다.
    qpsk_iq = zeros(300, sample);
    lfm_iq = zeros(300, sample);
    overlap_iq = zeros(300, sample);
    phases = zeros(300, sample);
    qpsk_stft = [];
    lfm_stft = [];
    overlap_stft = [];
    lfm_bandwidth = [];
    lfm_chirp_duration = [];
    for i = 1 : 300
        tic
        lfm_sig = zeros(1, sample);
        % 신호 생성
        bit = randi([0 3], 1, sample_ex/symbol_sample); % random bits. 2행으로 수정했습니다.
        phase = pi*randn(1, sample_ex); % random phase
        % phase = zeros(1, sample_ex); % random phase
        qpsk_signal = qpsk(bit, t_ex, phase, symbol_duration); % qpsk signal
        qpsk_signal = qpsk_signal(1 : sample);
        bit = bit(:, 1 : sample/symbol_sample);
        phase = phase(1 : sample);
        power_qpsk = sum(abs(qpsk_signal) .^ 2); % qpsk power
        chirp_duration_half = T * randi([100, sample/2]);
        chirp_duration = 2*chirp_duration_half; % lfm chirp duration
        lfm_bw = randi([sample/2, sample/1.]); % lfm의 Bandwidth
        lfm_sig = lfm(t, chirp_duration, lfm_bw); % 초기 lfm signal
        power_lfm = sum(abs(lfm_sig) .^ 2); % 초기 lfm power
        lfm_signal = sqrt(double(sir) * power_qpsk  / power_lfm) * lfm_sig; % sir 고려한 lfm signal
        overlap_signal = qpsk_signal + lfm_signal; % 합성 신호

        % STFT
        window_size = 128;
        overlap = 124;
        nfft = 128;
        window = hann(window_size);
        qpsk_img = stft(qpsk_signal, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft);
        lfm_img = stft(lfm_signal, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft);
        overlap_img = stft(overlap_signal, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft);

        % data 업데이트
        qpsk_iq(i, :) = squeeze(qpsk_signal);
        lfm_iq(i, :) = squeeze(lfm_signal);
        overlap_iq(i, :) = squeeze(overlap_signal);
        qpsk_stft(i, :, :) = qpsk_img;
        lfm_stft(i, :, :) = lfm_img;
        overlap_stft(i, :, :) = overlap_img;
        bits(i, :) = squeeze(bit);
        phases(i, :) = squeeze(phase);
        lfm_bandwidth(i) = lfm_bw;
        lfm_chirp_duration(i) = chirp_duration;
        disp(sir_dB + "dB : " + i + "번째 data 완료! (" + toc + "sec)")
    end

    % Matfile 저장
    filename = "sir_" + string(sir_dB) + "_dB.mat";
    filedir = "/home2/LIG/QPSK_LFM_Overlap/" + filename;
    save(filedir, 'qpsk_iq', 'lfm_iq', 'overlap_iq', 'qpsk_stft', 'lfm_stft', 'overlap_stft', 'bits', 'phases', 'qpsk_bandwidth', 'lfm_bandwidth', 'sir_dB', 'lfm_chirp_duration');
end