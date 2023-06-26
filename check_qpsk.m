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

sps = 4; % Samples per symbol (now 4 as per your requirement)
span = 8; % Filter span
beta = 0.01; % Roll-off factor

bit = randi([0 3], 1, sample_ex/symbol_sample); % random bits. 2행으로 수정했습니다.
% phase = pi*randn(1, sample_ex); % random phase
phase = zeros(1, sample_ex); % random phase
qpsk_signal = qpsk(bit, t_ex, phase, symbol_duration); % qpsk signal
qpsk_signal = qpsk_signal(1 : sample);






% figure(1); % Create a new figure window
% 
% % Plot the real part of the QPSK signal
% subplot(2, 1, 1); % Create a subplot for the real part
% plot(real(qpsk_signal)); % Plot the real part
% 
% % Plot the imaginary part of the QPSK signal
% subplot(2, 1, 2); % Create a subplot for the imaginary part
% plot(imag(qpsk_signal)); % Plot the imaginary part

figure(2); % Create a new figure window

% Plot the real part of the QPSK signal
subplot(2, 1, 1); % Create a subplot for the real part
plot(real(qpsk_signal_filtered)); % Plot the real part

% Plot the imaginary part of the QPSK signal
subplot(2, 1, 2); % Create a subplot for the imaginary part
plot(imag(qpsk_signal_filtered)); % Plot the imaginary part





