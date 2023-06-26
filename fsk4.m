function fsk_signal_filtered = fsk4(bits, t, phase, symbol_duration)
    dt = t(2) - t(1);
    fs = 1/dt;
    base_freq = fs/4; % 가장 낮은 주파수를 기준 주파수로 설정
    freq_deviation = fs/8;
    sps = 4; % Samples per symbol (now 4 as per your requirement)
    span = 32; % Filter span
    beta = 0.1; % Roll-off factor

    for i = 1 : length(t)
        symbol = bits(ceil(i/(symbol_duration/dt)));
        freq = base_freq + symbol*freq_deviation; % 각 심볼에 대한 주파수를 계산
        fsk4_signal(i) = exp(1i*(2*pi*freq*t(i) + phase(i))); % 4-FSK 신호 생성
    end
 
    rcosFilter = rcosdesign(beta, span, sps, 'sqrt');
    fsk_upsampled = upsample(fsk4_signal, sps);
    fsk_signal_filtered = filter(rcosFilter, 1, [fsk_upsampled zeros(1, span*sps)]); % FIR filtered signal
    fsk_signal_filtered = fsk_signal_filtered(span*sps/2+1:end-span*sps/2);
    fsk_signal_filtered = downsample(fsk_signal_filtered, sps);
end