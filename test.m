% Define parameters
N = 1000; % Number of bits
sps = 8; % Samples per symbol
span = 6; % Filter span
beta = 0.25; % Roll-off factor

% Generate random bits
bits = randi([0 1], N, 1);

% Map bits to BPSK symbols
symbols = 2*bits - 1;

% Upsample the symbols
upsampled_symbols = upsample(symbols, sps);

% Create the raised cosine filter
h = rcosdesign(beta, span, sps);

% Filter the upsampled symbols
bpsk_signal = filter(h, 1, upsampled_symbols);

% Shift the signal to compensate for the delay introduced by the filter
delay = span*sps/2;
bpsk_signal = [bpsk_signal(delay+1:end); zeros(delay,1)];

% Now 'bpsk_signal' is the BPSK signal with a raised cosine pulse shape

% Plot the first few symbols of the BPSK signal
figure;
stem(bpsk_signal(1:sps*10), 'filled');
title('BPSK signal with Raised Cosine pulse shaping');
xlabel('Sample');
ylabel('Amplitude');
grid on;