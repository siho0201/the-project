function qpsk_signal_filtered = qpsk(bits, t, phase, symbol_duration) % Input Bits, Times, Phase, Symbol Duration, Samples per Symbol, Filter Span, Roll-off Factor
    % Design a Raised Cosine filter
 
    sps = 4; % Samples per symbol (now 4 as per your requirement)
    span = 32; % Filter span
    beta = 0.1; % Roll-off factor

    dt = t(2) - t(1);
    % fs = 1/dt;
    % Map the bits to QPSK symbols
    symbols = [1+1i, 1-1i, -1+1i, -1-1i] / sqrt(2);
    qpsk = zeros(1, length(t));
    for i = 1 : length(t)
        qpsk(i) = exp(1i*phase(i))*symbols(bits(ceil(i/(symbol_duration/dt))) + 1);   % qpsk signal
    end

    qpsk_signal = qpsk;
    rcosFilter = rcosdesign(beta, span, sps, 'sqrt');
    qpsk_upsampled = upsample(qpsk_signal, sps);
    qpsk_signal_filtered = filter(rcosFilter, 1, [qpsk_upsampled zeros(1, span*sps)]); % FIR filtered signal
    qpsk_signal_filtered = qpsk_signal_filtered(span*sps/2+1:end-span*sps/2);
    qpsk_signal_filtered = downsample(qpsk_signal_filtered, sps);
    
   
end